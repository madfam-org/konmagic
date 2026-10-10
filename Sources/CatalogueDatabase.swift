import Foundation
import SQLite3
import Darwin
import zlib

final class CatalogueCancellation {
    private let lock=NSLock()
    private var stopped=false
    func cancel() {lock.lock();stopped=true;lock.unlock()}
    var cancelled:Bool {lock.lock();defer {lock.unlock()};return stopped}
}

// Every durable Atlas connection is read-only. No original source is opened here.
final class AtlasDatabase {
    let db: OpaquePointer
    private let deadline: Date
    private let cancellation:CatalogueCancellation?
    init(_ path: String, seconds: TimeInterval = 5, cancellation:CatalogueCancellation?=nil) throws {
        let parent = try SafeFS.openDirectory(URL(fileURLWithPath:path).deletingLastPathComponent().path)
        defer {close(parent)}
        let file = try SafeFS.info(parent,URL(fileURLWithPath:path).lastPathComponent)
        guard SafeFS.isFile(file) else {throw KonMagicError("A catalogue must be a local regular file.")}
        var connection: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_NOFOLLOW
        guard sqlite3_open_v2(path,&connection,flags,nil)==SQLITE_OK, let connection=connection else {
            if let connection=connection {sqlite3_close(connection)}
            throw KonMagicError("Catalogue access is unavailable. Connect its folder through the native folder panel.")
        }
        db=connection; deadline=Date().addingTimeInterval(seconds);self.cancellation=cancellation
        sqlite3_limit(db,SQLITE_LIMIT_LENGTH,16*1024*1024)
        sqlite3_busy_timeout(db,1000)
        sqlite3_progress_handler(db,20_000,{p in
            guard let p=p else {return 1}
            let reader=Unmanaged<AtlasDatabase>.fromOpaque(p).takeUnretainedValue()
            return Date()>reader.deadline || reader.cancellation?.cancelled==true ? 1 : 0
        },Unmanaged.passUnretained(self).toOpaque())
    }
    deinit {sqlite3_progress_handler(db,0,nil,nil);sqlite3_close(db)}
    func rows(_ sql:String, _ values:[String]=[], each:(OpaquePointer)throws->Void) throws {
        guard cancellation?.cancelled != true else {throw KonMagicError("Superseded catalogue request cancelled.")}
        var raw:OpaquePointer?
        guard sqlite3_prepare_v2(db,sql,-1,&raw,nil)==SQLITE_OK,let statement=raw else {
            throw KonMagicError("Catalogue query held: "+String(cString:sqlite3_errmsg(db)))
        }
        defer {sqlite3_finalize(statement)}
        let transient=unsafeBitCast(-1,to:sqlite3_destructor_type.self)
        for (i,value) in values.enumerated() {sqlite3_bind_text(statement,Int32(i+1),value,-1,transient)}
        while true {
            let status=sqlite3_step(statement)
            if status==SQLITE_DONE {break}
            guard status==SQLITE_ROW else {throw KonMagicError("Catalogue query was held or exceeded its time budget. Narrow the scope and retry; an empty success is not being reported.")}
            try each(statement)
        }
    }
    func blobRows(_ sql:String, key:Data, each:(OpaquePointer)throws->Void) throws {
        var raw:OpaquePointer?
        guard sqlite3_prepare_v2(db,sql,-1,&raw,nil)==SQLITE_OK,let statement=raw else {throw KonMagicError("Disk metadata schema is unavailable.")}
        defer {sqlite3_finalize(statement)}
        let transient=unsafeBitCast(-1,to:sqlite3_destructor_type.self)
        _ = key.withUnsafeBytes {sqlite3_bind_blob(statement,1,$0.baseAddress,Int32(key.count),transient)}
        while true {
            let status=sqlite3_step(statement)
            if status==SQLITE_DONE {break}
            guard status==SQLITE_ROW else {throw KonMagicError("Disk metadata query held; no original files were accessed.")}
            try each(statement)
        }
    }
    static func string(_ s:OpaquePointer,_ i:Int32)->String {sqlite3_column_text(s,i).map {String(cString:$0)} ?? ""}
    static func blob(_ s:OpaquePointer,_ i:Int32,limit:Int)->Data? {
        let size=Int(sqlite3_column_bytes(s,i))
        guard size>=0,size<=limit,let p=sqlite3_column_blob(s,i) else {return nil}
        return Data(bytes:p,count:size)
    }
    static func unpack(_ data:Data,limit:Int) throws -> Data {
        guard limit>=0,limit<=8*1024*1024,!data.isEmpty,data.count<=8*1024*1024 else {throw KonMagicError("Invalid compressed catalogue record.")}
        var capacity=min(limit+1,16*1024)
        while true {
            var bytes=[UInt8](repeating:0,count:capacity),size=uLongf(capacity),used=uLong(data.count)
            let result=data.withUnsafeBytes {p in uncompress2(&bytes,&size,p.bindMemory(to:Bytef.self).baseAddress,&used)}
            if result==Z_OK,size<=limit,used==data.count {return Data(bytes.prefix(Int(size)))}
            guard result==Z_BUF_ERROR,capacity<limit+1 else {throw KonMagicError("Compressed catalogue record is incomplete or exceeds its bound.")}
            capacity=min(limit+1,capacity*2)
        }
    }
    static func pack(_ data:Data) throws -> Data {
        var size=compressBound(uLong(data.count)),buffer=[UInt8](repeating:0,count:Int(compressBound(uLong(data.count))))
        let result=data.withUnsafeBytes {p in compress2(&buffer,&size,p.bindMemory(to:Bytef.self).baseAddress,uLong(data.count),1)}
        guard result==Z_OK else {throw KonMagicError("Could not encode disk metadata lookup.")}
        return Data(buffer.prefix(Int(size)))
    }
}

