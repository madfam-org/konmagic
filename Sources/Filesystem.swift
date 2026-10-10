import Foundation
import Darwin
import CryptoKit

struct Identity: Codable, Equatable {
    let device: Int64, inode: UInt64, bytes: Int64, mode: UInt16
    let modified: Int64, modifiedNano: Int64, changed: Int64, changedNano: Int64
    init(_ s: stat) {
        device = Int64(s.st_dev); inode = UInt64(s.st_ino); bytes = s.st_size; mode = s.st_mode
        modified = Int64(s.st_mtimespec.tv_sec); modifiedNano = Int64(s.st_mtimespec.tv_nsec)
        changed = Int64(s.st_ctimespec.tv_sec); changedNano = Int64(s.st_ctimespec.tv_nsec)
    }
}
struct FileRecord: Codable, Equatable {
    let relative: String
    let directory: Bool
    let identity: Identity
    let hash: String?
}
struct BucketPlan: Codable {
    let assignment: Assignment
    let destination: String
    let records: [FileRecord]
    let bytes: Int64
}
struct CopyPlan: Codable {
    let id: String
    let prepared: Date
    let workspaceHash: String
    let output: String
    let outputAnchor: OutputAnchor
    let buckets: [BucketPlan]
    let bytes: Int64
    var fileCount: Int { buckets.flatMap(\.records).filter {!$0.directory}.count }
}
struct OutputAnchor: Codable, Equatable {
    let path:String
    let device:Int64
    let inode:UInt64
}

