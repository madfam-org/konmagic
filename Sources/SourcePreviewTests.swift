import Foundation
import Darwin

func runSourcePreviewTests(at directory:URL) throws -> Int {
    var checks=0
    func check(_ condition:Bool,_ message:String)throws {guard condition else {throw KonMagicError(message)};checks+=1}
    func refuses(_ body:()throws->Void)throws {do {try body()} catch {checks+=1;return};throw KonMagicError("Source preview should have held the synthetic source.")}
    let root=directory.appendingPathComponent("preview-fixture");try FileManager.default.createDirectory(at:root,withIntermediateDirectories:false)
    let file=root.appendingPathComponent("example.txt");try Data("Invented source preview".utf8).write(to:file)
    let a=try SourcePreviewSafety.inspect(file.path,allowFixture:true)
    try check(!a.directory && a.identity.bytes==23,"Source preview identifies a regular synthetic file without a body read.")
    try check(try SourcePreviewSafety.inspect(root.path,allowFixture:true).directory,"Source preview identifies an ordinary folder.")
    try refuses {_ = try SourcePreviewSafety.inspect(file.path)}
    let link=root.appendingPathComponent("linked.txt");try FileManager.default.createSymbolicLink(at:link,withDestinationURL:file)
    try refuses {_ = try SourcePreviewSafety.inspect(link.path,allowFixture:true)}
    let parentLink=directory.appendingPathComponent("preview-linked-parent");try FileManager.default.createSymbolicLink(at:parentLink,withDestinationURL:root)
    try refuses {_ = try SourcePreviewSafety.inspect(parentLink.appendingPathComponent("example.txt").path,allowFixture:true)}
    let secret=root.appendingPathComponent("private-key.pem");try Data("Synthetic refused content".utf8).write(to:secret)
    try refuses {_ = try SourcePreviewSafety.inspect(secret.path,allowFixture:true)}
    try check(try SourcePreviewSafety.inspect(file.path,expected:a.identity,allowFixture:true).identity==a.identity,"An unchanged preview identity remains eligible.")
    try Data("Changed invented source preview".utf8).write(to:file)
    try refuses {_ = try SourcePreviewSafety.inspect(file.path,expected:a.identity,allowFixture:true)}
    print("SOURCE_PREVIEW_TESTS passed=\(checks); synthetic metadata only; user-source operations=0")
    return checks
}
