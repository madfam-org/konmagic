import Foundation
import SQLite3
import Darwin

struct CatalogItem {
    let id: Int64
    let path: String
    let name: String
    let kind: String
    let bytes: Int64
    var context: String
    var tags: [String:String] = [:]
    var state = "metadata_only"
    var barrier = ""
    var confidence: Double? = nil
    var evidence: [String] = []
    var reason = ""
    var modified: Int64 = 0
    var observed = ""
    var manual = false
    var visualLabels: [String] = []
    var origin = "Live metadata"
}
private final class QueryBudget { let deadline=Date().addingTimeInterval(3) }

final class Catalog {
    let path: String
    let knowledge:KnowledgeStore?
    init(path: String,knowledge:KnowledgeStore?=nil) { self.path = path;self.knowledge=knowledge }
    func liveFolder(_ path:String,search:String="",offset:Int=0,includeHidden:Bool=false) throws -> [CatalogItem] {
        let fd=try SafeFS.openDirectory(path);defer {close(fd)}
        let names=try SafeFS.names(fd).filter {(includeHidden || !$0.hasPrefix(".")) && (search.isEmpty || $0.localizedCaseInsensitiveContains(search))}
        let start=min(max(0,offset),names.count),end=min(start+200,names.count)
        return try names[start..<end].map {name in
            var s=stat();guard fstatat(fd,name,&s,AT_SYMLINK_NOFOLLOW)==0 else {throw SafeFS.fail("Folder changed during metadata browsing")}
            let kind=SafeFS.isDirectory(s) ? "directory" : SafeFS.isFile(s) ? "file" : "link"
            let fullPath=URL(fileURLWithPath:path).appendingPathComponent(name).path
            var item=CatalogItem(id:0,path:fullPath,name:name,kind:kind,bytes:s.st_size,context:s.st_flags & 0x40000000 != 0 ? "Cloud metadata · held" : "Live folder metadata")
            item.tags=MetadataLabels.tags(path:fullPath,kind:kind,inherited:"");item.barrier=item.tags["boundary"] ?? "user_data";item.confidence=0.35
            if kind=="link" {item.barrier="symlink"}
            item.modified=Int64(s.st_mtimespec.tv_sec)*1_000_000_000+Int64(s.st_mtimespec.tv_nsec)
            if s.st_flags & 0x40000000 != 0 {item.barrier="cloud"}
            return knowledge?.snapshot().applying(to:item) ?? item
        }
    }
    func query(scope: String?, search: String, offset: Int = 0) throws -> [CatalogItem] {
        guard offset>=0 else {throw KonMagicError("Invalid catalogue page offset.")}
        let reader=try AtlasDatabase(path,seconds:15)
        var slice=CatalogueSlice();slice.folder=scope;slice.directChildren=scope != nil && search.isEmpty;slice.search=search
        let predicate=slice.predicate(),source=try effectiveSource(reader)
        var items:[CatalogItem]=[]
        try reader.rows("SELECT "+Self.recordFields+" FROM "+source+" WHERE ("+predicate.0+") AND i.barrier NOT IN ('credentials','audit') ORDER BY i.path LIMIT 200 OFFSET ?",predicate.1+[String(offset)]) {items.append(Self.record($0))}
        return items
    }
}
