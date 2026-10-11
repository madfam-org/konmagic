import AppKit

// Placement is a draft calculation: no bookmarks, source reads or output writes.
struct PlacementPair {
    let source:String,destination:String,kind:String
}
struct PlacementPreview {
    let pairs:[PlacementPair]
    let newAssignments:Int
    let exceedsCapacity:Bool
    static func make(_ items:[CatalogItem],node:String,workspace:Workspace) throws -> PlacementPreview {
        guard !items.isEmpty,items.count<=200,items.allSatisfy({$0.kind=="file" || $0.kind=="directory"}) else {throw KonMagicError("Select up to 200 real files or folders to preview their destinations.")}
        _ = try workspace.path(node)
        let pairs=try items.map {item -> PlacementPair in
            var a=workspace.assignments.first {$0.source==item.path} ?? Assignment(source:item.path,node:node,outputName:item.name)
            a.node=node
            return PlacementPair(source:item.path,destination:try workspace.destination(a),kind:item.kind)
        }
        let count=Set(items.map(\.path)).subtracting(Set(workspace.assignments.map(\.source))).count
        return PlacementPreview(pairs:pairs,newAssignments:count,exceedsCapacity:workspace.assignments.count+count>100)
    }
}

// An explicit state surface prevents an old page looking like fresh results.
final class ContentResultState:FriendlyPanel {
    let title=FriendlyUI.label("Updating your view…",size:18,weight:.semibold,wrapping:true)
    let detail=FriendlyUI.label("",size:12,wrapping:true),spinner=NSProgressIndicator()
    let clear=NSButton()
    init(owner:CatalogueExplorerController) {
        super.init();spinner.style = .spinning;spinner.controlSize = .small
        spinner.widthAnchor.constraint(equalToConstant:20).isActive=true
        clear.title="Clear search & filters";clear.bezelStyle = .rounded;clear.target=owner;clear.action=#selector(CatalogueExplorerController.clearFilters)
        detail.textColor=FriendlyUI.muted
        let words=FriendlyUI.column([FriendlyUI.row([spinner,title]),detail,clear],spacing:12)
        words.translatesAutoresizingMaskIntoConstraints=false;addSubview(words)
        NSLayoutConstraint.activate([words.leadingAnchor.constraint(equalTo:leadingAnchor,constant:24),words.trailingAnchor.constraint(equalTo:trailingAnchor,constant:-24),words.topAnchor.constraint(equalTo:topAnchor,constant:22),words.bottomAnchor.constraint(equalTo:bottomAnchor,constant:-22),detail.widthAnchor.constraint(equalTo:words.widthAnchor)])
        setAccessibilityLabel("Content result state")
    }
    required init?(coder:NSCoder) {fatalError("Use an explorer")}
}
