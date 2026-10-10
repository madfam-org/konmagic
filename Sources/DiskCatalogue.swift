import Foundation
import SQLite3
import Darwin

struct DiskOverview {
    var count:Int64=0
    var status="Unavailable",updated=""
    var kinds:[String:Int64]=[:],boundaries:[String:Int64]=[:]
    var exceptions:Int64=0
}
struct DiskPage {let items:[CatalogItem];let total:Int;let canonical:String;let next:Int?}
final class DiskCatalogue {
    let path:String
    init(path:String) {self.path=path}
    func overview() throws -> DiskOverview {
        let reader=try AtlasDatabase(path);var record:[String:String]=[:],overview=DiskOverview()
        try reader.rows("SELECT key,value FROM meta") {s in record[AtlasDatabase.string(s,0)]=AtlasDatabase.string(s,1)}
        overview.count=Int64(record["entries"] ?? "0") ?? 0;overview.status=record["status"] ?? "Unknown";overview.updated=record["updated"] ?? ""
        for key in ["kinds","boundaries"] {
            let data=(record[key] ?? "{}").data(using:.utf8) ?? Data()
            let values=(try? JSONDecoder().decode([String:Int64].self,from:data)) ?? [:]
            if key=="kinds" {overview.kinds=values} else {overview.boundaries=values}
        }
        try reader.rows("SELECT count(*) FROM issues") {s in overview.exceptions=sqlite3_column_int64(s,0)}
        return overview
    }
    func roots() throws -> [CatalogItem] {
        let reader=try AtlasDatabase(path);var items:[CatalogItem]=[]
        try reader.rows("SELECT path,status FROM roots ORDER BY path") {s in
            let path=AtlasDatabase.string(s,0)
            var item=CatalogItem(id:0,path:path,name:path,kind:"directory",bytes:0,context:AtlasDatabase.string(s,1))
            item.origin="Whole-disk metadata";item.state="metadata_only";items.append(item)
        };return items
    }
    func folder(_ requested:String,offset:Int=0,search:String="") throws -> DiskPage {
        guard requested.utf8.count<=65_536,requested.hasPrefix("/"),offset>=0,offset<=10_000_000,search.count<=300 else {throw KonMagicError("Invalid disk folder page.")}
        let reader=try AtlasDatabase(path),key=try AtlasDatabase.pack(Data(requested.utf8));var canonical=requested
        try reader.blobRows("SELECT canonical FROM aliases WHERE path=?",key:key) {s in
            if let data=AtlasDatabase.blob(s,0,limit:65_536),let path=String(data:try AtlasDatabase.unpack(data,limit:65_536),encoding:.utf8) {canonical=path}
        }
        let lookup=try AtlasDatabase.pack(Data(canonical.utf8));var total:Int?=nil,boundary=""
        try reader.blobRows("SELECT total,boundary FROM directories WHERE path=?",key:lookup) {s in total=Int(sqlite3_column_int64(s,0));boundary=AtlasDatabase.string(s,1)}
        guard let total=total else {throw KonMagicError("This directory was unscanned or held at ingestion. See the coverage exceptions; no live traversal was requested.")}
        var items:[CatalogItem]=[],matched=0
        try reader.blobRows("SELECT entries FROM blocks WHERE path=? ORDER BY part",key:lookup) {s in
            if items.count>=201 {return}
            guard let data=AtlasDatabase.blob(s,0,limit:8*1024*1024),let rows=try JSONSerialization.jsonObject(with:AtlasDatabase.unpack(data,limit:8*1024*1024)) as? [[Any]] else {throw KonMagicError("Disk metadata block is invalid.")}
            for row in rows {
                guard row.count==8,let name=row[0] as? String,let kind=row[1] as? String else {throw KonMagicError("Disk entry schema is invalid.")}
                guard !name.contains("/"),name != ".",name != ".." else {throw KonMagicError("Invalid disk entry name.")}
                if !search.isEmpty && !name.localizedCaseInsensitiveContains(search) {continue}
                matched+=1;if matched<=offset {continue};if items.count>=201 {break}
                let path=canonical=="/" ? "/"+name : canonical+"/"+name
                let size=(row[2] as? NSNumber)?.int64Value ?? 0
                var item=CatalogItem(id:0,path:path,name:name,kind:kind,bytes:size,context:"Metadata only · "+(boundary.isEmpty ? "user_data" : boundary))
                item.state="metadata_only";item.origin="Whole-disk metadata";item.modified=(row[4] as? NSNumber)?.int64Value ?? 0
                item.tags=MetadataLabels.tags(path:path,kind:kind,inherited:boundary)
                item.barrier=item.tags["boundary"] ?? "user_data";item.confidence=0.35
                let flags=(row[7] as? NSNumber)?.uint32Value ?? 0
                if flags & 0x40000000 != 0 {item.barrier="cloud"}
                if kind=="link" {item.barrier="symlink"}
                items.append(item)
            }
        }
        let more=items.count>200;if more {items.removeLast()}
        return DiskPage(items:items,total:total,canonical:canonical,next:more ? offset+200 : nil)
    }
    func exceptions(offset:Int=0) throws -> [CatalogItem] {
        let reader=try AtlasDatabase(path);var items:[CatalogItem]=[]
        try reader.rows("SELECT path,reason FROM issues ORDER BY path LIMIT 200 OFFSET ?",[String(max(0,offset))]) {s in
            let path=AtlasDatabase.string(s,0)
            var item=CatalogItem(id:0,path:path,name:URL(fileURLWithPath:path).lastPathComponent,kind:"exception",bytes:0,context:AtlasDatabase.string(s,1))
            item.origin="Whole-disk metadata";item.state="held";item.reason=item.context;items.append(item)
        };return items
    }
}

