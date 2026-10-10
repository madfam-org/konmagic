import Foundation
import SQLite3
import Darwin

// These writes are restricted to a new, private derived snapshot. Atlas and source files stay read-only.
final class LensWriter {
    let url:URL,db:OpaquePointer
    var insert:OpaquePointer!,identity:OpaquePointer!,sum:OpaquePointer!
    var count:Int64=0
    let cancellation:CatalogueCancellation
    let transient=unsafeBitCast(-1,to:sqlite3_destructor_type.self)
    init(directory:URL,cancellation:CatalogueCancellation) throws {
        self.cancellation=cancellation
        let folder=try SafeFS.openDirectory(directory.path,create:true);defer {close(folder)}
        var st=stat();guard fstat(folder,&st)==0,st.st_uid==getuid(),st.st_mode & 0o077==0 else {throw KonMagicError("Disk snapshots need an owned, private folder.")}
        url=directory.appendingPathComponent(UUID().uuidString+".konmagic-scan")
        let fd=openat(folder,url.lastPathComponent,O_RDWR|O_CREAT|O_EXCL|O_NOFOLLOW,0o600);guard fd>=0 else {throw SafeFS.fail("Cannot create a private snapshot")};close(fd)
        var raw:OpaquePointer?
        guard sqlite3_open_v2(url.path,&raw,SQLITE_OPEN_READWRITE|SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_NOFOLLOW,nil)==SQLITE_OK,let raw=raw else {if let raw=raw {sqlite3_close(raw)};throw KonMagicError("Cannot open the private snapshot.")};db=raw
        // Status readers must not turn a brief shared lock into incomplete scan coverage.
        guard sqlite3_busy_timeout(db,5_000)==SQLITE_OK else {throw KonMagicError("Cannot configure the private snapshot lock bound.")}
        try exec("PRAGMA journal_mode=DELETE; PRAGMA synchronous=FULL; PRAGMA cache_size=-16384; PRAGMA temp_store=FILE; CREATE TABLE meta(key TEXT PRIMARY KEY,value TEXT); CREATE TABLE nodes(id INTEGER PRIMARY KEY,parent INTEGER NOT NULL,name TEXT NOT NULL,kind INTEGER NOT NULL,relative TEXT,bytes INTEGER,allocated INTEGER,modified INTEGER,created INTEGER,accessed INTEGER,device INTEGER,inode INTEGER,links INTEGER,flags INTEGER,package INTEGER,duplicate INTEGER,error TEXT,depth INTEGER,tb INTEGER,ta INTEGER,tc INTEGER); CREATE INDEX children ON nodes(parent); CREATE UNIQUE INDEX directory_paths ON nodes(relative) WHERE kind=1; CREATE TABLE identities(device INTEGER,inode INTEGER,PRIMARY KEY(device,inode)) WITHOUT ROWID; BEGIN IMMEDIATE")
        insert=try prepare("INSERT INTO nodes VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
        identity=try prepare("INSERT OR IGNORE INTO identities VALUES(?,?)")
        sum=try prepare("UPDATE nodes SET tb=tb+?,ta=ta+?,tc=tc+? WHERE id=?")
    }
    deinit {sqlite3_finalize(insert);sqlite3_finalize(identity);sqlite3_finalize(sum);sqlite3_close(db)}
    func prepare(_ sql:String) throws -> OpaquePointer {var s:OpaquePointer?;guard sqlite3_prepare_v2(db,sql,-1,&s,nil)==SQLITE_OK,let s=s else {throw KonMagicError("Private snapshot SQL failed: "+String(cString:sqlite3_errmsg(db)))};return s}
    func exec(_ sql:String) throws {guard sqlite3_exec(db,sql,nil,nil,nil)==SQLITE_OK else {throw KonMagicError("Private snapshot write failed: "+String(cString:sqlite3_errmsg(db)))}}
    func check() throws {
        guard !cancellation.cancelled else {throw KonMagicError("Scan paused by you; the partial snapshot is retained.")}
        guard count<25_000_000 else {throw KonMagicError("Snapshot entry limit reached; partial coverage is retained.")}
        var size:Int64=0;let s=try prepare("PRAGMA page_count");defer {sqlite3_finalize(s)};if sqlite3_step(s)==SQLITE_ROW {size=sqlite3_column_int64(s,0)*4096}
        var fs=statfs();guard statfs(url.deletingLastPathComponent().path,&fs)==0 else {throw SafeFS.fail("Cannot check snapshot capacity")}
        guard size<3*1024*1024*1024,Int64(fs.f_bavail)*Int64(fs.f_bsize)>SafeFS.reserve else {throw KonMagicError("Scan storage guard reached (3 GiB snapshot or 10 GiB free). Partial coverage is retained.")}
    }
    func append(_ input:LensNode,deduplicate:Bool=true) throws -> LensNode {
        var n=input;n.id=count+1
        if n.kind==0,deduplicate,n.inode != 0,(n.links != 1) {
            sqlite3_reset(identity);sqlite3_clear_bindings(identity);sqlite3_bind_int64(identity,1,n.device);sqlite3_bind_int64(identity,2,n.inode)
            guard sqlite3_step(identity)==SQLITE_DONE else {throw KonMagicError("Hard-link identity check failed.")};n.duplicate=sqlite3_changes(db)==0
        }
        n.total=n.ownTotal
        sqlite3_reset(insert);sqlite3_clear_bindings(insert)
        let numbers:[Int:Int64]=[1:n.id,2:n.parent,4:Int64(n.kind),6:n.bytes,7:n.allocated,8:n.modified,9:n.created,10:n.accessed,11:n.device,12:n.inode,13:n.links,14:Int64(n.flags),15:n.package ? 1:0,16:n.duplicate ? 1:0,18:Int64(n.depth),19:n.total.bytes,20:n.total.allocated,21:n.total.count]
        for (i,v) in numbers {sqlite3_bind_int64(insert,Int32(i),v)}
        sqlite3_bind_text(insert,3,n.name,-1,transient);if n.directory {sqlite3_bind_text(insert,5,n.relative,-1,transient)}
        sqlite3_bind_text(insert,17,n.error,-1,transient)
        guard sqlite3_step(insert)==SQLITE_DONE else {throw KonMagicError("Snapshot insertion failed: "+String(cString:sqlite3_errmsg(db)))}
        count+=1
        if count%1000==0 {try exec("COMMIT; BEGIN IMMEDIATE");try check()}
        return n
    }
    func issue(_ id:Int64,_ message:String) throws {
        let s=try prepare("UPDATE nodes SET error=? WHERE id=?");defer {sqlite3_finalize(s)}
        sqlite3_bind_text(s,1,String(message.prefix(1000)),-1,transient);sqlite3_bind_int64(s,2,id);guard sqlite3_step(s)==SQLITE_DONE else {throw KonMagicError("Could not retain a coverage exception.")}
    }
    func directory(relative:String) throws -> LensNode? {
        let s=try prepare("SELECT "+LensStore.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent WHERE n.kind=1 AND n.relative=? LIMIT 1");defer {sqlite3_finalize(s)}
        sqlite3_bind_text(s,1,relative,-1,transient)
        let status=sqlite3_step(s)
        if status==SQLITE_ROW {return LensStore.node(s)}
        guard status==SQLITE_DONE else {throw KonMagicError("Recorded root ancestry could not be reconciled.")}
        return nil
    }
    func finish(_ snapshot:LensSnapshot) throws -> LensSnapshot {
        try exec("COMMIT; BEGIN IMMEDIATE")
        // Parents precede their children. Reverse folding conserves totals without retaining all files in memory.
        let s=try prepare("SELECT id,parent,tb,ta,tc FROM nodes ORDER BY id DESC");defer {sqlite3_finalize(s)}
        var folded:Int64=0,status=sqlite3_step(s)
        while status==SQLITE_ROW {
            let parent=sqlite3_column_int64(s,1);if parent<=0 {status=sqlite3_step(s);continue}
            sqlite3_reset(sum);sqlite3_clear_bindings(sum)
            for i in 0..<3 {sqlite3_bind_int64(sum,Int32(i+1),sqlite3_column_int64(s,Int32(i+2)))};sqlite3_bind_int64(sum,4,parent)
            guard sqlite3_step(sum)==SQLITE_DONE else {throw KonMagicError("Snapshot totals could not be conserved.")};folded+=1
            if folded%100_000==0 {try exec("COMMIT; BEGIN IMMEDIATE")}
            status=sqlite3_step(s)
        }
        guard status==SQLITE_DONE else {throw KonMagicError("Snapshot aggregation was incomplete. Retained rows were not reported as a successful scan.")}
        var result=snapshot;result.entries=count;result.finished=Date()
        let totals=try prepare("SELECT tb,ta,tc FROM nodes WHERE id=1");defer {sqlite3_finalize(totals)}
        if sqlite3_step(totals)==SQLITE_ROW {result.totals=LensTotals(bytes:sqlite3_column_int64(totals,0),allocated:sqlite3_column_int64(totals,1),count:sqlite3_column_int64(totals,2))}
        let data=try JSONEncoder().encode(result),value=String(data:data,encoding:.utf8)!
        let m=try prepare("INSERT OR REPLACE INTO meta VALUES('snapshot',?)");defer {sqlite3_finalize(m)};sqlite3_bind_text(m,1,value,-1,transient)
        guard sqlite3_step(m)==SQLITE_DONE else {throw KonMagicError("Snapshot receipt could not be saved.")}
        try exec("COMMIT; PRAGMA optimize");return result
    }
}

struct LensStore {
    let url:URL
    static let columns="n.id,n.parent,n.name,n.kind,coalesce(n.relative,CASE WHEN p.relative='' THEN n.name ELSE p.relative||'/'||n.name END),n.bytes,n.allocated,n.modified,n.created,n.accessed,n.device,n.inode,n.links,n.flags,n.package,n.duplicate,n.error,n.depth,n.tb,n.ta,n.tc"
    static func node(_ s:OpaquePointer)->LensNode {
        var n=LensNode();n.id=sqlite3_column_int64(s,0);n.parent=sqlite3_column_int64(s,1);n.name=AtlasDatabase.string(s,2);n.kind=Int(sqlite3_column_int(s,3));n.relative=AtlasDatabase.string(s,4)
        n.bytes=sqlite3_column_int64(s,5);n.allocated=sqlite3_column_int64(s,6);n.modified=sqlite3_column_int64(s,7);n.created=sqlite3_column_int64(s,8);n.accessed=sqlite3_column_int64(s,9);n.device=sqlite3_column_int64(s,10);n.inode=sqlite3_column_int64(s,11);n.links=sqlite3_column_int64(s,12);n.flags=UInt32(truncatingIfNeeded:sqlite3_column_int64(s,13));n.package=sqlite3_column_int(s,14) != 0;n.duplicate=sqlite3_column_int(s,15) != 0;n.error=AtlasDatabase.string(s,16);n.depth=Int(sqlite3_column_int(s,17));n.total=LensTotals(bytes:sqlite3_column_int64(s,18),allocated:sqlite3_column_int64(s,19),count:sqlite3_column_int64(s,20));return n
    }
    func snapshot() throws -> LensSnapshot {
        let reader=try AtlasDatabase(url.path);var info:LensSnapshot?
        try reader.rows("SELECT value FROM meta WHERE key='snapshot'") {s in info=try JSONDecoder().decode(LensSnapshot.self,from:Data(AtlasDatabase.string(s,0).utf8))}
        guard let info=info,info.version==1,info.root.hasPrefix("/"),info.entries<=25_000_000 else {throw KonMagicError("Not a supported KonMagic scan.")};return info
    }
    func nodes(where predicate:String="n.parent=?",values:[String],order:String="n.ta DESC,n.name COLLATE NOCASE,n.id",limit:Int=5000,offset:Int=0) throws -> [LensNode] {
        let reader=try AtlasDatabase(url.path,seconds:20);var nodes:[LensNode]=[]
        try reader.rows("SELECT "+Self.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent WHERE "+predicate+" ORDER BY "+order+" LIMIT ? OFFSET ?",values+[String(min(5000,max(1,limit))),String(min(25_000_000,max(0,offset)))]) {s in nodes.append(Self.node(s))};return nodes
    }
    func node(_ id:Int64) throws -> LensNode? {try nodes(where:"n.id=?",values:[String(id)],limit:1).first}
    func path(_ node:LensNode,_ info:LensSnapshot)->String {node.relative.isEmpty ? info.root : (info.root=="/" ? "/" : info.root+"/")+node.relative}
    func comments(_ value:String,directory:URL) throws -> URL {
        // Save comments as a new snapshot instead of altering a previously saved observation.
        let destination=directory.appendingPathComponent(UUID().uuidString+".konmagic-scan")
        try copy(to:destination)
        var info=try snapshot();info.comments=String(value.prefix(20_000))
        var db:OpaquePointer?;guard sqlite3_open_v2(destination.path,&db,SQLITE_OPEN_READWRITE|SQLITE_OPEN_NOFOLLOW,nil)==SQLITE_OK,let db=db else {throw KonMagicError("Cannot save scan notes.")};defer {sqlite3_close(db)}
        var s:OpaquePointer?;guard sqlite3_prepare_v2(db,"UPDATE meta SET value=? WHERE key='snapshot'",-1,&s,nil)==SQLITE_OK,let s=s else {throw KonMagicError("Cannot save scan notes.")};defer {sqlite3_finalize(s)}
        let value=String(data:try JSONEncoder().encode(info),encoding:.utf8)!;sqlite3_bind_text(s,1,value,-1,unsafeBitCast(-1,to:sqlite3_destructor_type.self));guard sqlite3_step(s)==SQLITE_DONE else {throw KonMagicError("Cannot save scan notes.")};return destination
    }
    func copy(to destination:URL) throws {
        try SafeFS.destinationClear(destination.path)
        let source=try SafeFS.openDirectory(url.deletingLastPathComponent().path);defer {close(source)}
        let target=try SafeFS.openDirectory(destination.deletingLastPathComponent().path);defer {close(target)}
        let input=openat(source,url.lastPathComponent,O_RDONLY|O_NOFOLLOW),output=openat(target,destination.lastPathComponent,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0o600)
        guard input>=0,output>=0 else {if input>=0 {close(input)};if output>=0 {close(output)};throw SafeFS.fail("Snapshot save refused")};defer {close(input);close(output)}
        var st=stat();guard fstat(input,&st)==0,SafeFS.isFile(st),st.st_size<=3*1024*1024*1024 else {throw KonMagicError("Saved scan exceeds its bound.")}
        var fs=statfs();guard fstatfs(output,&fs)==0,Int64(fs.f_bavail)*Int64(fs.f_bsize)>st.st_size+SafeFS.reserve else {throw KonMagicError("Insufficient room for another retained scan.")}
        guard fcopyfile(input,output,nil,copyfile_flags_t(COPYFILE_DATA))==0,fsync(output)==0 else {throw SafeFS.fail("Snapshot copy incomplete")}
    }
}
