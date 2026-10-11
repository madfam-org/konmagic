import Foundation
import Darwin

// Human decisions live separately from the immutable Atlas observations.
struct TagCorrection:Codable,Equatable {
    var tags:[String:String]
    var note:String
    var date:Date
}
struct TagUndo:Codable {
    var paths:[String]
    var previous:[String:TagCorrection]
}
struct SavedCollection:Codable {
    var id=UUID().uuidString
    var name:String
    var slice:CatalogueSlice
    var mode:Int
    var dimension:CatalogueDimension
    var metric:Int
}
struct NameRecipe:Codable {
    var prefix="",suffix="",find="",replacement=""
    func output(_ name:String) throws -> String {
        let url=URL(fileURLWithPath:name),ext=url.pathExtension
        let stem=ext.isEmpty ? name : String(name.dropLast(ext.count+1))
        let renamed=find.isEmpty ? stem : stem.replacingOccurrences(of:find,with:replacement)
        let result=prefix+renamed+suffix+(ext.isEmpty ? "" : "."+ext)
        try Workspace.checkName(result);return result
    }
}
struct ProposalRule:Codable {
    var id=UUID().uuidString
    var name:String
    var slice:CatalogueSlice
    var destination:String
    var recipe:NameRecipe
}
struct Knowledge:Codable {
    var version=1
    var tagStamp=UUID().uuidString
    var corrections:[String:TagCorrection]=[:]
    var undo:[TagUndo]=[]
    var collections:[SavedCollection]=[]
    var rules:[ProposalRule]=[]
    static let fields=["owner","project","family","role","lifecycle"]
    func validate() throws {
        guard version==1,corrections.count<=5000,undo.count<=64,collections.count<=64,rules.count<=64,
              Set(collections.map(\.id)).count==collections.count,Set(rules.map(\.id)).count==rules.count else {throw KonMagicError("Knowledge storage exceeds its supported bounds.")}
        func correction(_ path:String,_ value:TagCorrection) throws {
            _ = try SafeFS.components(path)
            guard !value.tags.isEmpty,value.tags.keys.allSatisfy({Self.fields.contains($0)}),
                  value.tags.values.allSatisfy({$0.utf8.count<=240 && !$0.contains("\0")}),value.note.utf8.count<=2000 else {throw KonMagicError("Correct semantic tags only; protection boundaries and reading evidence cannot be overridden.")}
        }
        for (p,c) in corrections {try correction(p,c)}
        for u in undo {
            guard u.paths.count<=200,Set(u.paths).count==u.paths.count,Set(u.previous.keys).isSubset(of:Set(u.paths)) else {throw KonMagicError("Invalid correction history.")}
            for p in u.paths {_ = try SafeFS.components(p)}
            for (p,c) in u.previous {try correction(p,c)}
        }
        for c in collections {try Workspace.checkName(c.name);try c.slice.validate();guard (0...4).contains(c.mode),(0...1).contains(c.metric) else {throw KonMagicError("Invalid collection view.")}}
        for r in rules {
            try Workspace.checkName(r.name);try r.slice.validate()
            guard !r.destination.isEmpty,[r.recipe.prefix,r.recipe.suffix,r.recipe.find,r.recipe.replacement].allSatisfy({$0.utf8.count<=100 && !$0.contains("\0")}) else {throw KonMagicError("Invalid proposal recipe.")}
            _ = try r.recipe.output("example.pdf")
        }
    }
    func applying(to item:CatalogItem)->CatalogItem {
        guard let c=corrections[item.path] else {return item}
        var result=item
        for (k,v) in c.tags {result.tags[k]=v}
        result.context=[result.tags["owner"],result.tags["project"],result.tags["family"]].compactMap {$0}.filter {!$0.isEmpty}.joined(separator:" / ")
        result.manual=true
        result.evidence.append("Human tag correction for this exact path · "+ISO8601DateFormatter().string(from:c.date)+(c.note.isEmpty ? "" : " · "+c.note))
        return result
    }
}
final class KnowledgeStore {
    private let lock=NSLock()
    private var value:Knowledge
    let file:URL
    init(directory:URL) throws {
        file=directory.appendingPathComponent("knowledge.json")
        let parent=try SafeFS.openDirectory(directory.path);defer {close(parent)}
        var s=stat()
        if fstatat(parent,"knowledge.json",&s,AT_SYMLINK_NOFOLLOW)==0 {
            guard SafeFS.isFile(s),s.st_uid==getuid(),s.st_mode & 0o077==0,s.st_size<=8*1024*1024 else {throw KonMagicError("Knowledge must be a small, owned, private regular file.")}
            let fd=openat(parent,"knowledge.json",O_RDONLY|O_NOFOLLOW);guard fd>=0 else {throw SafeFS.fail("Could not open private knowledge")};defer {close(fd)}
            var current=stat();guard fstat(fd,&current)==0,Identity(current)==Identity(s) else {throw KonMagicError("Knowledge changed during opening.")}
            let data=FileHandle(fileDescriptor:fd,closeOnDealloc:false).readData(ofLength:Int(s.st_size)+1)
            var after=stat();guard data.count==s.st_size,fstat(fd,&after)==0,Identity(after)==Identity(s) else {throw KonMagicError("Knowledge changed during reading.")}
            let decoder=JSONDecoder();decoder.dateDecodingStrategy = .iso8601
            value=try decoder.decode(Knowledge.self,from:data);try value.validate()
        } else {
            guard errno==ENOENT else {throw SafeFS.fail("Could not inspect private knowledge")}
            value=Knowledge()
        }
    }
    func snapshot()->Knowledge {lock.lock();defer {lock.unlock()};return value}
    private func change(_ body:(inout Knowledge)throws->Void) throws {
        lock.lock();defer {lock.unlock()}
        var next=value;try body(&next);try next.validate()
        let encoder=JSONEncoder();encoder.dateEncodingStrategy = .iso8601;encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
        guard try encoder.encode(next).count<=8*1024*1024 else {throw KonMagicError("Private knowledge reached its 8 MiB limit. Export or reduce saved history before adding more.")}
        try SafeFS.writeRecord(next,at:file);value=next
    }
    func correct(paths:[String],tags:[String:String],note:String) throws {
        let paths=Array(Set(paths)).sorted()
        guard !paths.isEmpty,paths.count<=200,!tags.isEmpty else {throw KonMagicError("Select up to 200 exact observations and supply at least one semantic tag.")}
        try change {v in
            var previous:[String:TagCorrection]=[:]
            for p in paths {
                if let prior=v.corrections[p] {previous[p]=prior}
                var combined=v.corrections[p]?.tags ?? [:];for (k,t) in tags {combined[k]=t}
                v.corrections[p]=TagCorrection(tags:combined,note:note,date:Date())
            }
            v.undo.append(TagUndo(paths:paths,previous:previous));if v.undo.count>64 {v.undo.removeFirst()};v.tagStamp=UUID().uuidString
        }
    }
    func reset(paths:[String]) throws {
        let paths=Array(Set(paths)).sorted()
        guard paths.count<=200 else {throw KonMagicError("Reset at most 200 observations at once.")}
        try change {v in
            let previous=v.corrections.filter {paths.contains($0.key)}
            guard !previous.isEmpty else {throw KonMagicError("No personal tag corrections are stored for these paths.")}
            v.undo.append(TagUndo(paths:paths,previous:previous));if v.undo.count>64 {v.undo.removeFirst()}
            for p in paths {v.corrections.removeValue(forKey:p)};v.tagStamp=UUID().uuidString
        }
    }
    func undoCorrection() throws {
        try change {v in
            guard let u=v.undo.popLast() else {throw KonMagicError("No personal tag correction to undo.")}
            for p in u.paths {v.corrections[p]=u.previous[p]};v.tagStamp=UUID().uuidString
        }
    }
    func save(_ collection:SavedCollection) throws {try change {v in v.collections.removeAll {$0.id==collection.id};v.collections.append(collection)}}
    func save(_ rule:ProposalRule) throws {try change {v in v.rules.removeAll {$0.id==rule.id};v.rules.append(rule)}}
    func removeCollection(_ id:String) throws {try change {$0.collections.removeAll {$0.id==id}}}
    func removeRule(_ id:String) throws {try change {$0.rules.removeAll {$0.id==id}}}
}