struct SummaryStamp:Codable,Equatable {let path:String;let file:Identity;let wal:Identity?}
struct SummaryCache:Codable {let stamp:SummaryStamp;let summary:CatalogueSummary}
extension Catalog {
    func summaryStamp() throws -> SummaryStamp {
        let directory=URL(fileURLWithPath:path).deletingLastPathComponent().path,name=URL(fileURLWithPath:path).lastPathComponent
        let fd=try SafeFS.openDirectory(directory);defer {close(fd)}
        let file=try SafeFS.info(fd,name);var wal:Identity?
        var s=stat();if fstatat(fd,name+"-wal",&s,AT_SYMLINK_NOFOLLOW)==0 {guard SafeFS.isFile(s) else {throw KonMagicError("Catalogue WAL is not a regular file.")};wal=Identity(s)}
        return SummaryStamp(path:path,file:Identity(file),wal:wal)
    }
    func cachedSummary(in directory:URL,cancellation:CatalogueCancellation?=nil) throws -> CatalogueSummary {
        let stamp=try summaryStamp(),url=directory.appendingPathComponent("catalogue-summary.json")
        if let metadata=try? url.resourceValues(forKeys:[.isRegularFileKey,.isSymbolicLinkKey,.fileSizeKey]),metadata.isRegularFile==true,metadata.isSymbolicLink != true,(metadata.fileSize ?? Int.max)<32*1024*1024 {
            let fd=open(url.path,O_RDONLY|O_NOFOLLOW)
            if fd>=0 {defer {close(fd)};var info=stat();if fstat(fd,&info)==0,info.st_uid==getuid(),info.st_mode & 0o077==0 {
                guard info.st_size<32*1024*1024 else {throw KonMagicError("Aggregate cache exceeds its private size bound.")}
                let data=FileHandle(fileDescriptor:fd,closeOnDealloc:false).readDataToEndOfFile()
                if let cache=try? JSONDecoder().decode(SummaryCache.self,from:data),cache.stamp==stamp {return cache.summary}
            }}
        }
        let summary=try self.summary(cancellation:cancellation)
        guard try summaryStamp()==stamp else {throw KonMagicError("Catalogue changed while its summary was prepared. Retry; no mixed snapshot is being cached.")}
        try SafeFS.writeRecord(SummaryCache(stamp:stamp,summary:summary),at:url)
        return summary
    }
}
