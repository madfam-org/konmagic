import Foundation
import SQLite3
import Darwin

struct LensDifferencePage {let rows:[LensDifference];let next:String?}
struct LensDifference {var path:String,status:String,before:Int64,after:Int64}
extension LensStore {
    private func differenceSource(_ baseline:LensStore,cancellation:CatalogueCancellation,seconds:TimeInterval=60) throws -> (AtlasDatabase,String) {
        let current=try snapshot(),old=try baseline.snapshot()
        guard current.root==old.root else {throw KonMagicError("Compare scans of the same root. Different roots cannot be interpreted as added or removed files.")}
        let baselineParent=try SafeFS.openDirectory(baseline.url.deletingLastPathComponent().path);defer {close(baselineParent)}
        guard SafeFS.isFile(try SafeFS.info(baselineParent,baseline.url.lastPathComponent)) else {throw KonMagicError("Baseline is not a regular scan.")}
        let reader=try AtlasDatabase(url.path,seconds:seconds,cancellation:cancellation)
        try reader.rows("ATTACH DATABASE ? AS baseline",[baseline.url.path]) {_ in}
        let relative="CASE WHEN p.relative='' THEN n.name ELSE p.relative||'/'||n.name END"
        let forward="SELECT "+relative+" AS path,CASE WHEN o.id IS NULL THEN 'Added' ELSE 'Changed' END AS status,coalesce(o.bytes,0) AS before,n.bytes AS after FROM nodes n JOIN nodes p ON p.id=n.parent LEFT JOIN baseline.nodes q ON q.kind=1 AND q.relative=p.relative LEFT JOIN baseline.nodes o ON o.parent=q.id AND o.name=n.name AND o.kind=0 WHERE n.kind=0 AND (o.id IS NULL OR n.bytes<>o.bytes OR n.allocated<>o.allocated OR n.modified<>o.modified OR n.inode<>o.inode OR n.flags<>o.flags)"
        let removed="SELECT "+relative+" AS path,'Removed' AS status,n.bytes AS before,0 AS after FROM baseline.nodes n JOIN baseline.nodes p ON p.id=n.parent LEFT JOIN nodes q ON q.kind=1 AND q.relative=p.relative LEFT JOIN nodes o ON o.parent=q.id AND o.name=n.name AND o.kind=0 WHERE n.kind=0 AND o.id IS NULL"
        return (reader,"("+forward+" UNION ALL "+removed+")")
    }
    func differencePage(_ baseline:LensStore,cursor:String?=nil,cancellation:CatalogueCancellation) throws -> LensDifferencePage {
        let (reader,source)=try differenceSource(baseline,cancellation:cancellation)
        var rows:[LensDifference]=[]
        try reader.rows("SELECT path,status,before,after FROM "+source+(cursor==nil ? "" : " WHERE path>?")+" ORDER BY path COLLATE BINARY LIMIT 501",cursor.map {[$0]} ?? []) {s in rows.append(LensDifference(path:AtlasDatabase.string(s,0),status:AtlasDatabase.string(s,1),before:sqlite3_column_int64(s,2),after:sqlite3_column_int64(s,3)))}
        let more=rows.count>500;if more {rows.removeLast()}
        return LensDifferencePage(rows:rows,next:more ? rows.last?.path : nil)
    }
    func compare(_ baseline:LensStore,cancellation:CatalogueCancellation) throws -> [LensDifference] {
        let page=try differencePage(baseline,cancellation:cancellation)
        return page.rows
    }
    func exportDifferences(_ baseline:LensStore,to destination:URL,cancellation:CatalogueCancellation) throws -> Int {
        let (reader,source)=try differenceSource(baseline,cancellation:cancellation,seconds:6*3600)
        let parent=try SafeFS.openDirectory(destination.deletingLastPathComponent().path);defer {close(parent)}
        try SafeFS.destinationClear(destination.path)
        let fd=openat(parent,destination.lastPathComponent,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0o600);guard fd>=0 else {throw SafeFS.fail("Comparison export destination held")};defer {close(fd)}
        let handle=FileHandle(fileDescriptor:fd,closeOnDealloc:false);var count=0,bytes=0
        func write(_ fields:[String]) throws {
            let escaped=fields.map {$0.replacingOccurrences(of:"\\",with:"\\\\").replacingOccurrences(of:"\t",with:"\\t").replacingOccurrences(of:"\n",with:"\\n").replacingOccurrences(of:"\r",with:"\\r")}
            let data=Data((escaped.joined(separator:"\t")+"\n").utf8);bytes+=data.count
            guard bytes<1024*1024*1024 else {throw KonMagicError("Comparison export limit reached; partial private export retained.")}
            try handle.write(contentsOf:data)
        }
        try write(["path","observation_change","before_logical_bytes","after_logical_bytes"])
        try reader.rows("SELECT path,status,before,after FROM "+source+" ORDER BY path COLLATE BINARY") {s in
            try write([AtlasDatabase.string(s,0),AtlasDatabase.string(s,1),String(sqlite3_column_int64(s,2)),String(sqlite3_column_int64(s,3))]);count+=1
            if count%1000==0 {var fs=statfs();guard fstatfs(fd,&fs)==0,Int64(fs.f_bavail)*Int64(fs.f_bsize)>SafeFS.reserve else {throw KonMagicError("Comparison export reached the free-space reserve; partial export retained.")}}
        }
        guard fsync(fd)==0 else {throw SafeFS.fail("Comparison export could not be flushed")};return count
    }
    func export(to destination:URL,fields:[String],cancellation:CatalogueCancellation) throws {
        let allowed:Set<String>=["path","name","kind","logical","allocated","counted_logical","counted_allocated","files","modified","created","accessed","hard_links","cloud","package","issue"]
        guard !fields.isEmpty,fields.count<=allowed.count,fields.allSatisfy({allowed.contains($0)}) else {throw KonMagicError("Choose valid export fields.")}
        let info=try snapshot(),parent=try SafeFS.openDirectory(destination.deletingLastPathComponent().path);defer {close(parent)}
        try SafeFS.destinationClear(destination.path)
        let fd=openat(parent,destination.lastPathComponent,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0o600);guard fd>=0 else {throw SafeFS.fail("Export destination is held")};defer {close(fd)}
        let file=FileHandle(fileDescriptor:fd,closeOnDealloc:false)
        func row(_ values:[String]) throws {let data=Data((values.map {$0.replacingOccurrences(of:"\\",with:"\\\\").replacingOccurrences(of:"\t",with:"\\t").replacingOccurrences(of:"\n",with:"\\n").replacingOccurrences(of:"\r",with:"\\r")}.joined(separator:"\t")+"\n").utf8);try file.write(contentsOf:data)}
        try row(fields);let reader=try AtlasDatabase(url.path,seconds:6*3600,cancellation:cancellation);var count=0,bytes:Int64=0
        try reader.rows("SELECT "+Self.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent ORDER BY n.id") {s in
            let n=Self.node(s),values:[String:String]=["path":path(n,info),"name":n.name,"kind":n.kindName,"logical":String(n.bytes),"allocated":String(n.allocated),"counted_logical":String(n.total.bytes),"counted_allocated":String(n.total.allocated),"files":String(n.total.count),"modified":String(n.modified),"created":String(n.created),"accessed":String(n.accessed),"hard_links":String(n.links),"cloud":String(n.cloud),"package":String(n.package),"issue":n.error]
            try row(fields.map {values[$0] ?? ""});count+=1;bytes+=Int64(values.values.reduce(0) {$0+$1.utf8.count})
            if count%1000==0 {var fs=statfs();guard fstatfs(fd,&fs)==0,Int64(fs.f_bavail)*Int64(fs.f_bsize)>SafeFS.reserve,bytes<1024*1024*1024 else {throw KonMagicError("Export storage bound reached; partial private export retained.")}}
        };guard fsync(fd)==0 else {throw SafeFS.fail("Export could not be flushed")}
    }
}
