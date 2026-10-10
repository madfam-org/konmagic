import Foundation
import SQLite3
import Darwin

struct CatalogItem {
    let id: Int64
    let path: String
    let name: String
    let kind: String
    let bytes: Int64
    let context: String
}
private final class QueryBudget { let deadline=Date().addingTimeInterval(3) }

final class Catalog {
    let path: String
    init(path: String) { self.path = path }
    func liveFolder(_ path:String,search:String="",offset:Int=0,includeHidden:Bool=false) throws -> [CatalogItem] {
        let fd=try SafeFS.openDirectory(path);defer {close(fd)}
        let names=try SafeFS.names(fd).filter {(includeHidden || !$0.hasPrefix(".")) && (search.isEmpty || $0.localizedCaseInsensitiveContains(search))}
        let start=min(max(0,offset),names.count),end=min(start+200,names.count)
        return try names[start..<end].map {name in
            var s=stat();guard fstatat(fd,name,&s,AT_SYMLINK_NOFOLLOW)==0 else {throw SafeFS.fail("Folder changed during metadata browsing")}
            let kind=SafeFS.isDirectory(s) ? "directory" : SafeFS.isFile(s) ? "file" : "link"
            return CatalogItem(id:0,path:URL(fileURLWithPath:path).appendingPathComponent(name).path,name:name,kind:kind,bytes:s.st_size,context:s.st_flags & 0x40000000 != 0 ? "Cloud metadata · held" : "Live folder metadata")
        }
    }
    func query(scope: String?, search: String, offset: Int = 0) throws -> [CatalogItem] {
        let parent=try SafeFS.openDirectory(URL(fileURLWithPath:path).deletingLastPathComponent().path);defer {close(parent)}
        let metadata=try SafeFS.info(parent,URL(fileURLWithPath:path).lastPathComponent)
        guard SafeFS.isFile(metadata) else {throw KonMagicError("Choose a local regular catalogue file; linked or cloud files are held.")}
        var db: OpaquePointer?
        guard sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_NOFOLLOW, nil) == SQLITE_OK, let database = db else {
            if let db = db { sqlite3_close(db) }
            throw KonMagicError("Catalogue unavailable. Choose its folder in File → Connect catalogue; macOS may require explicit folder access.")
        }
        defer { sqlite3_close(database) }
        sqlite3_busy_timeout(database, 1500)
        let budget=QueryBudget()
        sqlite3_progress_handler(database,10_000,{pointer in
            guard let pointer=pointer else{return 1}
            return Date() > Unmanaged<QueryBudget>.fromOpaque(pointer).takeUnretainedValue().deadline ? 1 : 0
        },Unmanaged.passUnretained(budget).toOpaque())
        defer {sqlite3_progress_handler(database,0,nil,nil);withExtendedLifetime(budget) {}}
        // Bounded, metadata-only reads. Never decode or duplicate extracted bodies.
        var sql = "SELECT id,path,name,kind,size,tags,barrier FROM items WHERE "
        var args: [String] = []
        if let scope = scope {
            let prefix = scope.hasSuffix("/") ? scope : scope + "/"
            // The unique path index avoids walking the whole catalogue for a folder.
            sql += "path>=? AND path<? AND "
            args += [prefix, String(prefix.dropLast()) + "0"]
            if search.isEmpty { sql += "instr(substr(path,length(?)+1),'/')=0 AND "; args.append(prefix) }
        }
        if !search.isEmpty {
            sql += "(instr(lower(name),lower(?))>0 OR instr(lower(path),lower(?))>0) AND "
            args += [search, search]
        }
        sql += "barrier NOT IN ('credentials','audit') ORDER BY path LIMIT 200 OFFSET ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK, let statement = stmt else {
            let reason=String(cString:sqlite3_errmsg(database))
            throw KonMagicError("Catalogue query held: "+reason+". Choose a narrower source folder or retry. The original catalogue remains intact.")
        }
        defer { sqlite3_finalize(statement) }
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        for (i, arg) in args.enumerated() { sqlite3_bind_text(statement, Int32(i+1), arg, -1, transient) }
        sqlite3_bind_int64(statement, Int32(args.count+1), Int64(offset))
        func string(_ i: Int32) -> String { sqlite3_column_text(statement, i).map { String(cString: $0) } ?? "" }
        var items: [CatalogItem] = []
        while true {
            let status = sqlite3_step(statement)
            if status == SQLITE_DONE { break }
            guard status == SQLITE_ROW else { throw KonMagicError("Catalogue query was held or exceeded its three-second budget. Choose a narrower source folder; no empty result is being reported as a successful search.") }
            let tags = (string(5).data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) }) as? [String: Any] ?? [:]
            let context = [tags["owner"] as? String, tags["project"] as? String].compactMap { $0 }.joined(separator: " / ")
            items.append(CatalogItem(id: sqlite3_column_int64(statement,0), path: string(1), name: string(2), kind: string(3), bytes: sqlite3_column_int64(statement,4), context: context))
        }
        return items
    }
}