enum CatalogueDimension: String, CaseIterable, Codable {
    case owner,project,family,role,lifecycle,state,barrier,kind,extensionName,modifiedYear,sizeBand,confidenceBand,readingMethod
    var title:String {
        switch self {
        case .owner:return "Owner";case .project:return "Project";case .family:return "Content family"
        case .role:return "Purpose";case .lifecycle:return "Lifecycle";case .state:return "Reading status"
        case .barrier:return "Protection boundary";case .kind:return "File or folder";case .extensionName:return "Extension"
        case .modifiedYear:return "Modified year (UTC)";case .sizeBand:return "File size"
        case .confidenceBand:return "Tag confidence";case .readingMethod:return "Reading method"
        }
    }
    var sql:String {
        switch self {
        case .owner,.project,.family,.role,.lifecycle:return "COALESCE(NULLIF(json_extract(i.tags,'$."+rawValue+"'),''),'Unassigned')"
        case .state:return "COALESCE(NULLIF(i.state,''),'Unknown')"
        case .barrier:return "COALESCE(NULLIF(i.barrier,''),'user_data')"
        case .kind:return "i.kind"
        case .extensionName:return "COALESCE(NULLIF(i.extension,''),'[none]')"
        case .modifiedYear:return "COALESCE(strftime('%Y',i.mtime_ns/1000000000,'unixepoch'),'Unknown')"
        case .sizeBand:return "CASE WHEN i.kind!='file' THEN 'Not a regular file' WHEN i.size<1048576 THEN 'Under 1 MiB' WHEN i.size<104857600 THEN '1–100 MiB' WHEN i.size<1073741824 THEN '100 MiB–1 GiB' ELSE '1 GiB or larger' END"
        case .confidenceBand:return "CASE WHEN i.manual=1 THEN 'Human reviewed' WHEN i.confidence>=0.8 THEN 'High (≥0.8)' WHEN i.confidence>=0.5 THEN 'Medium (0.5–0.8)' ELSE 'Low (<0.5)' END"
        case .readingMethod:return "COALESCE(NULLIF(json_extract(i.tags,'$.reading_method'),''),'No recorded method')"
        }
    }
}

