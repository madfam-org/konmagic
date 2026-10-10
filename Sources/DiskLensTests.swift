import AppKit
import SQLite3
import Darwin

func runLensTests(at temp:URL) throws -> Int {
    var checks=0
    func check(_ result:Bool,_ text:String) throws {guard result else {throw KonMagicError("Disk Lens test failed: "+text)};checks+=1}
    func refuses(_ text:String,_ body:()throws->Void) throws {do {try body()} catch {checks+=1;return};throw KonMagicError("Disk Lens failed to refuse "+text)}
    let base=temp.appendingPathComponent("lens-source"),saved=temp.appendingPathComponent("lens-private")
    try FileManager.default.createDirectory(at:base,withIntermediateDirectories:true);try FileManager.default.createDirectory(at:saved,withIntermediateDirectories:true,attributes:[.posixPermissions:0o700])
    func write(_ path:URL,_ text:String) throws {try Data(text.utf8).write(to:path)}
    let folder=base.appendingPathComponent("Documents"),package=base.appendingPathComponent("Tool.app")
    try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true);try FileManager.default.createDirectory(at:package,withIntermediateDirectories:true)
    try write(folder.appendingPathComponent("note.txt"),"Synthetic note")
    try write(package.appendingPathComponent("binary"),"Synthetic program fixture")
    let first=base.appendingPathComponent("first.txt"),second=base.appendingPathComponent("second.txt")
    try write(first,"Synthetic shared bytes");guard link(first.path,second.path)==0 else {throw SafeFS.fail("Synthetic hard link failed")}
    let linked=base.appendingPathComponent("linked");guard symlink(folder.path,linked.path)==0 else {throw SafeFS.fail("Synthetic symlink failed")}
    let sparse=base.appendingPathComponent("sparse.dat"),fd=open(sparse.path,O_RDWR|O_CREAT|O_EXCL,0o600)
    guard fd>=0,ftruncate(fd,1_048_576)==0 else {throw SafeFS.fail("Sparse metadata fixture failed")};close(fd)
    let before=try Data(contentsOf:first),scanner=try LensScanner(directory:saved,cancellation:CatalogueCancellation())
    let store=try scanner.run(root:base.path),info=try store.snapshot()
    try check(info.status=="complete", "live scan completes")
    try check(info.entries==9 && info.totals.count==4,"one root, folders and link included; unique files counted")
    try check(info.duplicates==1,"hard links counted once")
    try check(info.totals.bytes==Int64(before.count+"Synthetic note".utf8.count+"Synthetic program fixture".utf8.count+1_048_576),"logical sizes reconcile")
    try check(info.totals.allocated<info.totals.bytes,"sparse physical allocation differs from logical size")
    try check(try Data(contentsOf:first)==before,"metadata scan retains source bytes")
    let descendants=try store.nodes(where:"n.id>0",values:[],order:"n.id",limit:100)
    try check(descendants.filter(\.package).count==1 && descendants.filter {$0.kind==2}.count==1,"package and symlink metadata retained")
    try check(descendants.filter {$0.name=="linked"}.first?.total.count==0,"symlinks are not followed")
    try check(descendants.filter {$0.name=="first.txt" || $0.name=="second.txt"}.allSatisfy {$0.links==2},"hard-link status available to filtering")
    try check(descendants.filter {$0.kind==0}.allSatisfy {$0.created>0 && $0.modified>0 && $0.accessed>0},"live scan captures all three dates")
    let note=descendants.first {$0.name=="note.txt"}!
    var filter=LensFilter(name:"Text",rules:[LensRule(field:.extensionName,operation:.equals,value:"txt",negated:false)],matchAll:true)
    try check(filter.matches(note,path:store.path(note,info)),"extension predicate")
    filter.rules.append(LensRule(field:.logical,operation:.maximum,value:"100",negated:false))
    try check(filter.matches(note,path:store.path(note,info)),"AND bounds")
    filter.rules[0].negated=true
    try check(!filter.matches(note,path:store.path(note,info)),"negated predicate")
    filter.matchAll=false
    try check(filter.matches(note,path:store.path(note,info)),"ANY predicate")
    let grouped=LensFilter(groups:[LensTestGroup(name:"Small text",rules:[LensRule(field:.extensionName,operation:.equals,value:"txt"),LensRule(field:.logical,operation:.maximum,value:"100")]),LensTestGroup(name:"Data",rules:[LensRule(field:.extensionName,operation:.equals,value:"dat")])])
    try grouped.validate();try check(grouped.matches(note,path:store.path(note,info)),"OR of AND compound groups")
    let folderExcluded=LensFilter(groups:[LensTestGroup(name:"Private subtree",rules:[LensRule(field:.name,operation:.equals,value:"Documents")],negated:true,scope:"folders")])
    try folderExcluded.validate();try check(!folderExcluded.matches(note,path:store.path(note,info)),"folder-scoped group excludes descendants")
    let typed=LensFilter(rules:[LensRule(field:.type,operation:.conforms,value:"public.text")])
    try typed.validate();try check(typed.matches(note,path:store.path(note,info)),"system file type conformance")
    let compatibility=try JSONDecoder().decode(LensFilter.self,from:Data("{\"name\":\"Old filter\",\"rules\":[],\"matchAll\":true}".utf8))
    try check(compatibility.groups.isEmpty && compatibility.matches(note,path:store.path(note,info)),"old saved filter remains readable")
    try refuses("invalid numeric filter") {try LensFilter(name:"Bad",rules:[LensRule(field:.logical,operation:.contains,value:"word",negated:false)]).validate()}
    try refuses("invalid boolean filter") {try LensFilter(name:"Bad",rules:[LensRule(field:.cloud,operation:.equals,value:"true",negated:false)]).validate()}
    filter=LensFilter(name:"Only notes",rules:[LensRule(field:.name,operation:.equals,value:"note.txt",negated:false)])
    let filtered=try LensScanner.filter(store,using:filter,directory:saved,cancellation:CatalogueCancellation())
    try check(try filtered.snapshot().totals.count==1 && filtered.snapshot().totals.bytes==note.bytes,"separate filter conserves selected bytes")
    try check(try store.snapshot().totals==info.totals,"filter leaves saved snapshot unchanged")
    let scoped=try LensScanner(directory:saved,cancellation:CatalogueCancellation()).run(root:base.path,exclude:LensFilter(name:"Skip app",rules:[LensRule(field:.package,operation:.isTrue,value:"",negated:false)]))
    try check(try scoped.snapshot().excluded==1 && scoped.snapshot().totals.count==3,"scan exclusion skips entire package subtree")
    let root=try store.node(1)!,bounds=NSRect(x:0,y:0,width:1000,height:700)
    var preferences=LensPreferences();preferences.measure = .logical;preferences.display = .files;preferences.depth=999
    let map=try LensMapBuilder(store:store,info:info,preferences:preferences,mask:filter,cancellation:CatalogueCancellation()).build(focus:root,bounds:bounds)
    try check(map.tiles.filter {!$0.virtual}.reduce(Int64(0)) {$0+$1.node.total.bytes}==info.totals.bytes,"hierarchical file map conserves full logical bytes")
    try check(map.tiles.contains {$0.masked},"mask marks areas without removing or reweighting")
    preferences.display = .packages
    let packages=try LensMapBuilder(store:store,info:info,preferences:preferences,mask:LensFilter(),cancellation:CatalogueCancellation()).build(focus:root,bounds:bounds)
    try check(packages.tiles.contains {$0.node.package},"package view collapses package")
    try check(packages.tiles.reduce(Int64(0)) {$0+$1.node.total.bytes}==info.totals.bytes,"package map conserves totals")
    let rects=LensMapBuilder.rectangles([1,3,0],rect:NSRect(x:0,y:0,width:100,height:100))
    try check(abs(rects[0].width*rects[0].height-2500)<0.01 && abs(rects[1].width*rects[1].height-7500)<0.01 && rects[2].width*rects[2].height==0,"rectangle area is proportional with true zero area")
    let exported=saved.appendingPathComponent("scan.tsv");try store.export(to:exported,fields:["path","logical","allocated","issue"],cancellation:CatalogueCancellation())
    try check(String(data:try Data(contentsOf:exported),encoding:.utf8)!.split(separator:"\n").count==10,"export contains every retained record")
    try refuses("export overwrite") {try store.export(to:exported,fields:["name"],cancellation:CatalogueCancellation())}
    let copy=saved.appendingPathComponent("saved.konmagic-scan");try store.copy(to:copy)
    try check(try LensStore(url:copy).snapshot().totals==info.totals,"save/reload conserves full scan")
    try refuses("scan overwrite") {try store.copy(to:copy)}
    let db=try AtlasDatabase(store.url.path)
    try refuses("read-only snapshot modification") {try db.rows("DELETE FROM nodes") {_ in}}
    try write(folder.appendingPathComponent("note.txt"),"A changed synthetic note")
    try write(folder.appendingPathComponent("added.txt"),"Added synthetic note")
    let updated=try LensScanner(directory:saved,cancellation:CatalogueCancellation()).run(root:base.path,previous:store,changes:[folder.path])
    let differences=try updated.compare(store,cancellation:CatalogueCancellation())
    try check(differences.contains {$0.path=="Documents/added.txt" && $0.status=="Added"},"comparison detects added file")
    try check(differences.contains {$0.path=="Documents/note.txt" && $0.status=="Changed"},"comparison detects changed metadata")
    try check(try updated.snapshot().totals.count==5,"incremental refresh conserves unchanged and new subtrees")
    let cancelled=CatalogueCancellation();cancelled.cancel()
    let partial=try LensScanner(directory:saved,cancellation:cancelled).run(root:base.path)
    try check(try partial.snapshot().status=="partial","cancelled scan retains explicit partial coverage")
    try check(try Data(contentsOf:first)==before,"all analysis actions leave source bytes intact")

    let pages=try LensWriter(directory:saved,cancellation:CatalogueCancellation())
    var parent=LensNode();parent.name="Synthetic root";parent.kind=1;parent=try pages.append(parent)
    for i in 0..<205 {var n=LensNode();n.parent=parent.id;n.name=String(format:"fixture-%03d.dat",i);n.bytes=Int64(i);n.allocated=Int64(i);n.links=1;_ = try pages.append(n)}
    var pageInfo=LensSnapshot();pageInfo.root="/synthetic";pageInfo.source="Synthetic metadata";pageInfo.status="complete";_ = try pages.finish(pageInfo)
    let pageStore=LensStore(url:pages.url),page1=try pageStore.nodes(values:["1"],limit:200),page2=try pageStore.nodes(values:["1"],limit:200,offset:200)
    try check(page1.count==200 && page2.count==5 && Set(page1.map(\.id)).isDisjoint(with:Set(page2.map(\.id))),"disk list pages reach every row exactly once")

    let ledger=saved.appendingPathComponent("synthetic-ledger.sqlite3")
    var raw:OpaquePointer?;guard sqlite3_open(ledger.path,&raw)==SQLITE_OK,let raw=raw else {throw KonMagicError("Synthetic ledger failed")};defer {sqlite3_close(raw)}
    func sql(_ text:String) throws {guard sqlite3_exec(raw,text,nil,nil,nil)==SQLITE_OK else {throw KonMagicError("Synthetic ledger SQL failed")}}
    func hex(_ data:Data)->String {"X'"+data.map {String(format:"%02x",$0)}.joined()+"'"}
    func key(_ path:String) throws -> String {try hex(AtlasDatabase.pack(Data(path.utf8)))}
    func block(_ rows:[[Any]]) throws -> String {try hex(AtlasDatabase.pack(JSONSerialization.data(withJSONObject:rows)))}
    try sql("CREATE TABLE aliases(path BLOB PRIMARY KEY,canonical BLOB); CREATE TABLE directories(path BLOB PRIMARY KEY,metadata TEXT); CREATE TABLE blocks(path BLOB,part INTEGER,entries BLOB)")
    try sql("INSERT INTO directories VALUES(\(try key("/synthetic")),'{}'),(\(try key("/synthetic/A")),'{}')")
    let entries:[[Any]]=[["A","directory",0,0,0,1,10,0],["Alias","directory",0,0,0,1,10,0],["first.dat","file",10,4096,0,1,20,0],["second.dat","file",10,4096,0,1,20,0],["cloud.dat","file",90,0,0,1,30,1073741824]]
    try sql("INSERT INTO blocks VALUES(\(try key("/synthetic")),0,\(try block(entries))),(\(try key("/synthetic/A")),0,\(try block([["child.dat","file",20,4096,0,1,40,0]])))")
    try sql("INSERT INTO aliases VALUES(\(try key("/synthetic/Alias")),\(try key("/synthetic/A")))")
    let ledgerBytes=try Data(contentsOf:ledger),recorded=try LensScanner(directory:saved,cancellation:CatalogueCancellation()).recorded(root:"/synthetic",ledger:ledger.path),recordedInfo=try recorded.snapshot()
    try check(recordedInfo.totals==LensTotals(bytes:120,allocated:8192,count:3),"native ledger import counts cloud metadata and hard links correctly")
    try check(recordedInfo.status=="complete_with_exceptions" && recordedInfo.issues==1,"repeated directory alias remains explicit")
    try check(recordedInfo.cloud==1 && !recordedInfo.datesKnown && !recordedInfo.linksKnown,"unknown dates/link count and cloud status are preserved")
    try check(try Data(contentsOf:ledger)==ledgerBytes,"native import leaves the retained database byte-identical")
    try sql("CREATE TABLE roots(path TEXT); INSERT INTO roots VALUES('/synthetic')")
    let machine=try LensScanner(directory:saved,cancellation:CatalogueCancellation()).recorded(root:"/",ledger:ledger.path)
    try check(try machine.snapshot().totals==recordedInfo.totals && machine.snapshot().entries==recordedInfo.entries+1,"virtual machine root conserves all recorded roots")
    return checks
}
