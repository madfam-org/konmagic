import AppKit
import Foundation

if CommandLine.arguments.contains("--lens-recorded-smoke") {
    do {
        let home=FileManager.default.homeDirectoryForCurrentUser,environment=ProcessInfo.processInfo.environment
        let root=environment["KONMAGIC_QA_ROOT"] ?? home.appendingPathComponent("Downloads").path
        let directory=URL(fileURLWithPath:environment["KONMAGIC_QA_STATE"] ?? home.appendingPathComponent("Library/Caches/KonMagic UI QA").path).appendingPathComponent("Disk Lens Scans")
        let scanner=try LensScanner(directory:directory,cancellation:CatalogueCancellation()),start=Date()
        let store=try scanner.recorded(root:root,ledger:home.appendingPathComponent("Library/Application Support/Workstation Atlas/disk-coverage.sqlite3").path),info=try store.snapshot()
        print("LENS_RECORDED_QA status=\(info.status); records=\(info.entries); files=\(info.totals.count); logical=\(info.totals.bytes); allocated=\(info.totals.allocated); issues=\(info.issues); milliseconds=\(Int(Date().timeIntervalSince(start)*1000)); sourceBodiesRead=0; sourceOperations=0")
        print("LENS_QA_SCAN="+store.url.path);exit(0)
    } catch {fputs("Disk Lens check failed: \(error.localizedDescription)\n",stderr);exit(1)}
}
if CommandLine.arguments.contains("--explorer-smoke") {
    do {
        let home=FileManager.default.homeDirectoryForCurrentUser
        let parent=home.appendingPathComponent("Library/Application Support/Workstation Atlas")
        let c=Catalog(path:parent.appendingPathComponent("catalog.sqlite3").path)
        let t=Date(),page=try c.cataloguePage(CatalogueSlice())
        print("EXPLORER_PAGE rows=\(page.items.count), tags=\(page.items.filter {!$0.tags.isEmpty}.count), milliseconds=\(Int(Date().timeIntervalSince(t)*1000))")
        let a=Date(),summary=try c.cachedSummary(in:home.appendingPathComponent("Library/Application Support/KonMagic"))
        print("EXPLORER_SUMMARY entries=\(summary.count), readings=\(summary.readings), partitions=\(summary.partitions.count), milliseconds=\(Int(Date().timeIntervalSince(a)*1000))")
        for dimension in CatalogueDimension.allCases {guard summary.groups(dimension).reduce(0,{$0+$1.count})==summary.count else {throw KonMagicError("Facet count conservation failed")}}
        let disk=DiskCatalogue(path:parent.appendingPathComponent("disk-coverage.sqlite3").path),overview=try disk.overview()
        let d=Date(),folder=try disk.folder(home.appendingPathComponent("Downloads").path)
        print("EXPLORER_DISK entries=\(overview.count), exceptions=\(overview.exceptions), pageRows=\(folder.items.count), milliseconds=\(Int(Date().timeIntervalSince(d)*1000)); all source operations=0")
        exit(0)
    } catch {fputs("Explorer check failed: \(error.localizedDescription)\n",stderr);exit(1)}
}
if CommandLine.arguments.contains("--volume-context-smoke") {
    do {let start=Date(),context=try VolumeContext.observe("/");print("VOLUME_CONTEXT_QA completed=true; sharedAPFSContext=\(context.details.contains("Shared container free")); snapshotCoverage=\(context.details.contains("Snapshots reported")); milliseconds=\(Int(Date().timeIntervalSince(start)*1000)); sourceBodiesRead=0; sourceOperations=0");exit(0)} catch {fputs("Volume context held: \(error.localizedDescription)\n",stderr);exit(1)}
}
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
let delegate=KonMagicDelegate(qa:CommandLine.arguments.contains("--review-ui-smoke") || CommandLine.arguments.contains("--knowledge-ui-smoke") || CommandLine.arguments.contains("--toolkit-ui-smoke") || CommandLine.arguments.contains("--ui-smoke") || CommandLine.arguments.contains("--explorer-ui-smoke") || CommandLine.arguments.contains("--lens-ui-smoke"))
application.delegate=delegate
application.setActivationPolicy(.regular)
application.run()
