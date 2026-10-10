import Foundation
import Darwin
import SQLite3

final class LensScanner {
    let writer:LensWriter,cancellation:CatalogueCancellation
    var info=LensSnapshot()
    var progress:((Int64,Int64)->Void)?
    var visited:Set<String>=[],lastProgress=Date.distantPast
    var exclusion=LensFilter()
    init(directory:URL,cancellation:CatalogueCancellation) throws {self.cancellation=cancellation;writer=try LensWriter(directory:directory,cancellation:cancellation)}
    func pulse() throws {if Date().timeIntervalSince(lastProgress)>0.5 {lastProgress=Date();progress?(writer.count,info.issues);try writer.check()}}
    func run(root:String,filter:LensFilter=LensFilter(),exclude:LensFilter=LensFilter(),previous:LensStore?=nil,changes:Set<String>?=nil) throws -> LensStore {
        try filter.validate();try exclude.validate();info.root=root;info.source=previous != nil && changes != nil ? "Live metadata · incremental refresh" : "Live metadata · full rescan";info.filter=filter;info.exclusions=exclude;exclusion=exclude
        do {
            let baseline=try? previous?.snapshot()
            let reusable=baseline?.root==root && baseline?.filter==filter && (baseline?.exclusions ?? LensFilter())==exclude && baseline?.status != "partial"
            info.source=reusable && changes != nil ? "Live metadata · incremental refresh" : "Live metadata · full rescan"
            let fd=try SafeFS.openDirectory(root);defer {close(fd)};var st=stat();guard fstat(fd,&st)==0 else {throw SafeFS.fail("Cannot inspect scan root")}
            var fs=statfs();if fstatfs(fd,&fs)==0 {info.capacity=Int64(fs.f_blocks)*Int64(fs.f_bsize);info.free=Int64(fs.f_bavail)*Int64(fs.f_bsize)}
            var node=LensNode.metadata(st,name:URL(fileURLWithPath:root).lastPathComponent,parent:0,relative:"",depth:0);node.kind=1
            node=try writer.append(node);try liveChildren(fd:fd,path:root,parent:node,previous:reusable ? previous:nil,changes:reusable ? changes:nil)
            info.status=info.issues==0 ? "complete" : "complete_with_exceptions"
        } catch {info.status="partial";info.issues+=1;if writer.count>0 {try? writer.issue(1,error.localizedDescription)} else {throw error}}
        info=try writer.finish(info);return LensStore(url:writer.url)
    }
    private func liveChildren(fd:Int32,path:String,parent:LensNode,previous:LensStore?,changes:Set<String>?) throws {
        var before=stat();guard fstat(fd,&before)==0 else {throw SafeFS.fail("Cannot recheck folder metadata")}
        try pulse();guard parent.depth<256 else {info.issues+=1;try writer.issue(parent.id,"Depth limit held; descendants were not scanned.");return}
        if path==writer.url.deletingLastPathComponent().path {info.issues+=1;try writer.issue(parent.id,"The active private scan store is excluded to prevent self-ingestion.");return}
        let key=String(parent.device)+":"+String(parent.inode)
        guard visited.insert(key).inserted else {info.issues+=1;try writer.issue(parent.id,"Repeated directory identity held; totals are counted once.");return}
        if let previous=previous,let changes=changes,!changes.contains(where:{$0==path || $0.hasPrefix(path=="/" ? "/" : path+"/")}) {
            let old=try previous.nodes(where:"n.kind=1 AND n.relative=?",values:[parent.relative],limit:1).first
            if let old=old {try cachedChildren(previous,parent:parent,old:old);return}
        }
        let copy=openat(fd,".",O_RDONLY|O_DIRECTORY|O_NOFOLLOW)
        guard copy>=0,let dir=fdopendir(copy) else {if copy>=0 {close(copy)};info.issues+=1;try writer.issue(parent.id,"Folder enumeration denied.");return};defer {closedir(dir)}
        errno=0
        while let entry=readdir(dir) {
            let name=withUnsafePointer(to:&entry.pointee.d_name) {$0.withMemoryRebound(to:CChar.self,capacity:Int(MAXNAMLEN)+1) {String(cString:$0)}}
            if name=="." || name==".." {continue}
            let full=(path=="/" ? "/" : path+"/")+name,relative=parent.relative.isEmpty ? name : parent.relative+"/"+name
            var st=stat()
            guard fstatat(fd,name,&st,AT_SYMLINK_NOFOLLOW)==0 else {info.issues+=1;try writer.issue(parent.id,"An entry became inaccessible during scan; coverage is incomplete.");errno=0;continue}
            var node=LensNode.metadata(st,name:name,parent:parent.id,relative:relative,depth:parent.depth+1)
            if (!exclusion.rules.isEmpty || !exclusion.groups.isEmpty) && exclusion.matches(node,path:full) {info.excluded+=1;errno=0;continue}
            if !node.directory && !info.filter.matches(node,path:full) {info.excluded+=1;errno=0;continue}
            node=try writer.append(node);if node.cloud {info.cloud+=1};if node.duplicate {info.duplicates+=1}
            if node.directory {
                if node.cloud {info.issues+=1;try writer.issue(node.id,"Cloud directory held; no hydration.")}
                else {
                    let child=openat(fd,name,O_RDONLY|O_DIRECTORY|O_NOFOLLOW)
                    if child<0 {info.issues+=1;try writer.issue(node.id,"Folder access denied or changed during scan.")}
                    else {defer {close(child)};var identity=stat();if fstat(child,&identity)==0,identity.st_dev==st.st_dev,identity.st_ino==st.st_ino {try liveChildren(fd:child,path:full,parent:node,previous:previous,changes:changes)} else {info.issues+=1;try writer.issue(node.id,"Directory changed before enumeration.")}}
                }
            }
            try pulse();errno=0
        }
        if errno != 0 {info.issues+=1;try writer.issue(parent.id,"Directory enumeration ended with an error.")}
        var after=stat();if fstat(fd,&after)==0,(before.st_mtimespec.tv_sec != after.st_mtimespec.tv_sec || before.st_mtimespec.tv_nsec != after.st_mtimespec.tv_nsec) {info.issues+=1;try writer.issue(parent.id,"Directory changed during scan; refresh to reconcile.")}
    }
    private func cachedChildren(_ store:LensStore,parent:LensNode,old:LensNode) throws {
        let reader=try AtlasDatabase(store.url.path,seconds:3600,cancellation:cancellation)
        func visit(_ parent:LensNode,_ old:LensNode) throws {
            try reader.rows("SELECT "+LensStore.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent WHERE n.parent=? ORDER BY n.id",[String(old.id)]) {s in
                let source=LensStore.node(s);var node=source;node.parent=parent.id;node.depth=parent.depth+1
                node=try writer.append(node);if node.cloud {info.cloud+=1};if node.duplicate {info.duplicates+=1};if !node.error.isEmpty {info.issues+=1}
                if node.directory {try visit(node,source)};try pulse()
            }
        };try visit(parent,old)
    }
    func recorded(root:String,ledger:String) throws -> LensStore {
        info.root=root;info.source="Atlas whole-disk metadata · retained observation";info.datesKnown=false;info.linksKnown=false
        let reader=try AtlasDatabase(ledger,seconds:6*3600,cancellation:cancellation)
        var rootNode=LensNode();rootNode.name=URL(fileURLWithPath:root).lastPathComponent;rootNode.kind=1;rootNode=try writer.append(rootNode)
        var seen:Set<String>=[]
        func visit(path:String,parent:LensNode) throws {
            try pulse();guard parent.depth<256 else {info.issues+=1;try writer.issue(parent.id,"Depth limit held.");return}
            var lookup=path,key=try AtlasDatabase.pack(Data(path.utf8))
            try reader.blobRows("SELECT canonical FROM aliases WHERE path=?",key:key) {s in
                if let d=AtlasDatabase.blob(s,0,limit:65536),let p=String(data:try AtlasDatabase.unpack(d,limit:65536),encoding:.utf8) {lookup=p;key=try AtlasDatabase.pack(Data(p.utf8))}
            }
            guard seen.insert(lookup).inserted else {info.issues+=1;try writer.issue(parent.id,"Alias of already counted directory; descendants are represented at the canonical location.");return}
            var found=false
            try reader.blobRows("SELECT metadata FROM directories WHERE path=?",key:key) {s in found=true}
            guard found else {info.issues+=1;try writer.issue(parent.id,"Retained directory was not scanned. See Atlas coverage exceptions.");return}
            try reader.blobRows("SELECT entries FROM blocks WHERE path=? ORDER BY part",key:key) {s in
                guard let data=AtlasDatabase.blob(s,0,limit:8*1024*1024),let rows=try JSONSerialization.jsonObject(with:AtlasDatabase.unpack(data,limit:8*1024*1024)) as? [[Any]] else {throw KonMagicError("Invalid retained metadata block.")}
                for r in rows {
                    guard r.count==8,let name=r[0] as? String,let kind=r[1] as? String,!name.contains("/"),name != ".",name != ".." else {throw KonMagicError("Invalid retained metadata entry.")}
                    var n=LensNode();n.name=name;n.kind=kind=="directory" ? 1 : kind=="file" ? 0 : kind=="link" ? 2 : 3;n.parent=parent.id;n.relative=parent.relative.isEmpty ? name : parent.relative+"/"+name;n.depth=parent.depth+1
                    n.bytes=(r[2] as? NSNumber)?.int64Value ?? 0;n.allocated=(r[3] as? NSNumber)?.int64Value ?? 0;n.modified=((r[4] as? NSNumber)?.int64Value ?? 0)/1_000_000_000;n.device=(r[5] as? NSNumber)?.int64Value ?? 0;n.inode=(r[6] as? NSNumber)?.int64Value ?? 0;n.flags=(r[7] as? NSNumber)?.uint32Value ?? 0;n.package=n.directory && LensNode.packageName(name)
                    n=try writer.append(n);if n.cloud {info.cloud+=1};if n.duplicate {info.duplicates+=1}
                    if n.directory {try visit(path:(lookup=="/" ? "/" : lookup+"/")+name,parent:n)};try pulse()
                }
            }
        }
        do {
            if root=="/" {
                var roots:[String]=[];try reader.rows("SELECT path FROM roots ORDER BY length(path),path") {s in roots.append(AtlasDatabase.string(s,0))}
                var indexed:[String:LensNode]=["/":rootNode]
                for path in roots {
                    if seen.contains(path) {continue}
                    var parent=rootNode,current=""
                    for component in try SafeFS.components(path) {
                        current+="/"+component
                        if let stored=indexed[current] {parent=stored}
                        else {var n=LensNode();n.name=component;n.kind=1;n.relative=String(current.dropFirst());n.parent=parent.id;n.depth=parent.depth+1;parent=try writer.append(n);indexed[current]=parent}
                    }
                    try visit(path:path,parent:parent)
                }
            } else {try visit(path:root,parent:rootNode)}
            info.status=info.issues==0 ? "complete" : "complete_with_exceptions"
        } catch {info.status="partial";info.issues+=1;try? writer.issue(1,error.localizedDescription)}
        info=try writer.finish(info);return LensStore(url:writer.url)
    }
    static func filter(_ original:LensStore,using filter:LensFilter,directory:URL,cancellation:CatalogueCancellation) throws -> LensStore {
        try filter.validate();let originalInfo=try original.snapshot(),scanner=try LensScanner(directory:directory,cancellation:cancellation)
        scanner.info=originalInfo;scanner.info.id=UUID().uuidString;scanner.info.started=Date();scanner.info.source="Filtered retained scan";scanner.info.filter=filter;scanner.info.status="complete";scanner.info.excluded=0
        let reader=try AtlasDatabase(original.url.path,seconds:6*3600,cancellation:cancellation);var parents:[Int64:Int64]=[:]
        do {try reader.rows("SELECT "+LensStore.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent ORDER BY n.id") {s in
            var node=LensStore.node(s);let oldID=node.id
            guard node.directory || filter.matches(node,path:original.path(node,originalInfo)) else {scanner.info.excluded+=1;return}
            node.parent=parents[node.parent] ?? 0;node.duplicate=false;node=try scanner.writer.append(node)
            if node.directory {parents[oldID]=node.id};try scanner.pulse()
        }} catch {scanner.info.status="partial";scanner.info.issues+=1;try? scanner.writer.issue(1,error.localizedDescription)}
        scanner.info=try scanner.writer.finish(scanner.info);return LensStore(url:scanner.writer.url)
    }
}
