import AppKit
import Foundation
import UniformTypeIdentifiers

private let draftType = NSPasteboard.PasteboardType("org.madfam.konmagic.draft-paths")
private let nodeType = NSPasteboard.PasteboardType("org.madfam.konmagic.destination-node")

final class WorkspaceCanvas: NSView {
    override var isOpaque: Bool { true }
    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        dirtyRect.fill()
    }
}

final class TreeEntry: NSObject {
    let id: String
    init(_ id: String) { self.id = id }
}

final class KonMagicController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate,
    NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate {
    let store: WorkspaceStore
    var catalog: Catalog
    let outline = NSOutlineView(), sources = NSTableView(), draft = NSTableView()
    let search = NSSearchField(), scope = NSPopUpButton(), status = NSTextField(labelWithString:""),
        sourceLocation = NSTextField(labelWithString:""),
        selection = NSTextField(labelWithString:"Choose a destination in the structure"),
        outputLabel = NSTextField(labelWithString:""), draftCount = NSTextField(labelWithString:"No assignments yet")
    let inspector = NSTextView(), spinner = NSProgressIndicator()
    let previewButton = NSButton(), applyButton = NSButton()
    let split = NSSplitView()
    var treeEntries: [String: TreeEntry] = [:]
    var items: [CatalogItem] = []
    var plan: CopyPlan?
    var busy = false
    var didExpandInitialTree = false
    var showHidden = false
    var scopePath: String? = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path
    var offset = 0
    var request = 0
    var debounce: DispatchWorkItem?
    let work = DispatchQueue(label:"org.madfam.konmagic.catalogue",qos:.userInitiated)
    let transfers = DispatchQueue(label:"org.madfam.konmagic.verified-copy",qos:.utility)
    var directoryAccess: [URL] = []

    init(store: WorkspaceStore, catalog: Catalog) { self.store=store; self.catalog=catalog; super.init(nibName:nil,bundle:nil) }
    required init?(coder:NSCoder) { fatalError("Use designated initializer") }
    deinit { directoryAccess.forEach {$0.stopAccessingSecurityScopedResource()} }

    func label(_ text: String, size: CGFloat = 12, weight: NSFont.Weight = .regular) -> NSTextField {
        let v=NSTextField(labelWithString:text); v.font=NSFont.systemFont(ofSize:size,weight:weight); v.lineBreakMode = .byTruncatingMiddle; return v
    }
    func button(_ name:String, _ action:Selector, symbol:String?=nil) -> NSButton {
        let b=NSButton(title:name,target:self,action:action); b.bezelStyle = .rounded
        if let symbol=symbol {b.image=NSImage(systemSymbolName:symbol,accessibilityDescription:name);b.imagePosition = .imageLeading}
        return b
    }
    func vertical(_ children:[NSView], padding:CGFloat=16) -> NSStackView {
        let s=NSStackView(views:children);s.orientation = .vertical;s.alignment = .leading;s.spacing=12
        s.edgeInsets=NSEdgeInsets(top:padding,left:padding,bottom:padding,right:padding); return s
    }
    func row(_ children:[NSView]) -> NSStackView {
        let s=NSStackView(views:children);s.orientation = .horizontal;s.alignment = .centerY;s.spacing=8;return s
    }
    func scroll(_ content:NSView) -> NSScrollView {
        let s=NSScrollView();s.hasVerticalScroller=true;s.hasHorizontalScroller=false;s.autohidesScrollers=true;s.documentView=content
        s.borderType = .noBorder; s.translatesAutoresizingMaskIntoConstraints=false; return s
    }
    func configure(_ table:NSTableView, columns:[(String,String,CGFloat)]) {
        table.delegate=self;table.dataSource=self;table.rowHeight=48;table.usesAlternatingRowBackgroundColors=true
        table.allowsMultipleSelection=true;table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        for (id,title,width) in columns {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=title;c.width=width;c.minWidth=80;table.addTableColumn(c)}
        table.setAccessibilityLabel(table===sources ? "Source files and buckets" : "Draft assignments. No files changed.")
    }
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1320,height:800))
        let title=label("KonMagic",size:22,weight:.bold)
        let subtitle=label("Your structure. Your decisions. Exact previews before copies.",size:12);subtitle.textColor = .secondaryLabelColor
        spinner.style = .spinning;spinner.isDisplayedWhenStopped=false;spinner.controlSize = .small
        let head=row([vertical([title,subtitle],padding:0),NSView(),spinner,button("Guide",#selector(showGuide),symbol:"questionmark.circle")])
        split.isVertical=true;split.dividerStyle = .thin;split.translatesAutoresizingMaskIntoConstraints=false

        outline.dataSource=self;outline.delegate=self;outline.headerView=nil;outline.rowHeight=29
        outline.style = .sourceList;outline.setAccessibilityLabel("Editable destination structure. Drop files or whole folders here to assign them.")
        let column=NSTableColumn(identifier:NSUserInterfaceItemIdentifier("structure"));column.width=265;outline.addTableColumn(column);outline.outlineTableColumn=column
        outline.registerForDraggedTypes([.fileURL,draftType,nodeType]);outline.setDraggingSourceOperationMask([.copy,.move],forLocal:true)
        let treeScroll=scroll(outline)
        let structure=vertical([label("DESTINATION STRUCTURE",size:11,weight:.semibold),label("Virtual until you approve a copy",size:11),treeScroll,
            row([button("New",#selector(newFolder),symbol:"folder.badge.plus"),button("Rename",#selector(renameFolder)),button("Remove",#selector(removeFolder))]),
            button("Undo draft edit",#selector(undoDraft),symbol:"arrow.uturn.backward")])
        structure.widthAnchor.constraint(greaterThanOrEqualToConstant:290).isActive=true
        treeScroll.widthAnchor.constraint(equalTo:structure.widthAnchor,constant:-32).isActive=true

        scope.addItems(withTitles:["Downloads","Desktop","Documents","All catalogue","Chosen folder"]);scope.target=self;scope.action=#selector(changeScope)
        search.placeholderString="Search names here · All catalogue searches stored paths";search.delegate=self;search.setAccessibilityLabel("Search current folder names, or retained paths in All catalogue")
        search.widthAnchor.constraint(greaterThanOrEqualToConstant:160).isActive=true
        configure(sources,columns:[("name","Drops & buckets",285),("context","Observed context",150)])
        sources.target=self;sources.doubleAction=#selector(openBucket)
        sources.setDraggingSourceOperationMask(.copy,forLocal:true);sources.registerForDraggedTypes([draftType])
        let sourceScroll=scroll(sources)
        sourceLocation.font=NSFont.systemFont(ofSize:10);sourceLocation.textColor = .secondaryLabelColor;sourceLocation.lineBreakMode = .byTruncatingMiddle
        let browse=vertical([label("SOURCE LIBRARY",size:11,weight:.semibold),row([scope,button("Choose folder…",#selector(chooseScope))]),sourceLocation,search,
            label("Drag a file or folder onto your destination tree.",size:11),sourceScroll,
            row([button("↑ Parent",#selector(parentScope)),button("Previous",#selector(previousPage)),button("Next 200",#selector(nextPage))]),
            button("Assign selected →",#selector(assignSelection),symbol:"arrow.right.circle")])
        sourceScroll.widthAnchor.constraint(equalTo:browse.widthAnchor,constant:-32).isActive=true
        browse.widthAnchor.constraint(greaterThanOrEqualToConstant:340).isActive=true

        configure(draft,columns:[("name","Assigned source",150),("destination","Chosen destination",210)])
        draft.rowHeight=42
        let draftScroll=scroll(draft);draftScroll.heightAnchor.constraint(greaterThanOrEqualToConstant:160).isActive=true
        inspector.isEditable=false;inspector.isSelectable=true;inspector.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular)
        inspector.isVerticallyResizable=true;inspector.isHorizontallyResizable=false;inspector.autoresizingMask = [.width]
        inspector.textContainer?.widthTracksTextView=true
        inspector.textContainerInset=NSSize(width:12,height:12);inspector.setAccessibilityLabel("Exact source and destination preview")
        let inspectScroll=scroll(inspector);inspectScroll.heightAnchor.constraint(greaterThanOrEqualToConstant:170).isActive=true
        previewButton.title="Verify exact copy preview";previewButton.target=self;previewButton.action=#selector(verifyPreview);previewButton.bezelStyle = .rounded
        applyButton.title="Review & copy…";applyButton.target=self;applyButton.action=#selector(applyCopy);applyButton.bezelStyle = .rounded;applyButton.isEnabled=false
        selection.font=NSFont.systemFont(ofSize:11,weight:.medium);selection.maximumNumberOfLines=2
        outputLabel.font=NSFont.systemFont(ofSize:10);outputLabel.lineBreakMode = .byTruncatingMiddle
        let planning=vertical([label("YOUR REORGANIZATION DRAFT",size:11,weight:.semibold),selection,draftCount,draftScroll,
            row([button("Remove assignment",#selector(removeAssignment)),button("Rename output",#selector(renameOutput))]),inspectScroll,
            label("OUTPUT ROOT",size:10,weight:.semibold),outputLabel,button("Choose output…",#selector(chooseOutput)),
            row([previewButton,applyButton]),button("Receipts & recovery",#selector(openJournal),symbol:"clock.arrow.circlepath")])
        for s in [draftScroll,inspectScroll] {s.widthAnchor.constraint(equalTo:planning.widthAnchor,constant:-32).isActive=true}
        planning.widthAnchor.constraint(greaterThanOrEqualToConstant:410).isActive=true
        for v in [structure,browse,planning] {split.addArrangedSubview(v)}
        let foot=row([status]);status.font=NSFont.systemFont(ofSize:11);status.textColor = .secondaryLabelColor
        let outer=vertical([head,split,foot],padding:16);outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor),outer.topAnchor.constraint(equalTo:view.topAnchor),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor),head.widthAnchor.constraint(equalTo:outer.widthAnchor,constant:-32),split.widthAnchor.constraint(equalTo:outer.widthAnchor,constant:-32),foot.widthAnchor.constraint(equalTo:outer.widthAnchor,constant:-32)])
        split.setHoldingPriority(.defaultLow,forSubviewAt:1)
        refreshDraft();loadSources()
    }
    func arrangeInitialPanes() {
        view.layoutSubtreeIfNeeded()
        split.setPosition(300,ofDividerAt:0)
        split.setPosition(max(640,split.bounds.width-490),ofDividerAt:1)
        view.layoutSubtreeIfNeeded()
    }
    func node(_ item:Any?) -> FolderNode? {guard let e=item as? TreeEntry else{return nil};return store.value.nodes.first {$0.id==e.id}}
    var selectedNode:FolderNode? {node(outline.item(atRow:outline.selectedRow))}
    func outlineView(_ o:NSOutlineView,numberOfChildrenOfItem item:Any?) -> Int {store.value.children(node(item)?.id).count}
    func outlineView(_ o:NSOutlineView,child index:Int,ofItem item:Any?) -> Any {
        let id=store.value.children(node(item)?.id)[index].id
        if treeEntries[id]==nil {treeEntries[id]=TreeEntry(id)};return treeEntries[id]!
    }
    func outlineView(_ o:NSOutlineView,isItemExpandable item:Any) -> Bool {!store.value.children(node(item)?.id).isEmpty}
    func outlineView(_ o:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any) -> NSView? {
        guard let n=node(item) else{return nil}
        let cell=NSTableCellView();let l=label(n.name,size:12,weight:n.parent==nil ? .semibold : .regular)
        l.translatesAutoresizingMaskIntoConstraints=false;cell.addSubview(l);cell.textField=l
        NSLayoutConstraint.activate([l.leadingAnchor.constraint(equalTo:cell.leadingAnchor,constant:4),l.trailingAnchor.constraint(equalTo:cell.trailingAnchor,constant:-4),l.centerYAnchor.constraint(equalTo:cell.centerYAnchor)])
        cell.toolTip=try? store.value.path(n.id);return cell
    }
    func outlineViewSelectionDidChange(_ n:Notification) {
        selection.stringValue=selectedNode.flatMap {try? store.value.path($0.id)} ?? "Choose a destination in the structure"
    }
    func draggedPaths(_ pasteboard:NSPasteboard) -> [String] {
        let encoded=(pasteboard.pasteboardItems ?? []).compactMap {$0.string(forType:draftType)}
        if !encoded.isEmpty {return encoded.flatMap {$0.data(using:.utf8).flatMap {try? JSONDecoder().decode([String].self,from:$0)} ?? []}}
        return (pasteboard.readObjects(forClasses:[NSURL.self],options:[.urlReadingFileURLsOnly:true]) as? [NSURL] ?? []).compactMap {$0.isFileURL ? $0.path : nil}
    }
    func outlineView(_ o:NSOutlineView,pasteboardWriterForItem item:Any) -> NSPasteboardWriting? {
        guard let n=node(item),!busy else{return nil};let p=NSPasteboardItem();p.setString(n.id,forType:nodeType);return p
    }
    func outlineView(_ o:NSOutlineView,validateDrop info:NSDraggingInfo,proposedItem item:Any?,proposedChildIndex index:Int) -> NSDragOperation {
        if let id=info.draggingPasteboard.string(forType:nodeType),!busy {
            var w=store.value;guard let i=w.nodes.firstIndex(where:{$0.id==id}),node(item)?.id != id else{return []}
            w.nodes[i].parent=node(item)?.id;guard (try? w.validate()) != nil else{return []};return .move
        }
        guard !busy,node(item) != nil,!draggedPaths(info.draggingPasteboard).isEmpty else{return []}
        o.setDropItem(item,dropChildIndex:NSOutlineViewDropOnItemIndex);return .copy
    }
    func outlineView(_ o:NSOutlineView,acceptDrop info:NSDraggingInfo,item:Any?,childIndex:Int) -> Bool {
        if let id=info.draggingPasteboard.string(forType:nodeType),!busy {
            do {try store.change {w in guard let i=w.nodes.firstIndex(where:{$0.id==id}) else{throw KonMagicError("Unknown destination")};var moving=w.nodes.remove(at:i);moving.parent=node(item)?.id
                let siblings=w.nodes.enumerated().filter {$0.element.parent==moving.parent};let index=childIndex>=0 && childIndex<siblings.count ? siblings[childIndex].offset : w.nodes.count;w.nodes.insert(moving,at:index)}
                plan=nil;refreshDraft();status.stringValue="Destination structure changed in the draft. No source files moved.";return true
            } catch {showError(error);return false}
        }
        guard let destination=node(item),!busy else{return false}
        do {try store.change {try $0.assign(draggedPaths(info.draggingPasteboard),to:destination.id)};plan=nil;refreshDraft();status.stringValue="Assignment saved in the draft. Original files unchanged.";return true}
        catch {showError(error);return false}
    }
    func numberOfRows(in tableView:NSTableView) -> Int {tableView===sources ? items.count : store.value.assignments.count}
    func tableView(_ table:NSTableView,viewFor column:NSTableColumn?,row r:Int) -> NSView? {
        let text:String,subtitle:String
        if table===sources {
            let x=items[r];text=column?.identifier.rawValue=="name" ? (x.kind=="directory" ? "▸ ":"")+x.name : x.context
            subtitle=column?.identifier.rawValue=="name" ? x.path : x.kind
        } else {
            let a=store.value.assignments[r];text=column?.identifier.rawValue=="name" ? URL(fileURLWithPath:a.source).lastPathComponent : (try? store.value.path(a.node)) ?? "Missing destination"
            subtitle=column?.identifier.rawValue=="name" ? a.source : a.outputName
        }
        let cell=NSTableCellView(),title=label(text,size:12,weight:.medium),sub=label(subtitle,size:10);sub.textColor = .secondaryLabelColor
        let stack=vertical([title,sub],padding:3);stack.spacing=3;stack.translatesAutoresizingMaskIntoConstraints=false;cell.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:cell.leadingAnchor,constant:3),stack.trailingAnchor.constraint(equalTo:cell.trailingAnchor,constant:-3),stack.centerYAnchor.constraint(equalTo:cell.centerYAnchor)])
        cell.textField=title;cell.toolTip=subtitle;return cell
    }
    func tableView(_ table:NSTableView,pasteboardWriterForRow row:Int) -> NSPasteboardWriting? {
        guard table===sources else{return nil};let p=NSPasteboardItem()
        if let d=try? JSONEncoder().encode([items[row].path]),let s=String(data:d,encoding:.utf8) {p.setString(s,forType:draftType)};return p
    }
    func tableViewSelectionDidChange(_ n:Notification) {if let table=n.object as? NSTableView,table === draft {showDraftPaths()}}
    func showDraftPaths() {
        let a=store.value.assignments
        let selected=draft.selectedRowIndexes.isEmpty ? Array(a.indices) : Array(draft.selectedRowIndexes)
        var paragraphs:[String]=[]
        for i in selected.prefix(100) {
            let destination:String=(try? store.value.destination(a[i])) ?? "Invalid destination"
            let parts:[String]=["SOURCE · retained",a[i].source,"","CHOSEN DESTINATION · proposed copy",destination]
            paragraphs.append(parts.joined(separator:"\n"))
        }
        inspector.string=paragraphs.joined(separator:"\n\n────────────────────\n\n")
        if let p=plan {inspector.string+="\n\nVERIFIED PREVIEW\n\(p.fileCount) files · \(ByteCountFormatter.string(fromByteCount:p.bytes,countStyle:.file))\nWhole folders keep every relative path. No source operation has run."}
    }
    func refreshDraft() {
        let selectedID=selectedNode?.id
        let expanded=store.value.nodes.filter {treeEntries[$0.id].map {outline.isItemExpanded($0)} ?? false}.map(\.id)
        for n in store.value.nodes where treeEntries[n.id]==nil {treeEntries[n.id]=TreeEntry(n.id)}
        outline.reloadData();for id in expanded {if let e=treeEntries[id] {outline.expandItem(e)}}
        if !didExpandInitialTree {
            didExpandInitialTree=true
            for n in store.value.children(nil) where n.name=="10 Projects" || n.name=="40 Archive" {
                if let e=treeEntries[n.id] {outline.expandItem(e,expandChildren:n.name=="10 Projects")}
            }
        }
        if let id=selectedID,let e=treeEntries[id],outline.row(forItem:e)>=0 {outline.selectRowIndexes(IndexSet(integer:outline.row(forItem:e)),byExtendingSelection:false)} else {outline.deselectAll(nil)}
        draft.reloadData();draftCount.stringValue="\(store.value.assignments.count) drops / buckets · draft only"
        outputLabel.stringValue=store.value.output;outputLabel.toolTip=store.value.output
        applyButton.isEnabled=plan != nil && !busy;previewButton.isEnabled = !busy && !store.value.assignments.isEmpty;showDraftPaths()
    }
    func loadSources() {
        request+=1;let serial=request,path=scopePath,query=search.stringValue,page=offset,reader=catalog,hidden=showHidden
        sourceLocation.stringValue=path ?? "All retained catalogue observations";sourceLocation.toolTip=path
        spinner.startAnimation(nil);status.stringValue="Reading a bounded metadata page…"
        work.async {[weak self] in
            let result:Result<[CatalogItem],Error>=Result {
                if let path=path {return try reader.liveFolder(path,search:query,offset:page,includeHidden:hidden)}
                return try reader.query(scope:path,search:query,offset:page)
            }
            DispatchQueue.main.async {
                guard let self=self,self.request==serial else{return};self.spinner.stopAnimation(nil)
                switch result {case .success(let rows):self.items=rows;self.sources.reloadData();self.status.stringValue="\(rows.count) entries · page \(page/200+1) · \(path != nil ? "current folder metadata" : "retained catalogue observations"). Double-click a bucket to browse."
                case .failure(let e):self.status.stringValue=e.localizedDescription;self.items=[];self.sources.reloadData()}
            }
        }
    }
    func controlTextDidChange(_ n:Notification) {
        debounce?.cancel();let action=DispatchWorkItem {[weak self] in self?.offset=0;self?.loadSources()};debounce=action;DispatchQueue.main.asyncAfter(deadline:.now()+0.25,execute:action)
    }
    @objc func changeScope() {let names=["Downloads","Desktop","Documents"];if scope.indexOfSelectedItem<3 {scopePath=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(names[scope.indexOfSelectedItem]).path} else if scope.indexOfSelectedItem==3 {scopePath=nil} else if scopePath==nil {scopePath=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path};offset=0;loadSources()}
    func navigate(_ path:String) {scopePath=path;scope.selectItem(at:4);offset=0;search.stringValue="";loadSources()}
    @objc func toggleHidden(_ sender:NSMenuItem) {showHidden.toggle();sender.state=showHidden ? .on : .off;offset=0;loadSources()}
    @objc func previousPage() {offset=max(0,offset-200);loadSources()}
    @objc func nextPage() {if items.count==200 {offset+=200;loadSources()}}
    @objc func parentScope() {if let p=scopePath {navigate(URL(fileURLWithPath:p).deletingLastPathComponent().path)}}
    @objc func openBucket() {let r=sources.clickedRow;guard r>=0,r<items.count else{return};if items[r].kind=="directory" {navigate(items[r].path)} else {NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath:items[r].path)])}}
    func grant(_ u:URL) {if u.startAccessingSecurityScopedResource() {directoryAccess.append(u)}}
    func folderPanel(_ title:String, action:@escaping(URL)->Void) {let p=NSOpenPanel();p.title=title;p.canChooseDirectories=true;p.canChooseFiles=false;p.allowsMultipleSelection=false;guard let window=view.window else{return};p.beginSheetModal(for:window) {[weak self] result in if result == .OK,let u=p.url {self?.grant(u);action(u)}}}
    @objc func chooseScope() {folderPanel("Choose a source folder to browse") {[weak self] u in self?.navigate(u.path)}}
    @objc func chooseOutput() {guard !busy else{return};folderPanel("Choose a local organized output folder") {[weak self] u in guard let self=self else{return};do {try self.store.change {$0.output=u.path;$0.outputBookmark=try? u.bookmarkData(options:.withSecurityScope,includingResourceValuesForKeys:nil,relativeTo:nil)};self.plan=nil;self.refreshDraft()} catch {self.showError(error)}}}
    @objc func connectCatalog() {guard !busy else{return};folderPanel("Select an existing compatible catalogue folder") {[weak self] u in guard let self=self else{return};do {let path=u.appendingPathComponent("catalog.sqlite3").path;try self.store.change {$0.cataloguePath=path;$0.catalogueBookmark=try? u.bookmarkData(options:[.withSecurityScope,.securityScopeAllowOnlyReadAccess],includingResourceValuesForKeys:nil,relativeTo:nil)};self.catalog=Catalog(path:path);self.plan=nil;self.refreshDraft();self.loadSources()} catch {self.showError(error)}}}
    func ask(_ title:String, initial:String, then:(String)throws->Void) {
        guard !busy else{return};let a=NSAlert();a.messageText=title;a.informativeText="Changes only the organizational draft. Original files remain untouched."
        let f=NSTextField(string:initial);f.frame=NSRect(x:0,y:0,width:360,height:26);a.accessoryView=f;a.addButton(withTitle:"Save draft");a.addButton(withTitle:"Cancel")
        if a.runModal() == .alertFirstButtonReturn {do {try then(f.stringValue);plan=nil;refreshDraft()} catch {showError(error)}}
    }
    @objc func newFolder() {let parent=selectedNode?.id;ask("New destination folder",initial:"") {name in try store.change {$0.nodes.append(FolderNode(parent:parent,name:name))}}}
    @objc func renameFolder() {guard let n=selectedNode else{return};ask("Rename destination",initial:n.name) {name in try store.change {if let i=$0.nodes.firstIndex(where:{$0.id==n.id}) {$0.nodes[i].name=name}}}}
    @objc func removeFolder() {
        guard !busy,let n=selectedNode else{return};do {try store.change {w in guard w.children(n.id).isEmpty,!w.assignments.contains(where:{$0.node==n.id}) else {throw KonMagicError("Remove or reassign this folder's children and assignments first.")};w.nodes.removeAll {$0.id==n.id}};plan=nil;refreshDraft()} catch {showError(error)}
    }
    @objc func undoDraft() {guard !busy else{return};do {try store.undoDraft();plan=nil;refreshDraft()} catch {showError(error)}}
    @objc func assignSelection() {guard !busy,let n=selectedNode else{return};do {let paths=sources.selectedRowIndexes.map {items[$0].path};try store.change {try $0.assign(paths,to:n.id)};plan=nil;refreshDraft()} catch {showError(error)}}
    @objc func removeAssignment() {guard !busy else{return};let ids=Set(draft.selectedRowIndexes.map {store.value.assignments[$0].id});do {try store.change {$0.assignments.removeAll {ids.contains($0.id)}};plan=nil;refreshDraft()} catch {showError(error)}}
    @objc func renameOutput() {let r=draft.selectedRow;guard r>=0,r<store.value.assignments.count else{return};let a=store.value.assignments[r];ask("Rename this copied drop or bucket",initial:a.outputName) {name in try Workspace.checkName(name);try store.change {if let i=$0.assignments.firstIndex(where:{$0.id==a.id}) {$0.assignments[i].outputName=name}}}}
    func setBusy(_ b:Bool) {busy=b;if b {spinner.startAnimation(nil)} else {spinner.stopAnimation(nil)};applyButton.isEnabled = !b && plan != nil;previewButton.isEnabled = !b && !store.value.assignments.isEmpty}
    @objc func verifyPreview() {
        guard !busy else{return};setBusy(true);plan=nil;applyButton.isEnabled=false;status.stringValue="Checking capacity, folder relationships and complete file hashes in the background…";let workspace=store.value
        transfers.async {[weak self] in
            let result:Result<CopyPlan,Error>=Result {try SafeFS.preview(workspace)}
            DispatchQueue.main.async {guard let self=self else{return};self.setBusy(false)
                switch result {case .success(let p):self.plan=p;self.refreshDraft();self.status.stringValue="Verified \(p.fileCount) files. Nothing copied. Review every exact path before applying.";self.showPlan(p)
                case .failure(let e):self.showError(e);self.status.stringValue="Preview held. All originals remain in place."}
            }
        }
    }
    func showPlan(_ p:CopyPlan) {
        let a=NSAlert();a.messageText="Verified exact copy preview";a.informativeText="\(p.buckets.count) drops / buckets · \(p.fileCount) files · \(ByteCountFormatter.string(fromByteCount:p.bytes,countStyle:.file)). This does not apply anything."
        let t=NSTextView(frame:NSRect(x:0,y:0,width:760,height:380));t.isEditable=false;t.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular)
        var blocks:[String]=[]
        for bucket in p.buckets {
            var lines:[String]=["SOURCE · retained",bucket.assignment.source,"→ "+bucket.destination,""]
            for record in bucket.records {
                let kind:String=record.directory ? "Folder: " : "File: "
                let name:String=record.relative.isEmpty ? "[bucket root]" : record.relative
                lines.append(kind+name)
                if let hash=record.hash {lines.append("  SHA-256 "+hash)}
            }
            blocks.append(lines.joined(separator:"\n"))
        }
        t.string=blocks.joined(separator:"\n\n────────────\n\n")
        let s=scroll(t);s.frame=NSRect(x:0,y:0,width:760,height:380);a.accessoryView=s;a.addButton(withTitle:"Keep reviewing");a.addButton(withTitle:"Export manifest…")
        if a.runModal() == .alertSecondButtonReturn {let save=NSSavePanel();save.nameFieldStringValue="konmagic-copy-preview.json";if save.runModal() == .OK,let u=save.url {do {try SafeFS.writeRecord(p,at:u)} catch {showError(error)}}}
    }
    @objc func applyCopy() {
        guard !busy,let p=plan else{return};let a=NSAlert();a.messageText="Apply this verified copy?"
        a.informativeText="Copy \(p.fileCount) files (\(ByteCountFormatter.string(fromByteCount:p.bytes,countStyle:.file))) to:\n\(p.output)\n\nOriginals remain intact. Every hash and destination is checked again. No overwrites, moves or deletions. A failed batch retains staged bytes and a recovery receipt."
        a.addButton(withTitle:"Copy this exact batch");a.addButton(withTitle:"Cancel")
        guard a.runModal() == .alertFirstButtonReturn else{return};let w=store.value;setBusy(true);status.stringValue="Verifying and copying. Originals remain intact; recovery is journaled."
        transfers.async {[weak self] in
            guard let self=self else{return};let result:Result<URL,Error>=Result {try SafeFS.copy(p,workspace:w,journalDirectory:self.store.directory.appendingPathComponent("Journal"))}
            DispatchQueue.main.async {self.setBusy(false);self.plan=nil;self.refreshDraft();switch result {
                case .success(let receipt):self.status.stringValue="Verified copy completed. Originals retained. Receipt: "+receipt.lastPathComponent
                case .failure(let e):self.showError(e);self.status.stringValue="Copy stopped. Inspect receipts and retained stages."}}
        }
    }
    @objc func openJournal() {let u=store.directory.appendingPathComponent("Journal");if FileManager.default.fileExists(atPath:u.path) {NSWorkspace.shared.open(u)} else {status.stringValue="No transfers have run. No receipts or recovery stages exist."}}
    func showError(_ e:Error) {let a=NSAlert();a.alertStyle = .warning;a.messageText="KonMagic kept the operation on hold";a.informativeText=e.localizedDescription;a.runModal()}
    @objc func showGuide() {
        guard !busy else{return}
        let pages:[(String,String)]=[
            ("Welcome to KonMagic", "A native Mac workspace for organizing with intention. You choose the structure and decide where things belong. Suggestions cannot override your assignments.\n\nThe left pane is your destination tree, the middle pane browses sources, and the right pane shows a draft of exact source → destination paths. Nothing moves when you browse or drag.\n\nKonMagic is independent and has no affiliation with Marie Kondo or KonMari."),
            ("Shape your semi-final structure", "New, Rename, Remove and destination drag/reparent edit a virtual structure. They do not create or rename real folders.\n\nKeep ongoing work in Projects and closed work in Archive. A project's active status is independent of an old parent-folder name. Add meaningful destinations for family memories, movies, work, research and other collections.\n\nStable destination identities keep assignments connected when you rename a branch. Undo draft edits without touching originals."),
            ("Assign drops and buckets", "A drop is an individual file. A bucket is a whole folder whose internal hierarchy and empty folders stay together.\n\nDrag directly from Finder onto a destination, or select sources and choose Assign selected. Multiple selected items can be assigned together. Rename output changes only the proposed copy's name.\n\nA bucket and its child cannot be assigned simultaneously. Split mixed collections into child buckets when they belong in different destinations."),
            ("Understand access and observations", "Native folder browsing reads current metadata in bounded pages. Searching an optional existing catalogue shows retained observations; some paths may have changed since ingestion. Extracted document bodies are not read or copied into a new index.\n\nFolder panels request access using your macOS account. KonMagic grants no privileges and bypasses no privacy permissions. Credentials, cloud placeholders, managed libraries, symlinks and operational project collections are held.\n\nNo server, login item, account or upload is installed."),
            ("Preview before you copy", "The draft shows exact source and destination paths immediately. Choose a local organized output folder, then Verify exact copy preview.\n\nVerification checks capacity before full-file hashing, source identities, all bucket contents, folder relationships and destination collisions. It creates no destination folders. Batches are bounded to 5,000 entries and 100 GiB, and leave 10 GiB free. Large video collections may need an external output drive.\n\nKeep reviewing or export the verified manifest. Verification alone applies nothing."),
            ("Copy deliberately; retain originals", "Review & copy opens a separate confirmation for the exact verified batch. All current identities, complete hashes and destinations are checked again.\n\nCopies preserve macOS file and folder metadata, verify every data hash and publish without overwriting. Originals stay intact. Receipts track completion and retained staging paths if interrupted; a batch is not one global transaction. Open Receipts & recovery to inspect them.\n\nMoving, deletion and deduplication are unavailable. Keep originals until a separate preservation and removal plan is reviewed.")]
        plan=nil;refreshDraft();var index=min(max(store.value.guidePage ?? 0,0),pages.count-1)
        while true {
            let a=NSAlert();a.messageText="\(index+1) / \(pages.count) · "+pages[index].0;a.informativeText=pages[index].1
            a.addButton(withTitle:index==pages.count-1 ? "Start organizing" : "Next")
            a.addButton(withTitle:index==0 ? "Continue later" : "Back")
            if index>0 {a.addButton(withTitle:"Continue later")}
            let response=a.runModal()
            if response == .alertFirstButtonReturn {
                if index==pages.count-1 {try? store.change {$0.welcomed=true;$0.guidePage=0};break}
                index+=1
            } else if response == .alertSecondButtonReturn,index>0 {index-=1}
            else {try? store.change {$0.guidePage=index};break}
            try? store.change {$0.guidePage=index}
        }
        refreshDraft()
    }
}

final class KonMagicDelegate: NSObject, NSApplicationDelegate {
    var window:NSWindow!
    var controller:KonMagicController!
    var lockFD:Int32 = -1
    let qa:Bool
    init(qa:Bool=false) {self.qa=qa}
    func applicationDidFinishLaunching(_ n:Notification) {
        do {
            let home=FileManager.default.homeDirectoryForCurrentUser
            let qaDefault=home.appendingPathComponent("Library/Caches/KonMagic UI QA").path
            let state=qa ? URL(fileURLWithPath:ProcessInfo.processInfo.environment["KONMAGIC_QA_STATE"] ?? qaDefault) : home.appendingPathComponent("Library/Application Support/KonMagic")
            let store=try WorkspaceStore(directory:state)
            lockFD=open(state.appendingPathComponent("instance.lock").path,O_RDWR | O_CREAT | O_NOFOLLOW,0o600)
            guard lockFD>=0,flock(lockFD,LOCK_EX | LOCK_NB)==0 else {throw KonMagicError("KonMagic is already running. Open the existing app window.")}
            controller=KonMagicController(store:store,catalog:Catalog(path:store.value.cataloguePath ?? home.appendingPathComponent("Library/Application Support/Workstation Atlas/catalog.sqlite3").path))
            for a in store.value.assignments {if let b=a.bookmark {var stale=false;if let u=try? URL(resolvingBookmarkData:b,options:[.withSecurityScope,.withoutUI],relativeTo:nil,bookmarkDataIsStale:&stale),!stale {controller.grant(u)}}}
            if let b=store.value.outputBookmark {var stale=false;if let u=try? URL(resolvingBookmarkData:b,options:[.withSecurityScope,.withoutUI],relativeTo:nil,bookmarkDataIsStale:&stale),!stale {controller.grant(u)}}
            if let b=store.value.catalogueBookmark {var stale=false;if let u=try? URL(resolvingBookmarkData:b,options:[.withSecurityScope,.withoutUI],relativeTo:nil,bookmarkDataIsStale:&stale),!stale {controller.grant(u)}}
            window=NSWindow(contentRect:NSRect(x:0,y:0,width:1360,height:820),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
            window.title="KonMagic";window.titlebarAppearsTransparent=true;window.minSize=NSSize(width:1180,height:740)
            if qa {window.appearance=NSAppearance(named:ProcessInfo.processInfo.environment["KONMAGIC_QA_APPEARANCE"]=="dark" ? .darkAqua : .aqua)}
            window.contentViewController=controller;window.center();if !qa {window.setFrameAutosaveName("KonMagicWorkspace")};window.makeKeyAndOrderFront(nil)
            controller.arrangeInitialPanes()
            let menu=NSMenu(),appMenu=NSMenu(),fileMenu=NSMenu()
            let appItem=NSMenuItem();appItem.submenu=appMenu;menu.addItem(appItem)
            appMenu.addItem(withTitle:"Welcome guide",action:#selector(KonMagicController.showGuide),keyEquivalent:"?").target=controller
            appMenu.addItem(NSMenuItem.separator());appMenu.addItem(withTitle:"Quit KonMagic",action:#selector(NSApplication.terminate(_:)),keyEquivalent:"q")
            let fileItem=NSMenuItem(title:"File",action:nil,keyEquivalent:"");fileItem.submenu=fileMenu;menu.addItem(fileItem)
            let commands:[(String,Selector,String)]=[("Choose source folder…",#selector(KonMagicController.chooseScope),"o"),("Connect catalogue…",#selector(KonMagicController.connectCatalog),""),("Choose output…",#selector(KonMagicController.chooseOutput),""),("Verify exact preview",#selector(KonMagicController.verifyPreview),"p"),("Undo draft edit",#selector(KonMagicController.undoDraft),"z")]
            for (title,action,key) in commands {fileMenu.addItem(withTitle:title,action:action,keyEquivalent:key).target=controller}
            fileMenu.addItem(withTitle:"Show hidden files in current folder",action:#selector(KonMagicController.toggleHidden(_:)),keyEquivalent:"").target=controller
            let editItem=NSMenuItem(title:"Edit",action:nil,keyEquivalent:""),editMenu=NSMenu();editItem.submenu=editMenu;menu.addItem(editItem)
            for (title,selector,key) in [("Cut","cut:","x"),("Copy","copy:","c"),("Paste","paste:","v"),("Select All","selectAll:","a")] {editMenu.addItem(withTitle:title,action:Selector(selector),keyEquivalent:key)}
            NSApp.mainMenu=menu;NSApp.activate(ignoringOtherApps:true)
            if qa {runUIQA()} else if !store.value.welcomed {DispatchQueue.main.asyncAfter(deadline:.now()+0.3) {self.controller.showGuide()}}
        } catch {let a=NSAlert();a.messageText="KonMagic could not open safely";a.informativeText=error.localizedDescription;a.runModal();NSApp.terminate(nil)}
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool {true}
    func applicationShouldTerminate(_ sender:NSApplication) -> NSApplication.TerminateReply {
        if controller?.busy==true {let a=NSAlert();a.messageText="A verification or copy is running";a.informativeText="Wait for it to finish. Quitting now could leave a retained stage that needs receipt review.";a.addButton(withTitle:"Keep KonMagic open");a.addButton(withTitle:"Quit and inspect receipts later");return a.runModal() == .alertSecondButtonReturn ? .terminateNow : .terminateCancel};return .terminateNow
    }
    func runUIQA() {
        DispatchQueue.main.asyncAfter(deadline:.now()+2) {
            self.window.contentView?.layoutSubtreeIfNeeded()
            if let v=self.window.contentView,let bitmap=v.bitmapImageRepForCachingDisplay(in:v.bounds) {
                v.effectiveAppearance.performAsCurrentDrawingAppearance {v.cacheDisplay(in:v.bounds,to:bitmap)}
                if let data=bitmap.representation(using:.png,properties:[:]),let path=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] {try? data.write(to:URL(fileURLWithPath:path));try? FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path)}
            }
            let board=NSPasteboard.withUniqueName();defer {board.releaseGlobally()}
            let paths=["/synthetic/first.txt","/synthetic/second.txt"]
            let item=NSPasteboardItem()
            if let data=try? JSONEncoder().encode(paths),let text=String(data:data,encoding:.utf8) {item.setString(text,forType:draftType)}
            board.writeObjects([item])
            let multipleDrops=self.controller.draggedPaths(board)==paths
            let widths=self.controller.split.arrangedSubviews.map {Int($0.frame.width)}
            let balanced=widths.count==3 && widths[0]<400 && widths[1]>=340 && widths[2]>=410
            let expanded=self.controller.outline.numberOfRows>self.controller.store.value.children(nil).count
            let passed=multipleDrops && balanced && expanded && !self.controller.applyButton.isEnabled && Thread.isMainThread
            print("UI_QA passed=\(passed); destinations=\(self.controller.store.value.nodes.count); rows=\(self.controller.items.count); paneWidths=\(widths); multipleDrops=\(multipleDrops); expandedTree=\(expanded); applyEnabled=\(self.controller.applyButton.isEnabled); userSourceOperations=0")
            if !passed {exit(1)}
            NSApp.terminate(nil)
        }
    }
}