struct CatalogueSlice {
    var folder:String? = nil
    var directChildren=false
    var search=""
    var contentSearch=false
    var facets:[CatalogueDimension:String]=[:]
    var cursor:String? = nil
    func predicate(paging:Bool=false)->(String,[String]) {
        var clauses:[String]=[],values:[String]=[]
        if let folder=folder {
            if directChildren {clauses.append("i.parent_path=?");values.append(folder)}
            else {let base=folder=="/" ? "" : folder.trimmingCharacters(in:CharacterSet(charactersIn:"/"));let prefix=base.isEmpty ? "/" : "/"+base+"/";clauses.append("i.path>=? AND i.path<?");values += [prefix,String(prefix.dropLast())+"0"]}
        }
        for d in CatalogueDimension.allCases {if let value=facets[d] {clauses.append(d.sql+"=?");values.append(value)}}
        let term=search.trimmingCharacters(in:.whitespacesAndNewlines)
        if !term.isEmpty {
            if contentSearch {
                let tokens=term.split(whereSeparator:{$0.isWhitespace}).prefix(12)
                let phrase=tokens.map {"\""+$0.replacingOccurrences(of:"\"",with:"\"\"")+"\""}.joined(separator:" AND ")
                clauses.append("i.barrier NOT IN ('credentials','audit') AND (i.id IN (SELECT item_id FROM content_index WHERE content_index MATCH ?) OR i.shared_text_id IN (SELECT item_id FROM content_index WHERE content_index MATCH ?))")
                values += [phrase,phrase]
            } else {clauses.append("(instr(lower(i.name),lower(?))>0 OR instr(lower(i.path),lower(?))>0 OR instr(lower(i.tags),lower(?))>0)");values += [term,term,term]}
        }
        if paging,let cursor=cursor {clauses.append("i.path>?");values.append(cursor)}
        return (clauses.isEmpty ? "1" : clauses.map {"("+$0+")"}.joined(separator:" AND "),values)
    }
}
struct CataloguePage {let items:[CatalogItem];let next:String?}
struct CataloguePartition:Codable {
    let values:[String:String]
    let count:Int64
    let bytes:Int64
    let readings:Int64
    func matches(_ facets:[CatalogueDimension:String])->Bool {facets.allSatisfy {values[$0.key.rawValue]==$0.value}}
}
struct CatalogueFacet {
    let value:String
    var count:Int64=0,bytes:Int64=0,readings:Int64=0
}
struct CatalogueSummary:Codable {
    let partitions:[CataloguePartition]
    var count:Int64 {partitions.reduce(0) {$0+$1.count}}
    var bytes:Int64 {partitions.reduce(0) {$0+$1.bytes}}
    var readings:Int64 {partitions.reduce(0) {$0+$1.readings}}
    func sliced(_ facets:[CatalogueDimension:String])->CatalogueSummary {CatalogueSummary(partitions:partitions.filter {$0.matches(facets)})}
    func groups(_ dimension:CatalogueDimension)->[CatalogueFacet] {
        var groups:[String:CatalogueFacet]=[:]
        for p in partitions {let value=p.values[dimension.rawValue] ?? "Unknown";var g=groups[value] ?? CatalogueFacet(value:value);g.count+=p.count;g.bytes+=p.bytes;g.readings+=p.readings;groups[value]=g}
        return groups.values.sorted {$0.count==$1.count ? $0.value<$1.value : $0.count>$1.count}
    }
}

