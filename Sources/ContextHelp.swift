import AppKit

final class DialogValidation:NSObject {
    private let evaluate:()->Void
    private var observers:[NSObjectProtocol]=[]
    init(fields:[NSTextField]=[],popups:[NSPopUpButton]=[],evaluate:@escaping ()->Void) {
        self.evaluate=evaluate;super.init()
        for field in fields {observers.append(NotificationCenter.default.addObserver(forName:NSControl.textDidChangeNotification,object:field,queue:nil) {[weak self] _ in self?.evaluate()})}
        for popup in popups {popup.target=self;popup.action=#selector(refresh(_:))}
    }
    deinit {for observer in observers {NotificationCenter.default.removeObserver(observer)}}
    @objc func refresh(_ sender:Any?) {evaluate()}
    func run(_ alert:NSAlert)->NSApplication.ModalResponse {evaluate();return withExtendedLifetime(self) {alert.runModal()}}
}

func dialogAccessory(_ views:[NSView])->NSView {
    let stack=NSStackView(views:views);stack.orientation = .vertical;stack.alignment = .leading;stack.spacing=10
    stack.translatesAutoresizingMaskIntoConstraints=false
    let size=stack.fittingSize
    let wrapper=NSView(frame:NSRect(x:0,y:0,width:size.width+44,height:size.height+24))
    wrapper.addSubview(stack)
    NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:wrapper.leadingAnchor,constant:22),stack.trailingAnchor.constraint(equalTo:wrapper.trailingAnchor,constant:-22),stack.topAnchor.constraint(equalTo:wrapper.topAnchor,constant:12),stack.bottomAnchor.constraint(equalTo:wrapper.bottomAnchor,constant:-12)])
    wrapper.layoutSubtreeIfNeeded()
    return wrapper
}

func contextHelp(from sender:NSButton,title:String,body:String)->NSPopover {
    let p=NSPopover(),controller=NSViewController();p.behavior = .transient;p.animates = !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    let heading=NSTextField(labelWithString:title);heading.font=NSFont.systemFont(ofSize:17,weight:.semibold)
    let text=NSTextField(wrappingLabelWithString:body);text.font=NSFont.systemFont(ofSize:13);text.textColor = .secondaryLabelColor;text.widthAnchor.constraint(equalToConstant:390).isActive=true
    let stack=NSStackView(views:[heading,text]);stack.orientation = .vertical;stack.alignment = .leading;stack.spacing=12;stack.edgeInsets=NSEdgeInsets(top:18,left:18,bottom:18,right:18)
    controller.view=stack;p.contentViewController=controller;p.contentSize=stack.fittingSize;p.show(relativeTo:sender.bounds,of:sender,preferredEdge:.minY);return p
}
extension CatalogueExplorerController {
    @objc func showTips(_ sender:NSButton) {
        let body=tagged ? "Start with a name, a familiar folder or a facet on the left. Intersect categories to narrow your view; maps and tag groups drill into the same observations.\n\nSelect real files or folders to inspect them. Correct selected tags records your knowledge. Collections save a view; Rules preview reusable destination and output-name proposals.\n\nChoose a destination before assigning. Then review the exact paths in the organization workspace. Retained readings and observations keep their coverage limits." : "This view browses the retained physical disk ledger. Double-click a root or expand Folder tree to drill into recorded directories. Access exceptions explain incomplete coverage.\n\nFor semantic maps, content search, collections and rules, switch to Content & tags. For proportional disk-size maps, open Disk Lens from the toolkit."
        helpPopover=contextHelp(from:sender,title:tagged ? "Find → refine → propose" : "Explore recorded coverage",body:body)
    }
}
extension DiskLensController {
    @objc func showTips(_ sender:NSButton) {
        helpPopover=contextHelp(from:sender,title:"Read the map, then drill in",body:"Recorded machine opens retained Atlas metadata; Scan current folder creates a fresh metadata observation.\n\nEach area represents the selected size measure. Hover inspects, click locks a selection and double-click zooms. Parent returns a level. Arrow keys navigate; Space requests a checked Quick Look.\n\nCustomize view exposes display, color and detail choices. More tools holds masks, filters, comparisons, exports, volume context and duplicate evidence.\n\nChoose a destination for a selected real source to add it to your exact draft. Scanning and browsing keep originals in place.")
    }
}
extension KonMagicController {
    @objc func showWorkspaceTips(_ sender:NSButton) {
        helpPopover=contextHelp(from:sender,title:"Shape → assign → review",body:"The left tree is your proposed structure. Rename or reparent it without touching real folders.\n\nA drop is a file; a bucket is a coherent folder. Drag either from Finder or the source list onto a destination. Whole buckets retain their internal hierarchy.\n\nThe right pane shows the exact proposed paths. Output naming changes only the proposed copy. Verify hashes and capacity separately, then review and explicitly approve a copy. Draft undo edits the plan; originals remain intact.")
    }
}
