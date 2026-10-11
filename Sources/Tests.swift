import Foundation
import Darwin

func runNativeTests() throws {
    let temp=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Caches/KonMagic Synthetic/"+UUID().uuidString)
    try FileManager.default.createDirectory(at:temp,withIntermediateDirectories:true,attributes:[.posixPermissions:0o700])
    defer {try? FileManager.default.removeItem(at:temp)} // Synthetic fixtures only.
    var checks=0
    func check(_ value:Bool,_ message:String)throws {guard value else{throw KonMagicError(message)};checks+=1}
    func refuses(_ message:String,_ operation:()throws->Void)throws {
        do {try operation()} catch {checks+=1;return};throw KonMagicError("Expected refusal: "+message)
    }
    func write(_ path:String,_ text:String)throws {try Data(text.utf8).write(to:URL(fileURLWithPath:path))}
    var w=Workspace.initial();w.output=temp.appendingPathComponent("output").path
    let dhanam=try w.nodes.first {try w.path($0.id)=="10 Projects/Organization"}!
    let aureo=try w.nodes.first {try w.path($0.id)=="40 Archive/Organization/Closed projects"}!
    try check(dhanam.id != aureo.id,"Active projects must stay separate from archived work")
    try w.validate();checks+=1
    try refuses("sibling case collision") {var x=w;x.nodes.append(FolderNode(parent:dhanam.parent,name:dhanam.name.lowercased()));try x.validate()}
    try refuses("Unicode collision") {var x=w;let p=x.nodes.first!.id;x.nodes.append(FolderNode(parent:p,name:"Café"));x.nodes.append(FolderNode(parent:p,name:"Cafe\u{301}"));try x.validate()}
    try refuses("traversal") {try Workspace.checkName("../outside")}
    try refuses("cycle") {var x=w;x.nodes[0].parent=x.nodes[0].id;try x.validate()}
    let src=temp.appendingPathComponent("Source bucket");try FileManager.default.createDirectory(at:src.appendingPathComponent("Empty"),withIntermediateDirectories:true)
    try FileManager.default.createDirectory(at:src.appendingPathComponent("Nested"),withIntermediateDirectories:true)
    try write(src.appendingPathComponent("note.txt").path,"Synthetic historical planning note.")
    try write(src.appendingPathComponent("Nested/bytes.txt").path,"Nested bytes must remain intact.")
    let attr="org.madfam.konmagic.fixture",value="preserved"
    try value.withCString {bytes in guard setxattr(src.path,attr,bytes,strlen(bytes),0,0)==0 else{throw SafeFS.fail("Cannot set synthetic directory attribute")}}
    let original=try SafeFS.inspect(src.path,allowFixture:true)
    print("NATIVE_TEST_STAGE: synthetic tree inspected")
    try w.assign([src.path],to:dhanam.id)
    let destination=try w.destination(w.assignments[0])
    let p=try SafeFS.preview(w,allowFixture:true)
    print("NATIVE_TEST_STAGE: read-only preview prepared")
    try check(!FileManager.default.fileExists(atPath:w.output),"Preview must not create any destination")
    try check(p.fileCount==2 && p.buckets[0].records.count==5,"All nested files and empty directories must be accounted for")
    try check(p.buckets[0].destination==destination,"Manual destination must override any inferred source context")
    let store=try WorkspaceStore(directory:temp.appendingPathComponent("state"))
    let old=store.value;try store.change {$0.nodes.append(FolderNode(parent:nil,name:"Custom collection"))};try store.undoDraft()
    try check(store.value.nodes==old.nodes,"Draft undo restores structure without source operations")
    try check(try SafeFS.inspect(src.path,allowFixture:true)==original,"Draft edits must not change originals")
    try refuses("source bucket and child overlap") {var x=w;try x.assign([src.appendingPathComponent("note.txt").path],to:aureo.id);_ = try SafeFS.preview(x,allowFixture:true)}
    try refuses("output inside source") {var x=w;x.output=src.appendingPathComponent("bad-output").path;_ = try SafeFS.preview(x,allowFixture:true)}
    let link=temp.appendingPathComponent("linked.txt");try FileManager.default.createSymbolicLink(at:link,withDestinationURL:src.appendingPathComponent("note.txt"))
    try refuses("source symlink") {_ = try SafeFS.inspect(link.path,allowFixture:true)}
    let linkedParent=temp.appendingPathComponent("linked-parent");try FileManager.default.createSymbolicLink(at:linkedParent,withDestinationURL:src)
    try refuses("ancestor symlink") {_ = try SafeFS.inspect(linkedParent.appendingPathComponent("note.txt").path,allowFixture:true)}
    let secret=temp.appendingPathComponent("recovery-phrase.pdf");try write(secret.path,"Do not open this fixture body during inspection.")
    try refuses("credential filename") {_ = try SafeFS.inspect(secret.path,allowFixture:true)}
    let project=temp.appendingPathComponent("project");try FileManager.default.createDirectory(at:project,withIntermediateDirectories:true);try write(project.appendingPathComponent("package.json").path,"{}")
    try refuses("project cohesion") {_ = try SafeFS.inspect(project.path,allowFixture:true)}
    let large=temp.appendingPathComponent("large.mov");let fd=open(large.path,O_RDWR|O_CREAT|O_EXCL,0o600)
    guard fd>=0 else{throw SafeFS.fail("Cannot create sparse synthetic fixture")};guard ftruncate(fd,SafeFS.byteLimit+1)==0 else{close(fd);throw SafeFS.fail("Sparse fixture failed")};close(fd)
    var lw=w;lw.assignments=[];try lw.assign([large.path],to:dhanam.id)
    let start=Date();try refuses("capacity before hashing") {_ = try SafeFS.preview(lw,allowFixture:true)}
    try check(Date().timeIntervalSince(start)<3,"Oversized transfer must be held by metadata before reading a sparse body")
    let journal=temp.appendingPathComponent("receipts")
    let receipt=try SafeFS.copy(p,workspace:w,journalDirectory:journal,allowFixture:true)
    print("NATIVE_TEST_STAGE: synthetic bucket copied and journaled")
    try check(FileManager.default.fileExists(atPath:receipt.path),"Copy requires a durable receipt")
    try check(try SafeFS.inspect(src.path,allowFixture:true)==original,"Copy leaves all source identities and hashes intact")
    let destRecords=try SafeFS.inspect(destination,allowFixture:true)
    try check(destRecords.map(\.relative)==original.map(\.relative) && destRecords.map(\.hash)==original.map(\.hash),"Copy preserves empty folders, hierarchy and full byte hashes")
    var buffer=[CChar](repeating:0,count:64);let n=getxattr(destination,attr,&buffer,buffer.count,0,0)
    try check(n==value.utf8.count && String(cString:buffer)==value,"Folder extended attributes survive verified copy")
    try refuses("no overwrite on reapplication") {_ = try SafeFS.copy(p,workspace:w,journalDirectory:journal,allowFixture:true)}
    let fresh=temp.appendingPathComponent("fresh.txt");try write(fresh.path,"before")
    var changed=w;changed.assignments=[];changed.output=temp.appendingPathComponent("held-output").path;try changed.assign([fresh.path],to:dhanam.id)
    let stale=try SafeFS.preview(changed,allowFixture:true);try write(fresh.path,"after!")
    try refuses("changed source") {_ = try SafeFS.copy(stale,workspace:changed,journalDirectory:journal,allowFixture:true)}
    try check(!FileManager.default.fileExists(atPath:changed.output),"Stale preflight cannot create output")
    var renamed=w;renamed.output=temp.appendingPathComponent("renamed-output").path
    try refuses("changed structure invalidates plan") {_ = try SafeFS.copy(p,workspace:renamed,journalDirectory:journal,allowFixture:true)}
    let collisions=temp.appendingPathComponent("collision");try FileManager.default.createDirectory(at:collisions,withIntermediateDirectories:true);try write(collisions.appendingPathComponent("File.TXT").path,"unique")
    try refuses("case-insensitive target collision") {try SafeFS.destinationClear(collisions.appendingPathComponent("file.txt").path)}
    try check(String(data:try Data(contentsOf:collisions.appendingPathComponent("File.TXT")),encoding:.utf8)=="unique","Existing collision bytes remain intact")
    let browsing=temp.appendingPathComponent("browsing");try FileManager.default.createDirectory(at:browsing,withIntermediateDirectories:true)
    for i in 0..<205 {try write(browsing.appendingPathComponent(String(format:"file-%03d.txt",i)).path,"Synthetic only")}
    try write(browsing.appendingPathComponent(".hidden-note.txt").path,"Synthetic hidden fixture")
    let library=Catalog(path:temp.appendingPathComponent("missing-catalogue.sqlite3").path)
    try check(try library.liveFolder(browsing.path).count==200 && library.liveFolder(browsing.path,offset:200).count==5,"Folder pages work without an external catalogue")
    let matches=try library.liveFolder(browsing.path,search:"FILE-204")
    try check(matches.count==1 && matches[0].name=="file-204.txt","Current-folder name search works without a catalogue")
    try check(try library.liveFolder(browsing.path,search:"hidden").isEmpty && library.liveFolder(browsing.path,search:"hidden",includeHidden:true).count==1,"Hidden entries are available only when explicitly included")
    try check(try library.liveFolder(browsing.path,offset:999).isEmpty,"End-of-folder pages are safely empty")
    checks += try runCatalogueTests(at:temp)
    checks += try runLensTests(at:temp)
    checks += try runReviewTests(at:temp)
    print("NATIVE_SAFETY_TESTS passed=\(checks); synthetic fixtures only; actual user-source operations=0")
}
