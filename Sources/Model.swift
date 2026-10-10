import Foundation
import Darwin

struct KonMagicError: Error, LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

struct FolderNode: Codable, Equatable {
    var id = UUID().uuidString
    var parent: String?
    var name: String
}

struct Assignment: Codable, Equatable {
    var id = UUID().uuidString
    var source: String
    var node: String
    var outputName: String
    var bookmark: Data?
}

struct Workspace: Codable {
    var version = 1
    var nodes: [FolderNode] = []
    var assignments: [Assignment] = []
    var output = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents/KonMagic Organized").path
    var outputBookmark: Data?
    var cataloguePath: String?
    var catalogueBookmark: Data?
    var welcomed = false
    var guidePage: Int?

    static func initial() -> Workspace {
        var w = Workspace()
        let paths = [
            "00 Inbox/To sort", "10 Projects/Organization", "10 Projects/Client work", "10 Projects/Personal",
            "20 Areas/Organization/Finance", "20 Areas/Organization/Legal", "20 Areas/Organization/Operations",
            "20 Areas/Organization/Branding", "20 Areas/Personal/Administration", "20 Areas/Personal/Finance",
            "20 Areas/Personal/Health", "30 Resources/Research & Learning", "30 Resources/Books & Templates",
            "30 Resources/Design & Fabrication", "30 Resources/Personal collections/Movies",
            "40 Archive/Organization/Closed projects", "40 Archive/Personal/Family",
            "90 Review/Unclassified", "90 Review/Collisions", "90 Review/Reading exceptions"
        ]
        for path in paths {
            var parent: String?
            for name in path.split(separator: "/").map(String.init) {
                if let n = w.nodes.first(where: {$0.parent == parent && $0.name == name}) { parent = n.id }
                else { let n = FolderNode(parent: parent, name: name); w.nodes.append(n); parent = n.id }
            }
        }
        return w
    }

    func children(_ parent: String?) -> [FolderNode] { nodes.filter { $0.parent == parent } }
    func path(_ id: String) throws -> String {
        var result: [String] = [], cursor: String? = id, seen = Set<String>()
        while let current = cursor {
            guard seen.insert(current).inserted, let n = nodes.first(where: {$0.id == current}) else {
                throw KonMagicError("Invalid or cyclic folder structure.")
            }
            try Self.checkName(n.name); result.insert(n.name, at: 0); cursor = n.parent
        }
        return result.joined(separator: "/")
    }
    static func key(_ name: String) -> String { name.precomposedStringWithCanonicalMapping.lowercased() }
    static func checkName(_ name: String) throws {
        guard !name.isEmpty, name != ".", name != "..", !name.contains("/"), !name.contains(":"),
              !name.contains("\0"), name.utf8.count <= 240, !name.hasPrefix(".atlas-") else {
            throw KonMagicError("Use a visible folder or file name without slashes, colons or traversal.")
        }
    }
    func validate() throws {
        guard nodes.count <= 500, assignments.count <= 100 else { throw KonMagicError("Keep the structure below 500 destinations and the draft below 100 assignments.") }
        guard Set(nodes.map(\.id)).count == nodes.count else { throw KonMagicError("Duplicate folder identities.") }
        for n in nodes {
            _ = try path(n.id)
            guard children(n.parent).filter({Self.key($0.name) == Self.key(n.name)}).count == 1 else {
                throw KonMagicError("Two sibling folders collide by case or Unicode spelling.")
            }
        }
        guard output.hasPrefix("/"), !output.contains("\0") else { throw KonMagicError("Choose an absolute output folder.") }
        if let path=cataloguePath {_ = try SafeFS.components(path)}
        for a in assignments {
            _ = try path(a.node); try Self.checkName(a.outputName)
            guard a.source.hasPrefix("/"), !a.source.contains("\0") else { throw KonMagicError("Invalid source path.") }
        }
    }
    func destination(_ a: Assignment) throws -> String {
        URL(fileURLWithPath: output).appendingPathComponent(try path(a.node)).appendingPathComponent(a.outputName).path
    }
    mutating func assign(_ paths: [String], to node: String) throws {
        _ = try path(node)
        for p in paths {
            // Keep the exact chosen path. Foundation standardization can turn
            // /private/var into the /var symlink, invalidating no-follow checks.
            let source = p
            _ = try SafeFS.components(source)
            guard source != "/", !source.contains("\0") else { throw KonMagicError("Choose a file or an ordinary collection folder.") }
            if let i = assignments.firstIndex(where: {$0.source == source}) { assignments[i].node = node }
            else { assignments.append(Assignment(source: source, node: node, outputName: URL(fileURLWithPath: source).lastPathComponent, bookmark: try? URL(fileURLWithPath: source).bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil))) }
        }
        try validate()
    }
}

final class WorkspaceStore {
    let directory: URL
    let file: URL
    var value: Workspace
    private var undo: [Workspace] = []
    init(directory: URL) throws {
        self.directory = directory; file = directory.appendingPathComponent("workspace.json")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let directoryFD=try SafeFS.openDirectory(directory.path);defer {close(directoryFD)}
        var directoryInfo=stat()
        guard fstat(directoryFD,&directoryInfo)==0,directoryInfo.st_uid==getuid() else {throw KonMagicError("Workspace state must be an owned local directory.")}
        guard fchmod(directoryFD,0o700)==0 else {throw KonMagicError("Could not protect private workspace state.")}
        if FileManager.default.fileExists(atPath: file.path) {
            var s=stat();guard fstatat(directoryFD,"workspace.json",&s,AT_SYMLINK_NOFOLLOW)==0,SafeFS.isFile(s),s.st_uid==getuid(),s.st_size<=2*1024*1024 else {throw KonMagicError("Workspace state is not a small owned regular file.")}
            let fd=openat(directoryFD,"workspace.json",O_RDONLY|O_NOFOLLOW);guard fd>=0 else{throw KonMagicError("Could not safely read workspace state.")};defer {close(fd)}
            var bytes=[UInt8](repeating:0,count:Int(s.st_size)+1);let count=read(fd,&bytes,bytes.count)
            guard count==s.st_size else{throw KonMagicError("Workspace state changed or could not be fully read.")}
            value = try JSONDecoder().decode(Workspace.self, from: Data(bytes.prefix(count))); try value.validate()
        } else { value = .initial(); try persist() }
    }
    func persist() throws {
        try value.validate()
        let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys]
        try e.encode(value).write(to: file, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
    }
    func change(_ body: (inout Workspace) throws -> Void) throws {
        let prior = value; var next = prior; try body(&next); next.version += 1; try next.validate()
        value = next
        do { try persist(); undo.append(prior); if undo.count > 50 { undo.removeFirst() } }
        catch { value = prior; throw error }
    }
    func undoDraft() throws {
        guard let prior = undo.last else { throw KonMagicError("No draft edit to undo in this session.") }
        let current = value; value = prior
        do { try persist(); undo.removeLast() } catch { value = current; throw error }
    }
}
