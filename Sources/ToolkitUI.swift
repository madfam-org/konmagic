import AppKit
import SQLite3

final class ToolkitCard:FriendlyPanel {
    let actionButton:NSButton
    init(step:String,title:String,body:String,kind:Int,tint:NSColor,actionTitle:String,target:AnyObject,action:Selector) {
        actionButton=FriendlyUI.button(actionTitle,symbol:"arrow.right",tint:tint,target:target,action:action)
        super.init(tint:tint)
        let heading=FriendlyUI.label(title,size:17,weight:.semibold,wrapping:true);heading.maximumNumberOfLines=2
        let stage=FriendlyUI.label(step,size:12,weight:.semibold);stage.textColor=tint
        let copy=FriendlyUI.label(body,size:12,wrapping:true);copy.textColor=FriendlyUI.muted;copy.maximumNumberOfLines=4
        actionButton.imagePosition = .imageTrailing;actionButton.setAccessibilityLabel(actionTitle+". "+title);actionButton.toolTip=body
        let words=FriendlyUI.column([heading,stage,copy,actionButton],spacing:7)
        let content=FriendlyUI.row([FriendlyTaskIcon(kind:kind,tint:tint),words],spacing:15);content.translatesAutoresizingMaskIntoConstraints=false;addSubview(content)
        NSLayoutConstraint.activate([content.leadingAnchor.constraint(equalTo:leadingAnchor,constant:16),content.trailingAnchor.constraint(equalTo:trailingAnchor,constant:-18),content.topAnchor.constraint(equalTo:topAnchor,constant:16),content.bottomAnchor.constraint(equalTo:bottomAnchor,constant:-16),copy.widthAnchor.constraint(equalTo:words.widthAnchor),heading.widthAnchor.constraint(equalTo:words.widthAnchor),heightAnchor.constraint(greaterThanOrEqualToConstant:200)])
        setAccessibilityLabel(title+". "+body)
    }
    required init?(coder:NSCoder) {fatalError("Use card content")}
}
private final class ToolkitDocument:NSView {override var isFlipped:Bool {true}}

