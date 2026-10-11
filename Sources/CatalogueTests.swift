import Foundation
import SQLite3

func runCatalogueTests(at directory:URL) throws -> Int {
    var checks=0
    func check(_ value:Bool,_ message:String)throws {guard value else{throw KonMagicError(message)};checks+=1}
    func refuses(_ message:String,_ body:()throws->Void)throws {do {try body()} catch {checks+=1;return};throw KonMagicError("Expected catalogue refusal: "+message)}
    let file=directory.appendingPathComponent("synthetic-catalogue.sqlite3"),diskFile=directory.appendingPathComponent("synthetic-disk.sqlite3")
    var connection:OpaquePointer?
    guard sqlite3_open(file.path,&connection)==SQLITE_OK,let db=connection else {throw KonMagicError("Synthetic catalogue could not be created.")}
    defer {sqlite3_close(db)}
    func execute(_ sql:String)throws {guard sqlite3_exec(db,sql,nil,nil,nil)==SQLITE_OK else {throw KonMagicError("Synthetic fixture SQL: "+String(cString:sqlite3_errmsg(db)))}}
    try execute("CREATE TABLE roots(path TEXT,label TEXT,purpose TEXT); INSERT INTO roots VALUES('/synthetic','Synthetic','source'); CREATE TABLE items(id INTEGER PRIMARY KEY,path TEXT UNIQUE,name TEXT,kind TEXT,size INTEGER,tags TEXT,state TEXT,barrier TEXT,confidence REAL,evidence TEXT,reason TEXT,mtime_ns INTEGER,seen TEXT,manual INTEGER,extension TEXT,parent_path TEXT,shared_text_id INTEGER,hash TEXT,text BLOB); CREATE INDEX parent_items ON items(parent_path,path); CREATE VIRTUAL TABLE content_index USING fts5(item_id UNINDEXED,body);")
    let visual:[String:Any]=["name":"shape","confidence":0.8]
    let tagValues:[String:Any]=["owner":"Organization","project":"Active project","family":"Documents","role":"Research","lifecycle":"Active","visual_labels":[visual]]
    let tags=try JSONSerialization.data(withJSONObject:tagValues)
    let hash=String(repeating:"a",count:64),body="Synthetic fabrication research. Never read a real source body."
    let packed=try AtlasDatabase.pack(Data(body.utf8))
    for i in 1...207 {
        let name=String(format:"file-%03d.txt",i),path="/synthetic/"+name
        var raw:OpaquePointer?
        let sql="INSERT INTO items VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        guard sqlite3_prepare_v2(db,sql,-1,&raw,nil)==SQLITE_OK,let statement=raw else {throw KonMagicError("Synthetic insertion failed.")}
        let transient=unsafeBitCast(-1,to:sqlite3_destructor_type.self)
        let values=[String(i),path,name,"file","100",String(data:tags,encoding:.utf8)!,i<=2 ? (i==1 ? "extracted" : "partial") : "metadata_only",i==3 ? "credentials" : "","0.75","[\"Synthetic evidence\"]","","1700000000000000000","Synthetic snapshot","0",".txt","/synthetic",i==2 ? "1" : "0",hash]
        for (n,value) in values.enumerated() {sqlite3_bind_text(statement,Int32(n+1),value,-1,transient)}
        if i==1 {_ = packed.withUnsafeBytes {sqlite3_bind_blob(statement,19,$0.baseAddress,Int32(packed.count),transient)}} else {sqlite3_bind_text(statement,19,"",-1,transient)}
        guard sqlite3_step(statement)==SQLITE_DONE else {sqlite3_finalize(statement);throw KonMagicError("Synthetic insertion refused.")};sqlite3_finalize(statement)
    }
    try execute("INSERT INTO content_index VALUES(1,'Synthetic fabrication research');")
    let catalogue=Catalog(path:file.path)
    var slice=CatalogueSlice();let first=try catalogue.cataloguePage(slice);slice.cursor=first.next;let second=try catalogue.cataloguePage(slice)
    try check(first.items.count==200 && second.items.count==7 && Set(first.items.map(\.path)).isDisjoint(with:second.items.map(\.path)),"Keyset pages must cover all observations without omissions or duplicates")
    let summary=try catalogue.summary()
    try check(summary.count==207 && summary.readings==2 && summary.bytes==20700,"Aggregate totals must conserve every catalogue observation, including protected metadata")
    try check(summary.groups(.owner).reduce(0) {$0+$1.count}==summary.count,"Facet counts are a complete partition")
    try check(first.items[0].tags["owner"]=="Organization" && first.items[0].visualLabels.count==1 && !first.items[0].evidence.isEmpty,"Tags, broad visual labels and provenance survive native decoding")
    slice=CatalogueSlice();slice.contentSearch=true;slice.search="fabrication"
    let matches=try catalogue.cataloguePage(slice)
    try check(matches.items.map(\.id)==[1,2],"Indexed content search includes canonical and shared readings")
    slice.search="fabrication OR missing"
    try check(try catalogue.cataloguePage(slice).items.isEmpty,"FTS operator text is quoted as literal tokens")
    slice.search="  "
    try check(try catalogue.cataloguePage(slice).items.count==200,"Whitespace searches safely behave as an empty filter")
    slice=CatalogueSlice();slice.facets=[.owner:"Organization",.state:"partial"]
    try check(try catalogue.cataloguePage(slice).items.map(\.id)==[2],"Combined semantic and reading filters intersect correctly")
    slice.facets=[.project:"' OR 1=1 --"]
    try check(try catalogue.cataloguePage(slice).items.isEmpty,"Facet values never become executable SQL")
    try check(try catalogue.storedReading(matches.items[1]).contains(body),"A shared reading resolves to its matching canonical compressed body")
    try refuses("protected body") {_ = try catalogue.storedReading(first.items[2])}
    try execute("UPDATE items SET hash='mismatch' WHERE id=2")
    try refuses("canonical hash mismatch") {_ = try catalogue.storedReading(matches.items[1])}
    try execute("UPDATE items SET hash='"+hash+"' WHERE id=2")
    let readOnlyBefore=try Data(contentsOf:file)
    let reader=try AtlasDatabase(file.path)
    try refuses("read-only connection") {try reader.rows("DELETE FROM items") {_ in }}
    let cancelled=CatalogueCancellation();cancelled.cancel()
    try refuses("superseded request") {_ = try catalogue.cataloguePage(CatalogueSlice(),cancellation:cancelled)}
    try check(try AtlasDatabase.unpack(packed,limit:640000)==Data(body.utf8),"Compressed cached content decodes losslessly")
    try refuses("compression bound") {_ = try AtlasDatabase.unpack(AtlasDatabase.pack(Data(repeating:65,count:4096)),limit:100)}
    try refuses("trailing compressed bytes") {_ = try AtlasDatabase.unpack(packed+Data([1,2]),limit:640000)}
    try check(try Data(contentsOf:file)==readOnlyBefore,"Read-only queries retain exact catalogue bytes")

    var diskConnection:OpaquePointer?
    guard sqlite3_open(diskFile.path,&diskConnection)==SQLITE_OK,let diskDB=diskConnection else {throw KonMagicError("Synthetic disk catalogue unavailable")}
    defer {sqlite3_close(diskDB)}
    func diskExecute(_ sql:String)throws {guard sqlite3_exec(diskDB,sql,nil,nil,nil)==SQLITE_OK else {throw KonMagicError("Synthetic disk schema failed")}}
    try diskExecute("CREATE TABLE meta(key TEXT,value TEXT); INSERT INTO meta VALUES('entries','207'),('status','finished_with_exceptions'),('kinds','{\"file\":207}'),('boundaries','{\"user_data\":207}'); CREATE TABLE roots(path TEXT,status TEXT); INSERT INTO roots VALUES('/synthetic','finished_with_exceptions'); CREATE TABLE directories(path BLOB PRIMARY KEY,metadata TEXT,total INTEGER,boundary TEXT); CREATE TABLE blocks(path BLOB,part INTEGER,entries BLOB); CREATE TABLE aliases(path BLOB,canonical BLOB); CREATE TABLE issues(path TEXT,reason TEXT); INSERT INTO issues VALUES('/synthetic/held','Synthetic permission boundary');")
    let key=try AtlasDatabase.pack(Data("/synthetic".utf8))
    func insertBlob(_ sql:String,_ blobs:[Data])throws {
        var raw:OpaquePointer?;guard sqlite3_prepare_v2(diskDB,sql,-1,&raw,nil)==SQLITE_OK,let statement=raw else {throw KonMagicError("Synthetic blob insertion failed")};defer {sqlite3_finalize(statement)}
        let transient=unsafeBitCast(-1,to:sqlite3_destructor_type.self)
        for (i,blob) in blobs.enumerated() {_ = blob.withUnsafeBytes {sqlite3_bind_blob(statement,Int32(i+1),$0.baseAddress,Int32(blob.count),transient)}}
        guard sqlite3_step(statement)==SQLITE_DONE else {throw KonMagicError("Synthetic disk insertion failed")}
    }
    try insertBlob("INSERT INTO directories VALUES(?,'{}',207,'')",[key])
    var entries:[[Any]]=[]
    for i in 1...207 {entries.append([String(format:"file-%03d.txt",i),"file",100,100,1700000000000000000,1,i,i==207 ? 0x40000000 : 0])}
    let block=try AtlasDatabase.pack(JSONSerialization.data(withJSONObject:entries))
    try insertBlob("INSERT INTO blocks VALUES(?,0,?)",[key,block])
    try insertBlob("INSERT INTO aliases VALUES(?,?)",[try AtlasDatabase.pack(Data("/synthetic-alias".utf8)),key])
    let disk=DiskCatalogue(path:diskFile.path),diskBefore=try Data(contentsOf:diskFile),overview=try disk.overview()
    let page=try disk.folder("/synthetic"),tail=try disk.folder("/synthetic",offset:200)
    try check(overview.count==207 && overview.exceptions==1 && page.items.count==200 && tail.items.count==7,"Complete compressed disk metadata is browsed in bounded pages")
    try check(tail.items.last?.barrier=="cloud" && tail.items.last?.state=="metadata_only","Cloud metadata remains an explicit hold without body access")
    try check(try disk.folder("/synthetic-alias").canonical=="/synthetic","Volume aliases resolve to one recorded tree, without live traversal")
    try check(try disk.folder("/synthetic",search:"FILE-207").items.count==1,"Disk folder searches filter retained names")
    try refuses("unscanned disk directory") {_ = try disk.folder("/unscanned")}
    try check(try Data(contentsOf:diskFile)==diskBefore,"Disk browsing leaves the original metadata database byte-identical")
    checks += try runKnowledgeTests(at:directory,catalogueURL:file)
    print("CATALOGUE_TESTS passed=\(checks); synthetic records only; actual source operations=0")
    return checks
}
