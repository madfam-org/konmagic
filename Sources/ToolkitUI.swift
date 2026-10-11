import AppKit
import SQLite3

final class ToolkitCard:NSBox {
    let actionButton:NSButton
    init(step:String,title:String,body:String,symbol:String,tint:NSColor,actionTitle:String,target:AnyObject,action:Selector) {
        actionButton=NSButton(title:actionTitle,target:target,action:action)
        super.init(frame:.zero)
        boxType = .custom;cornerRadius=16;borderWidth=1
        fillColor = .controlBackgroundColor;borderColor = .separatorColor;contentViewMargins=NSSize(width:22,height:20)
        let image=NSImageView();image.image=NSImage(systemSymbolName:symbol,accessibilityDescription:nil);image.contentTintColor=tint;image.imageScaling = .scaleProportionallyDown
        image.widthAnchor.constraint(equalToConstant:30).isActive=true;image.heightAnchor.constraint(equalToConstant:30).isActive=true
        let label=NSTextField(labelWithString:step.uppercased());label.font=NSFont.systemFont(ofSize:10,weight:.semibold);label.textColor = .secondaryLabelColor
        let heading=NSTextField(labelWithString:title);heading.font=NSFont.systemFont(ofSize:19,weight:.semibold)
        let copy=NSTextField(wrappingLabelWithString:body);copy.font=NSFont.systemFont(ofSize:13);copy.textColor = .secondaryLabelColor;copy.maximumNumberOfLines=4
        let top=NSStackView(views:[image,label,NSView()]);top.orientation = .horizontal;top.spacing=10
        actionButton.bezelStyle = .rounded;actionButton.controlSize = .large;actionButton.setAccessibilityLabel(actionTitle+". "+title);actionButton.toolTip=body
        let stack=NSStackView(views:[top,heading,copy,NSView(),actionButton]);stack.orientation = .vertical;stack.alignment = .leading;stack.spacing=10;stack.translatesAutoresizingMaskIntoConstraints=false
        contentView?.addSubview(stack)
        if let content=contentView {NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:content.leadingAnchor),stack.trailingAnchor.constraint(equalTo:content.trailingAnchor),stack.topAnchor.constraint(equalTo:content.topAnchor),stack.bottomAnchor.constraint(equalTo:content.bottomAnchor),copy.widthAnchor.constraint(equalTo:stack.widthAnchor),top.widthAnchor.constraint(equalTo:stack.widthAnchor)])}
        heightAnchor.constraint(greaterThanOrEqualToConstant:215).isActive=true
        setAccessibilityLabel(title+". "+body)
    }
    required init?(coder:NSCoder) {fatalError("Use card content")}
}

private final class ToolkitDocument:NSView {override var isFlipped:Bool {true}}