final class ToolkitController:NSViewController {
    weak var workspace:KonMagicController?
    let coverage=FriendlyUI.label("Connecting your retained catalogue…",size:10,wrapping:true),nextStep=FriendlyUI.label("",size:16,weight:.semibold,wrapping:true),draftStatus=FriendlyUI.label("",size:10,wrapping:true)
    let observed=FriendlyUI.label("Connecting…",size:11,wrapping:true)
    var coverageValues:[NSTextField]=[]
    var nextAction:NSButton!
    let queue=DispatchQueue(label:"org.madfam.konmagic.toolkit",qos:.utility)
    var cards:[ToolkitCard]=[],loaded=false
    init(workspace:KonMagicController) {self.workspace=workspace;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use workspace")}
    func label(_ text:String,size:CGFloat=13,weight:NSFont.Weight = .regular)->NSTextField {FriendlyUI.label(text,size:size,weight:weight)}
    func button(_ title:String,_ action:Selector)->NSButton {FriendlyUI.button(title,target:self,action:action)}
    override func loadView() {
        view=FriendlyCanvas(frame:NSRect(x:0,y:0,width:1180,height:850))
        let scroll=NSScrollView(),document=ToolkitDocument(frame:view.bounds)
        scroll.hasVerticalScroller=true;scroll.autohidesScrollers=true;scroll.borderType = .noBorder;scroll.drawsBackground=false
        scroll.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(scroll);scroll.documentView=document;document.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([scroll.leadingAnchor.constraint(equalTo:view.leadingAnchor),scroll.trailingAnchor.constraint(equalTo:view.trailingAnchor),scroll.topAnchor.constraint(equalTo:view.topAnchor),scroll.bottomAnchor.constraint(equalTo:view.bottomAnchor),document.widthAnchor.constraint(equalTo:scroll.contentView.widthAnchor),document.heightAnchor.constraint(greaterThanOrEqualTo:scroll.contentView.heightAnchor)])
        let hero=ToolkitHero();hero.heightAnchor.constraint(equalToConstant:220).isActive=true
        let title=label("KonMagic",size:42,weight:.bold),subtitle=FriendlyUI.label("Make room for what matters.\nKeep control of every decision.",size:17,wrapping:true)
        let heroActions=FriendlyUI.row([FriendlyUI.button("Documentation",symbol:"book",target:self,action:#selector(documentation)),FriendlyUI.button("Welcome guide",symbol:"sparkles",target:self,action:#selector(guide)),FriendlyUI.button("Refresh overview",symbol:"arrow.clockwise",target:self,action:#selector(refresh))],spacing:8)
        let heroWords=FriendlyUI.column([title,subtitle,heroActions],spacing:12);heroWords.translatesAutoresizingMaskIntoConstraints=false;hero.addSubview(heroWords)
        NSLayoutConstraint.activate([heroWords.leadingAnchor.constraint(equalTo:hero.leadingAnchor,constant:220),heroWords.trailingAnchor.constraint(lessThanOrEqualTo:hero.trailingAnchor,constant:-130),heroWords.centerYAnchor.constraint(equalTo:hero.centerYAnchor)])
        let trust=FriendlyUI.row([FriendlyUI.image("lock",tint:FriendlyUI.violet,size:16),FriendlyUI.label("Your files stay where they are. You decide what happens next.",size:12),NSView(),FriendlyUI.label("Curious. Calm. In control.",size:11)],spacing:10)
        let trustPanel=FriendlyUI.panel(trust,tint:FriendlyUI.pink,padding:12)
        let glance=FriendlyUI.row([FriendlyUI.image("chart.bar",tint:FriendlyUI.teal),label("Your Mac at a glance",size:14,weight:.semibold)])
        var stats:[NSView]=[glance]
        let definitions=[("Tagged observations","tag",FriendlyUI.teal),("Full readings retained","doc.text",FriendlyUI.violet),("Partial readings retained","doc.text.magnifyingglass",FriendlyUI.pink),("Disk entries recorded","folder",FriendlyUI.orange),("Access exceptions","exclamationmark.shield",FriendlyUI.orange)]
        for (caption,symbol,tint) in definitions {
            let value=label("—",size:12,weight:.semibold);value.alignment = .right;value.setContentCompressionResistancePriority(.required,for:.horizontal);coverageValues.append(value)
            let name=label(caption,size:11);name.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
            let r=FriendlyUI.row([FriendlyUI.image(symbol,tint:tint,size:16),name,NSView(),value],spacing:8);stats.append(r)
        }
        let last=FriendlyUI.column([label("Last observed",size:11,weight:.semibold),observed],spacing:5)
        stats.append(FriendlyUI.row([FriendlyUI.image("calendar",tint:FriendlyUI.violet),last]));stats.append(coverage)
        coverage.textColor=FriendlyUI.muted;coverage.maximumNumberOfLines=5;observed.textColor=FriendlyUI.muted
        let glanceColumn=FriendlyUI.column(stats,spacing:20)
        for v in stats {v.widthAnchor.constraint(equalTo:glanceColumn.widthAnchor).isActive=true}
        let sidebar=FriendlyUI.panel(glanceColumn,padding:18);sidebar.widthAnchor.constraint(equalToConstant:270).isActive=true
        sidebar.heightAnchor.constraint(equalToConstant:430).isActive=true
        let intro=FriendlyUI.column([label("What would you like to do?",size:21,weight:.bold),FriendlyUI.label("Explore your Mac, understand your content, and shape an organization that feels like you.",size:12,wrapping:true)],spacing:6)
        let values:[(String,String,String,NSColor,String,Selector)]=[
            ("01 · Observe","Understand storage","Explore your physical hierarchy, see what uses space, and get volume context.",FriendlyUI.teal,"Open Storage",#selector(observe)),
            ("02 · Discover","Find & refine content","Recognize familiar groups, inspect your files, and refine their tags.",FriendlyUI.violet,"Open Content",#selector(discover)),
            ("03 · Shape","Design your organization","Create virtual destinations and manually assign files or whole folders.",FriendlyUI.orange,"Open Structure",#selector(shape)),
            ("04 · Review","Preview every destination","See exact paths and verify your proposal before separately approving a copy.",FriendlyUI.green,"Open Review",#selector(review))]
        for (i,v) in values.enumerated() {cards.append(ToolkitCard(step:v.0,title:v.1,body:v.2,kind:i,tint:v.3,actionTitle:v.4,target:self,action:v.5))}
        let row1=FriendlyUI.row(Array(cards.prefix(2)),spacing:14),row2=FriendlyUI.row(Array(cards.suffix(2)),spacing:14)
        for row in [row1,row2] {row.distribution = .fillEqually}
        nextStep.maximumNumberOfLines=2;draftStatus.textColor=FriendlyUI.muted;draftStatus.maximumNumberOfLines=2
        let nextCaption=label("SUGGESTED NEXT STEP",size:10,weight:.semibold);nextCaption.textColor=FriendlyUI.pink
        nextAction=FriendlyUI.button("Open Storage",symbol:"arrow.right",tint:FriendlyUI.pink,target:self,action:#selector(observe));nextAction.imagePosition = .imageTrailing
        let nextWords=FriendlyUI.column([nextCaption,nextStep,draftStatus],spacing:5)
        let next=FriendlyUI.panel(FriendlyUI.row([FriendlyUI.image("sparkles",tint:FriendlyUI.pink,size:28),nextWords,NSView(),nextAction],spacing:15),tint:FriendlyUI.pink,padding:16)
        let work=FriendlyUI.column([intro,row1,row2,next],spacing:14)
        row1.heightAnchor.constraint(equalTo:row2.heightAnchor).isActive=true
        for v in [intro,row1,row2,next] {v.widthAnchor.constraint(equalTo:work.widthAnchor).isActive=true}
        let body=FriendlyUI.row([sidebar,work],spacing:24);body.alignment = .top
        work.widthAnchor.constraint(equalTo:body.widthAnchor,constant:-294).isActive=true
        let help=label("⌘0 Toolkit     ⌘1 Storage     ⌘2 Content     ⌘3 Structure     ⌘4 Review",size:10);help.textColor=FriendlyUI.muted
        let outer=FriendlyUI.column([hero,trustPanel,body,help],spacing:16);outer.translatesAutoresizingMaskIntoConstraints=false;document.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:document.leadingAnchor,constant:24),outer.trailingAnchor.constraint(equalTo:document.trailingAnchor,constant:-24),outer.topAnchor.constraint(equalTo:document.topAnchor,constant:20),outer.bottomAnchor.constraint(equalTo:document.bottomAnchor,constant:-20)])
        for v in [hero,trustPanel,body] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        loaded=true;refresh()
    }
    func updateDraft() {
        guard let workspace=workspace else{return}
        let value=workspace.store.value,knowledge=workspace.knowledge.snapshot()
        draftStatus.stringValue="\(value.nodes.count) destinations · \(value.assignments.count) assignments · \(knowledge.corrections.count) tag corrections · \(knowledge.collections.count) collections"
        nextStep.stringValue=value.assignments.isEmpty ? "Take a quick look at your storage" : "Your draft is ready for a closer look"
        nextAction?.title=value.assignments.isEmpty ? "Open Storage":"Open Review";nextAction?.action=value.assignments.isEmpty ? #selector(observe):#selector(review)
    }
    var observing=false
    @objc func refresh() {
        updateDraft();guard let workspace=workspace,!observing else{return};observing=true
        let catalogue=workspace.catalog,disk=DiskCatalogue(path:URL(fileURLWithPath:catalogue.path).deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path)
        queue.async {[weak self] in
            let record=try? disk.overview();var count:Int64=0,full:Int64=0,partial:Int64=0;var error:String?
            do {let db=try AtlasDatabase(catalogue.path,seconds:15);try db.rows("SELECT count(*),sum(state='extracted'),sum(state='partial') FROM items") {s in count=sqlite3_column_int64(s,0);full=sqlite3_column_int64(s,1);partial=sqlite3_column_int64(s,2)}} catch let e {error=e.localizedDescription}
            DispatchQueue.main.async {
                guard let self=self else{return};self.observing=false
                let n:(Int64)->String={NumberFormatter.localizedString(from:NSNumber(value:$0),number:.decimal)}
                let values=[error==nil ? n(count):"Unavailable",error==nil ? n(full):"—",error==nil ? n(partial):"—",record.map {n($0.count)} ?? "—",record.map {n($0.exceptions)} ?? "—"]
                for (field,value) in zip(self.coverageValues,values) {field.stringValue=value}
                self.coverage.stringValue=error==nil ? "Catalogue scopes overlap. Counts describe retained evidence; they are not a total of files fully understood.":"Catalogue unavailable. File → Connect catalogue can reconnect it. Live browsing remains available."
                if let d=record {let date=ISO8601DateFormatter().date(from:d.updated);let format=DateFormatter();format.dateStyle = .medium;format.timeStyle = .short;self.observed.stringValue=date.map {format.string(from:$0)} ?? d.updated}
                else {self.observed.stringValue="No recorded disk coverage connected"}
            }
        }
    }
    @objc func observe() {workspace?.showDiskLens()}
    @objc func discover() {workspace?.showExplorer()}
    @objc func shape() {workspace?.showWorkspace()}
    @objc func review() {workspace?.showReview()}
    @objc func guide() {workspace?.showGuide()}
    @objc func documentation() {KonMagicDocumentation.open("guide/getting-started/")}
}
extension KonMagicController {
    @objc func showToolkit() {pageHost?.navigate(.toolkit)}
    @objc func showWorkspace() {pageHost?.navigate(.structure)}
    @objc func showReview() {pageHost?.navigate(.review)}
    func focusReview() {review?.refresh();review?.view.window?.makeFirstResponder(review?.table)}
}