enum SafeFS {
    static let fileLimit = 5000
    static let byteLimit: Int64 = 100 * 1024 * 1024 * 1024
    static let reserve: Int64 = 10 * 1024 * 1024 * 1024
    static func fail(_ text: String) -> KonMagicError { KonMagicError(text + " (" + String(cString: strerror(errno)) + ")") }
    static func components(_ path: String) throws -> [String] {
        guard path.hasPrefix("/"), !path.contains("\0") else { throw KonMagicError("Use an absolute local path.") }
        let result = path.split(separator: "/").map(String.init)
        guard !result.contains(".."), !result.contains(".") else { throw KonMagicError("Traversal paths are held.") }
        return result
    }
    static func openDirectory(_ path: String, create: Bool = false) throws -> Int32 {
        var fd = open("/", O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
        guard fd >= 0 else { throw fail("Cannot open filesystem root") }
        do {
            for component in try components(path) {
                if create {
                    let matches = try names(fd).filter { Workspace.key($0) == Workspace.key(component) }
                    if !matches.isEmpty && matches != [component] { throw KonMagicError("Case or Unicode destination collision.") }
                    if mkdirat(fd, component, 0o700) != 0 && errno != EEXIST { throw fail("Cannot create reviewed destination directory") }
                }
                let next = openat(fd, component, O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
                guard next >= 0 else { throw fail("Folder access denied or a symlink boundary was encountered at component '"+component+"'") }
                close(fd); fd = next
            }
            return fd
        } catch { close(fd); throw error }
    }
    static func names(_ fd: Int32) throws -> [String] {
        // openat(".") has its own directory offset; dup would share a prior scan's offset.
        let copy = openat(fd, ".", O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
        guard copy >= 0, let dir = fdopendir(copy) else { if copy >= 0 { close(copy) }; throw fail("Cannot list folder") }
        defer { closedir(dir) }
        var result: [String] = []
        errno = 0
        while let entry = readdir(dir) {
            let n = withUnsafePointer(to: &entry.pointee.d_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN)+1) { String(cString: $0) }
            }
            if n != "." && n != ".." { result.append(n) }
            if result.count > 100_000 { throw KonMagicError("Folder has too many direct entries for an interactive batch.") }
            errno = 0
        }
        if errno != 0 { throw fail("Incomplete directory enumeration") }
        return result.sorted()
    }
    static func info(_ fd: Int32, _ name: String) throws -> stat {
        var s = stat()
        guard fstatat(fd,name,&s,AT_SYMLINK_NOFOLLOW) == 0 else { throw fail("Cannot read current identity") }
        guard (s.st_flags & 0x40000000) == 0 else { throw KonMagicError("Cloud placeholder held; no download was requested.") }
        return s
    }
    static func isDirectory(_ s: stat) -> Bool { (s.st_mode & S_IFMT) == S_IFDIR }
    static func isFile(_ s: stat) -> Bool { (s.st_mode & S_IFMT) == S_IFREG }
    static func hash(_ fd: Int32) throws -> String {
        var before = stat(); guard fstat(fd,&before)==0, isFile(before), lseek(fd,0,SEEK_SET)>=0 else { throw fail("Cannot hash regular source") }
        var h = SHA256(), buffer = [UInt8](repeating:0,count:1024*1024)
        while true {
            let n = read(fd,&buffer,buffer.count)
            if n == 0 { break }; if n < 0 { if errno == EINTR { continue }; throw fail("Incomplete source read") }
            h.update(data: Data(buffer.prefix(n)))
        }
        var after = stat(); guard fstat(fd,&after)==0, Identity(before)==Identity(after) else { throw KonMagicError("File changed during hashing.") }
        guard lseek(fd,0,SEEK_SET)>=0 else { throw fail("Cannot rewind file") }
        return h.finalize().map { String(format:"%02x",$0) }.joined()
    }
    static func guardedName(_ name: String) -> Bool {
        let n = name.lowercased()
        let exact: Set<String> = [".git",".obsidian",".ssh",".gnupg",".aws",".kube","credentials","secrets","node_modules",".venv","venv","library","cloudstorage","mobile documents",".atlas-recovery"]
        if exact.contains(n) || n.hasPrefix(".env") || n.hasPrefix(".atlas-stage-") { return true }
        if [".app",".photoslibrary",".musiclibrary",".imovielibrary",".band",".key",".pem",".keychain-db",".revo"].contains(where:{n.hasSuffix($0)}) { return true }
        return n.range(of:"password|credential|recovery[ _.-]*(phrase|key|code)|private[ _.-]*key|^fiel_|^csd_",options:.regularExpression) != nil
    }
    static func sourceGuard(_ path: String) throws {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let allowed = ["Desktop","Documents","Downloads","Pictures","Music","Movies"].map {home+"/"+$0+"/"}
        guard allowed.contains(where:{path.hasPrefix($0)}), !(try components(path)).contains(where:guardedName) else {
            throw KonMagicError("Keep system, app, cloud, credential and source-workspace collections in place. Select ordinary user files or folders.")
        }
        var ancestor=URL(fileURLWithPath:path).deletingLastPathComponent()
        while ancestor.path.hasPrefix(home+"/") {
            let fd=try openDirectory(ancestor.path);defer {close(fd)}
            for marker in [".git",".obsidian","package.json","pyproject.toml","Cargo.toml","go.mod","CMakeLists.txt","metadata.db"] {
                var s=stat()
                if fstatat(fd,marker,&s,AT_SYMLINK_NOFOLLOW)==0 {throw KonMagicError("File belongs to an operational project or managed library. Keep its collection in place.")}
                if errno != ENOENT {throw fail("Cannot verify collection boundary")}
            }
            ancestor.deleteLastPathComponent()
        }
    }
    static func inspect(_ path: String, allowFixture: Bool = false, hashing: Bool = true) throws -> [FileRecord] {
        if !allowFixture { try sourceGuard(path) }
        let parent = URL(fileURLWithPath:path).deletingLastPathComponent().path
        let name = URL(fileURLWithPath:path).lastPathComponent
        let parentFD = try openDirectory(parent); defer { close(parentFD) }
        var result: [FileRecord] = [], total: Int64 = 0
        func visit(_ pfd: Int32, _ name: String, _ relative: String, _ depth: Int) throws {
            guard depth <= 48, !guardedName(name) else { throw KonMagicError("Protected name or excessive nesting: collection retained intact.") }
            let s = try info(pfd,name)
            guard result.count < fileLimit else { throw KonMagicError("The batch exceeds 5,000 entries. Choose a smaller bucket.") }
            if isDirectory(s) {
                let fd = openat(pfd,name,O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
                guard fd >= 0 else { throw fail("Cannot safely open source folder") }; defer {close(fd)}
                var opened = stat(); guard fstat(fd,&opened)==0, Identity(opened)==Identity(s) else { throw KonMagicError("Source folder identity changed.") }
                let children = try names(fd)
                guard !children.contains(where:{["package.json","pyproject.toml","Cargo.toml","go.mod","CMakeLists.txt","metadata.db"].contains($0)}) else {
                    throw KonMagicError("Recognized operational project or managed library: keep the collection in place.")
                }
                result.append(FileRecord(relative:relative,directory:true,identity:Identity(s),hash:nil))
                for child in children { try visit(fd,child,relative.isEmpty ? child : relative+"/"+child,depth+1) }
                var after = stat(); guard fstat(fd,&after)==0, Identity(after)==Identity(s), try names(fd)==children else { throw KonMagicError("Folder changed during its preview.") }
            } else {
                guard isFile(s) else { throw KonMagicError("Symlinks and special files are held; no source was followed.") }
                total += s.st_size; guard total <= byteLimit else { throw KonMagicError("Choose a bucket below 100 GiB for a bounded transfer.") }
                if !hashing { result.append(FileRecord(relative:relative,directory:false,identity:Identity(s),hash:nil)); return }
                let fd = openat(pfd,name,O_RDONLY | O_NOFOLLOW | O_NONBLOCK)
                guard fd >= 0 else { throw fail("Cannot safely open source file") }; defer {close(fd)}
                var opened = stat(); guard fstat(fd,&opened)==0, Identity(opened)==Identity(s) else { throw KonMagicError("Source identity changed.") }
                result.append(FileRecord(relative:relative,directory:false,identity:Identity(s),hash:try hash(fd)))
            }
        }
        try visit(parentFD,name,"",0)
        return result
    }
    static func destinationClear(_ path: String) throws {
        let parts = try components(path); var fd = open("/",O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
        guard fd >= 0 else { throw fail("Cannot check destination") }; defer {close(fd)}
        for (i,n) in parts.enumerated() {
            let matches = try names(fd).filter {Workspace.key($0)==Workspace.key(n)}
            if matches.isEmpty { return }
            guard matches == [n], i < parts.count-1 else { throw KonMagicError("Destination already exists or collides by case/Unicode. Rename the draft; no overwrite is allowed.") }
            let next = openat(fd,n,O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
            guard next >= 0 else { throw fail("Destination crosses an inaccessible or linked folder") }; close(fd); fd=next
        }
    }
    static func available(_ path: String) throws -> Int64 {
        var candidate = URL(fileURLWithPath:path)
        while !FileManager.default.fileExists(atPath:candidate.path) && candidate.path != "/" { candidate.deleteLastPathComponent() }
        let fd = try openDirectory(candidate.path); defer {close(fd)}
        var v = statfs(); guard fstatfs(fd,&v)==0 else { throw fail("Cannot check free space") }
        guard v.f_flags & UInt32(MNT_LOCAL) != 0, v.f_flags & UInt32(MNT_RDONLY) == 0 else { throw KonMagicError("Choose a writable local output volume.") }
        return Int64(v.f_bavail)*Int64(v.f_bsize)
    }
    static func anchor(_ path:String) throws -> OutputAnchor {
        var u=URL(fileURLWithPath:path)
        while !FileManager.default.fileExists(atPath:u.path) && u.path != "/" {u.deleteLastPathComponent()}
        let fd=try openDirectory(u.path);defer {close(fd)};var s=stat()
        guard fstat(fd,&s)==0 else {throw fail("Cannot pin output location")}
        return OutputAnchor(path:u.path,device:Int64(s.st_dev),inode:UInt64(s.st_ino))
    }
    static func validateAnchor(_ a:OutputAnchor) throws {
        let fd=try openDirectory(a.path);defer {close(fd)};var s=stat()
        guard fstat(fd,&s)==0,Int64(s.st_dev)==a.device,UInt64(s.st_ino)==a.inode else {throw KonMagicError("Output location or mounted volume changed. Generate a new preview.")}
    }
    static func workspaceHash(_ w: Workspace) throws -> String {
        let e = JSONEncoder(); e.outputFormatting = [.sortedKeys]
        return SHA256.hash(data:try e.encode(w)).map {String(format:"%02x",$0)}.joined()
    }
    static func preview(_ w: Workspace, allowFixture: Bool = false) throws -> CopyPlan {
        try w.validate(); guard !w.assignments.isEmpty else { throw KonMagicError("Assign drops or buckets to destinations first.") }
        if !allowFixture {
            guard !(try components(w.output)).contains(where:guardedName) else { throw KonMagicError("Choose an ordinary local output folder outside managed, cloud and credential locations.") }
        }
        let sourcePaths = w.assignments.map(\.source).sorted()
        for i in sourcePaths.indices {
            for j in sourcePaths.indices where i != j {
                if sourcePaths[j].hasPrefix(sourcePaths[i]+"/") { throw KonMagicError("A bucket and its child overlap. Assign the whole bucket or its children, not both.") }
            }
        }
        var buckets: [BucketPlan] = [], targets = Set<String>(), bytes: Int64 = 0, count = 0
        for a in w.assignments {
            let target = try w.destination(a)
            guard targets.insert(Workspace.key(target)).inserted,
                  !target.hasPrefix(a.source+"/"), target != a.source,
                  !a.source.hasPrefix(w.output+"/"), !w.output.hasPrefix(a.source+"/") else {
                throw KonMagicError("Source/output overlap or duplicate destination. Adjust the draft.")
            }
            for existing in targets where existing != Workspace.key(target) {
                if existing.hasPrefix(Workspace.key(target)+"/") || Workspace.key(target).hasPrefix(existing+"/") {
                    throw KonMagicError("One proposed destination contains another. Choose non-overlapping buckets.")
                }
            }
            try destinationClear(target)
            let records = try inspect(a.source,allowFixture:allowFixture,hashing:false)
            let size = records.filter {!$0.directory}.reduce(Int64(0)) {$0+$1.identity.bytes}
            bytes += size; count += records.count
            guard bytes <= byteLimit, count <= fileLimit else { throw KonMagicError("Combined batch exceeds 100 GiB or 5,000 entries.") }
            buckets.append(BucketPlan(assignment:a,destination:target,records:records,bytes:size))
        }
        guard try available(w.output)-bytes > reserve else { throw KonMagicError("Copy would cross the 10 GiB free-space reserve.") }
        // Reject insufficient capacity using metadata before reading any file bodies.
        for i in buckets.indices {
            let b = buckets[i], records = try inspect(b.assignment.source,allowFixture:allowFixture)
            guard records.map({FileRecord(relative:$0.relative,directory:$0.directory,identity:$0.identity,hash:nil)}) == b.records else { throw KonMagicError("Source changed during preview verification.") }
            buckets[i] = BucketPlan(assignment:b.assignment,destination:b.destination,records:records,bytes:b.bytes)
        }
        return CopyPlan(id:UUID().uuidString,prepared:Date(),workspaceHash:try workspaceHash(w),output:w.output,outputAnchor:try anchor(w.output),buckets:buckets,bytes:bytes)
    }
    static func writeRecord<T: Encodable>(_ value: T, at url: URL) throws {
        let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted,.sortedKeys]; e.dateEncodingStrategy = .iso8601
        try e.encode(value).write(to:url,options:.atomic)
        try FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:url.path)
        let fd = open(url.path,O_RDONLY | O_NOFOLLOW); guard fd >= 0 else { throw fail("Cannot flush operation journal") }; defer {close(fd)}
        guard fsync(fd)==0 else { throw fail("Cannot durably save journal") }
        let parent = try openDirectory(url.deletingLastPathComponent().path); defer {close(parent)}
        guard fsync(parent)==0 else { throw fail("Cannot flush journal directory") }
    }
    static func copy(_ plan: CopyPlan, workspace: Workspace, journalDirectory: URL, allowFixture: Bool = false) throws -> URL {
        guard try workspaceHash(workspace)==plan.workspaceHash else { throw KonMagicError("Draft changed. Generate a new exact preview.") }
        try validateAnchor(plan.outputAnchor)
        // Full preflight of the entire batch before creating anything in the output.
        for b in plan.buckets {
            guard try inspect(b.assignment.source,allowFixture:allowFixture)==b.records else { throw KonMagicError("Source changed. Nothing applied; refresh the preview.") }
            try destinationClear(b.destination)
        }
        guard try available(plan.output)-plan.bytes > reserve else { throw KonMagicError("Free-space reserve changed; batch held.") }
        try FileManager.default.createDirectory(at:journalDirectory,withIntermediateDirectories:true,attributes:[.posixPermissions:0o700])
        let receipt = journalDirectory.appendingPathComponent(plan.id+".json")
        guard !FileManager.default.fileExists(atPath:receipt.path) else { throw KonMagicError("This plan already has a receipt. Inspect recovery history and generate a new preview.") }
        struct Receipt: Codable { let plan: CopyPlan; var status: String; var completed: [String]; var retainedStages: [String]; var message: String }
        var journal = Receipt(plan:plan,status:"started",completed:[],retainedStages:[],message:"Copy-first. Original files remain intact.")
        try writeRecord(journal,at:receipt)
        do {
            for bucket in plan.buckets {
                try validateAnchor(plan.outputAnchor)
                let targetURL = URL(fileURLWithPath:bucket.destination)
                let parentPath = targetURL.deletingLastPathComponent().path
                let parent = try openDirectory(parentPath,create:true); defer {close(parent)}
                guard !(try names(parent)).contains(where:{Workspace.key($0)==Workspace.key(targetURL.lastPathComponent)}) else { throw KonMagicError("Destination appeared during execution; batch stopped without overwrite.") }
                let stage = ".atlas-stage-"+UUID().uuidString
                guard mkdirat(parent,stage,0o700)==0 else { throw fail("Cannot create private staging folder") }
                let stagePath = parentPath+"/"+stage
                journal.retainedStages.append(stagePath); try writeRecord(journal,at:receipt)
                let contentPath = stagePath+"/"+bucket.assignment.outputName
                for record in bucket.records {
                    let sourcePath = record.relative.isEmpty ? bucket.assignment.source : bucket.assignment.source+"/"+record.relative
                    let copyPath = record.relative.isEmpty ? contentPath : contentPath+"/"+record.relative
                    if record.directory {
                        let fd = try openDirectory(copyPath,create:true); close(fd); continue
                    }
                    let sp = try openDirectory(URL(fileURLWithPath:sourcePath).deletingLastPathComponent().path); defer {close(sp)}
                    let current = try info(sp,URL(fileURLWithPath:sourcePath).lastPathComponent)
                    guard Identity(current)==record.identity else { throw KonMagicError("Source changed during copying; staged bytes retained.") }
                    let sf = openat(sp,URL(fileURLWithPath:sourcePath).lastPathComponent,O_RDONLY | O_NOFOLLOW | O_NONBLOCK)
                    guard sf >= 0 else { throw fail("Cannot open source for verified copy") }; defer {close(sf)}
                    var opened = stat(); guard fstat(sf,&opened)==0,Identity(opened)==record.identity else { throw KonMagicError("Source raced during opening.") }
                    let dp = try openDirectory(URL(fileURLWithPath:copyPath).deletingLastPathComponent().path); defer {close(dp)}
                    let df = openat(dp,URL(fileURLWithPath:copyPath).lastPathComponent,O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW,0o600)
                    guard df >= 0 else { throw fail("Cannot create exclusive staged copy") }; defer {close(df)}
                    guard fcopyfile(sf,df,nil,copyfile_flags_t(COPYFILE_ALL))==0, fsync(df)==0 else { throw fail("Metadata-preserving copy failed; stage retained") }
                    guard try hash(df)==record.hash, try hash(sf)==record.hash else { throw KonMagicError("Hash verification failed; staged bytes retained and originals unchanged.") }
                    var after = stat(); guard fstat(sf,&after)==0, Identity(after)==record.identity else { throw KonMagicError("Source changed during copy verification.") }
                }
                // Preserve directory ACLs, extended attributes and stat after children are written.
                for record in bucket.records.reversed() where record.directory {
                    let sourcePath = record.relative.isEmpty ? bucket.assignment.source : bucket.assignment.source+"/"+record.relative
                    let copyPath = record.relative.isEmpty ? contentPath : contentPath+"/"+record.relative
                    let sourceFD = try openDirectory(sourcePath); defer {close(sourceFD)}
                    let copyFD = try openDirectory(copyPath); defer {close(copyFD)}
                    guard fcopyfile(sourceFD,copyFD,nil,copyfile_flags_t(COPYFILE_METADATA))==0 else { throw fail("Directory metadata copy failed; stage retained") }
                }
                // A bucket is published only after every file and the source tree were reverified.
                guard try inspect(bucket.assignment.source,allowFixture:allowFixture)==bucket.records else { throw KonMagicError("Bucket changed during copying; verified stage retained.") }
                guard !(try names(parent)).contains(where:{Workspace.key($0)==Workspace.key(targetURL.lastPathComponent)}) else { throw KonMagicError("Late destination collision; verified stage retained.") }
                journal.status="publishing"; journal.message="Publishing "+bucket.destination; try writeRecord(journal,at:receipt)
                let sf = try openDirectory(stagePath); defer {close(sf)}
                guard renameatx_np(sf,bucket.assignment.outputName,parent,targetURL.lastPathComponent,UInt32(RENAME_EXCL))==0 else { throw fail("Exclusive publication failed; stage retained") }
                guard fsync(parent)==0 else { throw fail("Published copy needs journal recovery") }
                journal.completed.append(bucket.destination); journal.status="copying"; try writeRecord(journal,at:receipt)
                // Empty stage directories intentionally remain; no data-removal primitive exists here.
            }
            journal.status="completed"; journal.message="All destination bytes hash-verified; originals retained."; try writeRecord(journal,at:receipt)
            return receipt
        } catch {
            journal.status="needs_review"; journal.message=error.localizedDescription
            try? writeRecord(journal,at:receipt)
            throw KonMagicError(error.localizedDescription+"\nReceipt: "+receipt.path+"\nEarlier published copies and staging folders are retained.")
        }
    }
}