final class ToolkitController:NSViewController {
    weak var workspace:KonMagicController?
    let coverage=NSTextField(wrappingLabelWithString:"Connecting your retained catalogue…"),nextStep=NSTextField(wrappingLabelWithString:""),draftStatus=NSTextField(labelWithString:"")
    let queue=DispatchQueue(label:"org.madfam.konmagic.toolkit",qos:.utility)
    var cards:[ToolkitCard]=[],loaded=false
    init(workspace:KonMagicController) {self.workspace=workspace;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use workspace")}
    func label(_ text:String,size:CGFloat=13,weight:NSFont.Weight = .regular)->NSTextField {let t=NSTextField(labelWithString:text);t.font=NSFont.systemFont(ofSize:size,weight:weight);return t}
    func button(_ title:String,_ action:Selector)->NSButton {let b=NSButton(title:title,target:self,action:action);b.bezelStyle = .rounded;return b}
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1180,height:810))
        let scroll=NSScrollView(),document=ToolkitDocument(frame:view.bounds)
        scroll.hasVerticalScroller=true;scroll.autohidesScrollers=true;scroll.borderType = .noBorder;scroll.backgroundColor = .windowBackgroundColor
        scroll.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(scroll);scroll.documentView=document;document.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([scroll.leadingAnchor.constraint(equalTo:view.leadingAnchor),scroll.trailingAnchor.constraint(equalTo:view.trailingAnchor),scroll.topAnchor.constraint(equalTo:view.topAnchor),scroll.bottomAnchor.constraint(equalTo:view.bottomAnchor),document.widthAnchor.constraint(equalTo:scroll.contentView.widthAnchor),document.heightAnchor.constraint(greaterThanOrEqualTo:scroll.contentView.heightAnchor)])
        let title=label("KonMagic",size:30,weight:.bold),subtitle=label("Make room for what matters. Keep control of every decision.",size:15)
        subtitle.textColor = .secondaryLabelColor
        let heading=NSStackView(views:[title,NSView(),button("Welcome guide",#selector(guide)),button("Refresh overview",#selector(refresh))]);heading.orientation = .horizontal;heading.spacing=12
        let privacy=label("ON YOUR MAC  ·  PRIVATE BY DEFAULT  ·  ORIGINALS RETAINED",size:10,weight:.semibold);privacy.textColor = .secondaryLabelColor
        coverage.font=NSFont.systemFont(ofSize:12);coverage.textColor = .secondaryLabelColor;coverage.maximumNumberOfLines=3
        let values=[
            ("01 · Observe","Understand storage","See the whole recorded disk, zoom into its physical structure, compare scans and inspect volume context. Start with evidence before cleanup.","chart.pie",NSColor.systemTeal,"Explore Disk Lens",#selector(observe)),
            ("02 · Discover","Find & refine content","Browse files, folders, tags and retained readings. Correct classifications, save collections and turn a familiar group into a clear proposal.","magnifyingglass",NSColor.systemIndigo,"Open Content Explorer",#selector(discover)),
            ("03 · Shape","Design your organization","Refine your virtual folder structure. Drop individual files or coherent folders into destinations you choose. Your sources stay in place.","folder.badge.plus",NSColor.systemOrange,"Shape my structure",#selector(shape)),
            ("04 · Review","Preview every destination","Inspect source → destination pairs, output names and collisions. Verify complete hashes and capacity before separately approving any copy.","checklist",NSColor.systemGreen,"Review my draft",#selector(review))]
        for (step,title,body,symbol,tint,actionTitle,action) in values {cards.append(ToolkitCard(step:step,title:title,body:body,symbol:symbol,tint:tint,actionTitle:actionTitle,target:self,action:action))}
        let row1=NSStackView(views:Array(cards.prefix(2))),row2=NSStackView(views:Array(cards.suffix(2)))
        for row in [row1,row2] {row.orientation = .horizontal;row.distribution = .fillEqually;row.spacing=16}
        nextStep.font=NSFont.systemFont(ofSize:13,weight:.medium);nextStep.maximumNumberOfLines=2
        draftStatus.font=NSFont.systemFont(ofSize:11);draftStatus.textColor = .secondaryLabelColor
        let footer=NSStackView(views:[label("YOUR NEXT STEP",size:10,weight:.semibold),nextStep,draftStatus]);footer.orientation = .vertical;footer.alignment = .leading;footer.spacing=8
        let help=label("⌘0 Toolkit     ⌘1 Storage     ⌘2 Content     ⌘3 Structure     ⌘4 Review",size:11);help.textColor = .secondaryLabelColor
        let outer=NSStackView(views:[heading,subtitle,privacy,coverage,row1,row2,footer,help]);outer.orientation = .vertical;outer.alignment = .leading;outer.spacing=16;outer.translatesAutoresizingMaskIntoConstraints=false;document.addSubview(outer)
        row1.heightAnchor.constraint(equalTo:row2.heightAnchor).isActive=true
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:document.leadingAnchor,constant:30),outer.trailingAnchor.constraint(equalTo:document.trailingAnchor,constant:-30),outer.topAnchor.constraint(equalTo:document.topAnchor,constant:26),outer.bottomAnchor.constraint(equalTo:document.bottomAnchor,constant:-26)])
        for v in [heading,coverage,row1,row2,footer,nextStep] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        loaded=true;refresh()
    }
    func updateDraft() {
        guard let workspace=workspace else{return}
        let value=workspace.store.value,knowledge=workspace.knowledge.snapshot()
        draftStatus.stringValue="\(value.nodes.count) virtual destinations · \(value.assignments.count) source assignments · \(knowledge.corrections.count) personal tag corrections · \(knowledge.collections.count) saved collections"
        nextStep.stringValue=value.assignments.isEmpty ? "Start with a collection you know. Find it in Content Explorer, correct its context and choose its destination." : "Your draft has \(value.assignments.count) assignments. Review the exact paths before verifying the copy preview."
    }
    var observing=false
    @objc func refresh() {
        updateDraft();guard let workspace=workspace,!observing else{return};observing=true
        let catalogue=workspace.catalog,disk=DiskCatalogue(path:URL(fileURLWithPath:catalogue.path).deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path)
        queue.async {[weak self] in
            let record=try? disk.overview();var count:Int64=0,readings:Int64=0;var error:String?
            do {let db=try AtlasDatabase(catalogue.path,seconds:15);try db.rows("SELECT count(*),sum(state IN ('extracted','partial')) FROM items") {s in count=sqlite3_column_int64(s,0);readings=sqlite3_column_int64(s,1)}} catch let e {error=e.localizedDescription}
            DispatchQueue.main.async {
                guard let self=self else{return};self.observing=false
                let n:(Int64)->String={NumberFormatter.localizedString(from:NSNumber(value:$0),number:.decimal)}
                var text=error==nil ? n(count)+" tagged observations · "+n(readings)+" retained full/partial readings" : "Catalogue unavailable. File → Connect catalogue can reconnect it."
                if let d=record {let date=ISO8601DateFormatter().date(from:d.updated)
                    let format=DateFormatter();format.dateStyle = .medium;format.timeStyle = .short
                    let observed=date.map {format.string(from:$0)} ?? d.updated
                    text+="\n"+n(d.count)+" recorded disk entries · "+n(d.exceptions)+" coverage exceptions · observed "+observed+". Catalogue scopes overlap."}
                else {text+="\nLive folder browsing and metadata scans remain available."}
                self.coverage.stringValue=text
            }
        }
    }
    @objc func observe() {workspace?.showDiskLens()}
    @objc func discover() {workspace?.showExplorer()}
    @objc func shape() {workspace?.showWorkspace()}
    @objc func review() {workspace?.showReview()}
    @objc func guide() {workspace?.showGuide()}
}

extension KonMagicController {
    @objc func showToolkit() {pageHost?.navigate(.toolkit)}
    @objc func showWorkspace() {pageHost?.navigate(.structure)}
    @objc func showReview() {pageHost?.navigate(.review)}
    func focusReview() {review?.refresh();review?.view.window?.makeFirstResponder(review?.table)}
}
