import AppKit
import Foundation

if CommandLine.arguments.contains("--self-test") {
    do {try runNativeTests();exit(0)} catch {fputs("Native safety test failed: \(error.localizedDescription)\n",stderr);exit(1)}
}
if CommandLine.arguments.contains("--catalog-smoke") {
    do {
        let c=Catalog(path:FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Workstation Atlas/catalog.sqlite3").path)
        for scope in ["Downloads","Desktop","Documents"] {
            let path=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(scope).path
            let liveStart=Date(),liveRows=try c.liveFolder(path)
            print("LIVE_FOLDER_QA \(scope): rows=\(liveRows.count), milliseconds=\(Int(Date().timeIntervalSince(liveStart)*1000))")
            let t=Date(),rows=try c.query(scope:path,search:"")
            print("CATALOG_QA \(scope): rows=\(rows.count), milliseconds=\(Int(Date().timeIntervalSince(t)*1000))")
        }
        exit(0)
    } catch {fputs("Catalogue check: \(error.localizedDescription)\n",stderr);exit(1)}
}
let application=NSApplication.shared
let delegate=KonMagicDelegate(qa:CommandLine.arguments.contains("--ui-smoke"))
application.delegate=delegate
application.setActivationPolicy(.regular)
application.run()