struct DraftProposal {
    var assignments:[Assignment]=[]
    var held:[String]=[]
    var limited=false
    static func make(items:[CatalogItem],rule:ProposalRule,workspace:Workspace,more:Bool=false) throws -> DraftProposal {
        _ = try workspace.path(rule.destination)
        var result=DraftProposal(),destinations=Set<String>(),sources=Set<String>()
        for a in workspace.assignments {destinations.insert(Workspace.key(try workspace.destination(a)));sources.insert(a.source)}
        for item in items {
            if result.assignments.count+workspace.assignments.count>=100 {result.limited=true;break}
            guard item.kind=="file",item.barrier.isEmpty || item.barrier=="user_data",!SafeFS.guardedName(item.name) else {result.held.append(item.path+" — protected or not an individual regular file");continue}
            guard !sources.contains(item.path),!workspace.assignments.contains(where:{item.path.hasPrefix($0.source+"/") || $0.source.hasPrefix(item.path+"/")}) else {result.held.append(item.path+" — existing manual assignment or overlapping bucket");continue}
            do {
                _ = try SafeFS.components(item.path)
                let a=Assignment(source:item.path,node:rule.destination,outputName:try rule.recipe.output(item.name))
                let target=Workspace.key(try workspace.destination(a))
                guard !destinations.contains(where:{target.hasPrefix($0+"/") || $0.hasPrefix(target+"/")}),destinations.insert(target).inserted else {result.held.append(item.path+" — output-name collision");continue}
                sources.insert(item.path);result.assignments.append(a)
            } catch {result.held.append(item.path+" — "+error.localizedDescription)}
        }
        result.limited = result.limited || more
        return result
    }
    func apply(to workspace:inout Workspace) throws {
        // Recheck manual choices and collisions against the current draft.
        var paths=Set(workspace.assignments.map(\.source)),destinations=Set<String>()
        for a in workspace.assignments {destinations.insert(Workspace.key(try workspace.destination(a)))}
        for a in assignments {
            let target=Workspace.key(try workspace.destination(a))
            guard paths.insert(a.source).inserted,!workspace.assignments.contains(where:{a.source.hasPrefix($0.source+"/") || $0.source.hasPrefix(a.source+"/")}),!destinations.contains(where:{target.hasPrefix($0+"/") || $0.hasPrefix(target+"/")}),destinations.insert(target).inserted else {throw KonMagicError("The draft changed or a proposal collides. Preview the rule again.")}

            workspace.assignments.append(a)
        }
        try workspace.validate()
    }
}
