import AppKit

// Only static public routes leave the app. Never append a source path, query,
// catalogue identifier or diagnostic receipt to a documentation URL.
enum KonMagicDocumentation {
    static let base = URL(string:"https://madfam-org.github.io/konmagic/")!
    static func route(_ page:KonMagicPage)->String {
        switch page {
        case .toolkit:return "guide/getting-started/"
        case .storage:return "guide/storage/"
        case .content:return "guide/content/"
        case .structure:return "guide/structure/"
        case .review:return "guide/review/"
        }
    }
    static func open(_ route:String="") {NSWorkspace.shared.open(base.appendingPathComponent(route))}
}

extension KonMagicNavigation {
    @objc func showDocumentation() {KonMagicDocumentation.open()}
    @objc func showPageDocumentation() {
        if active.current?.controller is SourcePreviewController {KonMagicDocumentation.open("guide/previews/")}
        else if active.current?.controller is ScanComparisonController || active.current?.controller is DuplicateReviewController {KonMagicDocumentation.open("guide/evidence/")}
        else {KonMagicDocumentation.open(KonMagicDocumentation.route(active.current?.base ?? .toolkit))}
    }
    @objc func showDeveloperDocumentation() {KonMagicDocumentation.open("developer/architecture/")}
}