extension Catalog {
    func observation(at path:String) throws -> CatalogItem? {
        let reader=try AtlasDatabase(self.path);var item:CatalogItem?
        try reader.rows("SELECT i.id,i.path,i.name,i.kind,i.size,i.tags,i.state,i.barrier,i.confidence,i.evidence,i.reason,i.mtime_ns,i.seen,i.manual FROM items i WHERE i.path=?",[path]) {s in item=Self.record(s)}
        return item
    }
    func cataloguePage(_ slice:CatalogueSlice,cancellation:CatalogueCancellation?=nil) throws -> CataloguePage {
        guard slice.search.count<=300 else {throw KonMagicError("Keep search text below 300 characters.")}
        let reader=try AtlasDatabase(path,seconds:15,cancellation:cancellation),whereClause=slice.predicate(paging:true)
        let fields="i.id,i.path,i.name,i.kind,i.size,i.tags,i.state,i.barrier,i.confidence,i.evidence,i.reason,i.mtime_ns,i.seen,i.manual"
        var items:[CatalogItem]=[]
        try reader.rows("SELECT "+fields+" FROM items i WHERE "+whereClause.0+" ORDER BY i.path LIMIT 201",whereClause.1) {s in items.append(Self.record(s))}
        let more=items.count>200;if more {items.removeLast()}
        return CataloguePage(items:items,next:more ? items.last?.path : nil)
    }
    static func record(_ s:OpaquePointer)->CatalogItem {
        let string=AtlasDatabase.string
        let raw=(string(s,5).data(using:.utf8).flatMap {try? JSONSerialization.jsonObject(with:$0)}) as? [String:Any] ?? [:]
        var tags:[String:String]=[:]
        for (key,value) in raw where key != "visual_labels" {tags[key]=String(describing:value)}
        let context=[tags["owner"],tags["project"],tags["family"]].compactMap {$0}.joined(separator:" / ")
        var item=CatalogItem(id:sqlite3_column_int64(s,0),path:string(s,1),name:string(s,2),kind:string(s,3),bytes:sqlite3_column_int64(s,4),context:context)
        item.tags=tags;item.state=string(s,6);item.barrier=string(s,7);item.confidence=sqlite3_column_double(s,8)
        item.evidence=(string(s,9).data(using:.utf8).flatMap {try? JSONSerialization.jsonObject(with:$0)}) as? [String] ?? []
        item.reason=string(s,10);item.modified=sqlite3_column_int64(s,11);item.observed=string(s,12);item.manual=sqlite3_column_int(s,13)==1;item.origin="Atlas tagged catalogue"
        if let labels=raw["visual_labels"] as? [[String:Any]] {
            for label in labels {if let name=label["name"] as? String {let confidence=(label["confidence"] as? NSNumber)?.doubleValue ?? 0;item.visualLabels.append(name+" ("+String(format:"%.0f%%",confidence*100)+")")}}
        }
        return item
    }
    func catalogueRoots() throws -> [CatalogItem] {
        let reader=try AtlasDatabase(path);var roots:[CatalogItem]=[]
        try reader.rows("SELECT path,label FROM roots WHERE purpose='source' ORDER BY path") {s in
            var item=CatalogItem(id:0,path:AtlasDatabase.string(s,0),name:AtlasDatabase.string(s,1),kind:"directory",bytes:0,context:"Recorded source root")
            item.origin="Atlas tagged catalogue";roots.append(item)
        };return roots
    }
    func summary(_ slice:CatalogueSlice=CatalogueSlice(),cancellation:CatalogueCancellation?=nil) throws -> CatalogueSummary {
        let reader=try AtlasDatabase(path,seconds:90,cancellation:cancellation),whereClause=slice.predicate()
        let dimensions=CatalogueDimension.allCases,keys=dimensions.map(\.sql)
        let groupNumbers=(1...dimensions.count).map(String.init).joined(separator:",")
        let sql="SELECT "+keys.joined(separator:",")+",count(*),sum(CASE WHEN i.kind='file' THEN i.size ELSE 0 END),sum(i.state IN ('extracted','partial')) FROM items i WHERE "+whereClause.0+" GROUP BY "+groupNumbers
        var partitions:[CataloguePartition]=[]
        try reader.rows(sql,whereClause.1) {s in
            guard partitions.count<100_000 else {throw KonMagicError("Too many aggregate partitions; narrow the catalogue scope.")}
            var values:[String:String]=[:]
            for (i,d) in dimensions.enumerated() {values[d.rawValue]=AtlasDatabase.string(s,Int32(i))}
            let n=Int32(dimensions.count)
            partitions.append(CataloguePartition(values:values,count:sqlite3_column_int64(s,n),bytes:sqlite3_column_int64(s,n+1),readings:sqlite3_column_int64(s,n+2)))
        }
        return CatalogueSummary(partitions:partitions)
    }
    func storedReading(_ item:CatalogItem) throws -> String {
        guard item.id>0,["extracted","partial"].contains(item.state),!["credentials","audit"].contains(item.barrier),!SafeFS.guardedName(item.name) else {throw KonMagicError("This observation has no eligible stored reading. Original file bodies remain unopened.")}
        let reader=try AtlasDatabase(path);var result:String?
        let sql="SELECT CASE WHEN i.shared_text_id IS NULL OR i.shared_text_id=0 THEN i.text ELSE canonical.text END FROM items i LEFT JOIN items canonical ON canonical.id=i.shared_text_id AND canonical.hash=i.hash AND length(i.hash)=64 AND canonical.extension=i.extension AND (canonical.shared_text_id IS NULL OR canonical.shared_text_id=0) AND canonical.state IN ('extracted','partial') AND canonical.barrier NOT IN ('credentials','audit') WHERE i.id=? AND i.state IN ('extracted','partial') AND i.barrier NOT IN ('credentials','audit')"
        try reader.rows(sql,[String(item.id)]) {s in
            let type=sqlite3_column_type(s,0)
            if type==SQLITE_TEXT {let text=AtlasDatabase.string(s,0);guard text.utf8.count<=640_000 else {throw KonMagicError("Stored reading exceeds its safe bound.")};result=text}
            else if type==SQLITE_BLOB,let data=AtlasDatabase.blob(s,0,limit:640_000) {let text=try AtlasDatabase.unpack(data,limit:640_000);result=String(data:text,encoding:.utf8)}
        }
        guard let result=result,!result.isEmpty else {throw KonMagicError("The retained reading is unavailable or its canonical hash/extension does not match.")}
        return String(result.prefix(20_000))+"\n\n[Stored catalogue excerpt · at most 20,000 characters · original file not opened]"
    }
}
