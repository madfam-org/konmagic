import AppKit
import Quartz
import UniformTypeIdentifiers
import Darwin

final class DiskLensController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate,QLPreviewPanelDataSource,QLPreviewPanelDelegate,NSWindowDelegate,NSUserInterfaceValidations {
    weak var workspace:KonMagicController?
    var window:NSWindow?,store:LensStore?,info:LensSnapshot?,selected:LensNode?,focusNode:LensNode?
    var watcher:LensWatcher?,twinGroup:String?
    let canvas=LensCanvas(),table=NSTableView(),inspector=KonMagicInspector(),search=NSSearchField(),destination=NSPopUpButton()
    let measure=NSPopUpButton(),display=NSPopUpButton(),color=NSPopUpButton(),palette=NSPopUpButton(),depth=NSPopUpButton(),units=NSPopUpButton(),recent=NSPopUpButton()
    let volume=NSButton(checkboxWithTitle:"Show volume context",target:nil,action:nil)
    let summary=NSTextField(wrappingLabelWithString:"Choose a recorded Atlas folder or scan current metadata. Original file bodies are not read."),status=NSTextField(wrappingLabelWithString:""),location=NSTextField(labelWithString:"No scan loaded"),legend=NSTextField(wrappingLabelWithString:"")
    let spinner=NSProgressIndicator()
    var rows:[LensNode]=[],preferences=LensPreferences(),mask=LensFilter(),scanExclusion=LensFilter(),generation=0
    var busy=false {didSet {workspace?.navigation?.refreshActivity()}}
    var listOffset=0,listGeneration=0
    let pagePrevious=NSButton(),pageNext=NSButton()
    var operationCancellation=CatalogueCancellation(),mapCancellation=CatalogueCancellation(),debounce:DispatchWorkItem?
    let operations=DispatchQueue(label:"org.madfam.konmagic.disk-scan",qos:.utility),drawing=DispatchQueue(label:"org.madfam.konmagic.disk-map",qos:.userInitiated)
    var sourceActionButtons:[NSButton]=[]
    let assignSourceButton=NSButton()
    var helpPopover:NSPopover?
    var viewOptions:NSStackView?
    var previewURL:URL?
    var directory:URL {workspace!.store.directory.appendingPathComponent("Disk Lens Scans")}
    init(workspace:KonMagicController) {self.workspace=workspace;preferences=LensPreferences.load(workspace.store.directory);scanExclusion=preferences.scanExclusion;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use a workspace")}
    func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField {let l=NSTextField(labelWithString:value);l.font=NSFont.systemFont(ofSize:size,weight:weight);return l}
    func button(_ title:String,_ action:Selector)->NSButton {let b=NSButton(title:title,target:self,action:action);b.bezelStyle = .rounded;return b}
    func row(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .horizontal;s.spacing=8;s.alignment = .centerY;return s}
    func column(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .vertical;s.spacing=10;s.alignment = .leading;return s}
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1480,height:930))
        measure.addItems(withTitles:LensMeasure.allCases.map(\.title));display.addItems(withTitles:LensDisplay.allCases.map(\.title));color.addItems(withTitles:LensColor.allCases.map(\.title));palette.addItems(withTitles:LensPalette.allCases.map {$0.rawValue.capitalized});depth.addItems(withTitles:["1","2","3","4","6","8","12","All (adaptive)"]);units.addItems(withTitles:["Binary units","Decimal units"])
        measure.selectItem(at:LensMeasure.allCases.firstIndex(of:preferences.measure)!);display.selectItem(at:LensDisplay.allCases.firstIndex(of:preferences.display)!);color.selectItem(at:LensColor.allCases.firstIndex(of:preferences.color)!);palette.selectItem(at:LensPalette.allCases.firstIndex(of:preferences.palette)!);depth.selectItem(withTitle:String(preferences.depth));units.selectItem(at:preferences.binaryUnits ? 0:1);volume.state=preferences.showVolume ? .on:.off
        for p in [measure,display,color,palette,depth,units] {p.target=self;p.action=#selector(settingsChanged)};volume.target=self;volume.action=#selector(settingsChanged)
        recent.addItem(withTitle:"Recent scans…");for path in preferences.recent.prefix(12) {recent.addItem(withTitle:path)};recent.target=self;recent.action=#selector(openRecent);recent.widthAnchor.constraint(lessThanOrEqualToConstant:240).isActive=true
        spinner.style = .spinning;spinner.isDisplayedWhenStopped=false;spinner.controlSize = .small
        let tools=NSPopUpButton(frame:.zero,pullsDown:true);tools.addItem(withTitle:"More tools")
        let groups:[[(String,Selector)]]=[
            [("Recorded Atlas folder…",#selector(chooseRecorded)),("Full rescan",#selector(rescan)),("Scan exclusions…",#selector(scanFilters))],
            [("Focus up",#selector(focusUp)),("Focus down",#selector(focusDown)),("Duplicate view",#selector(duplicate)),("Twin view",#selector(twin))],
            [("Mask…",#selector(editMask)),("Create filtered view…",#selector(filterView)),("Saved filters…",#selector(filterLibrary)),("File-type colors…",#selector(typeColors))],
            [("Save scan…",#selector(saveScan)),("Compare scans…",#selector(compareScan)),("Volume & snapshots…",#selector(showVolumeContext)),("Duplicate evidence…",#selector(duplicateReview)),("Scan notes…",#selector(notes)),("File & folder viewer…",#selector(richPreview))],
            [("Export map PNG / TIFF…",#selector(exportImage)),("Export complete scan text…",#selector(exportText))]]
        for group in groups {tools.menu?.addItem(.separator());for (title,action) in group {let item=NSMenuItem(title:title,action:action,keyEquivalent:"");item.target=self;tools.menu?.addItem(item)}}
        tools.setAccessibilityLabel("Additional disk analysis tools, filters, comparisons and exports")
        let head=row([label("Disk Lens",size:13,weight:.semibold),NSView(),spinner,button("Stop",#selector(stop)),button("Tips",#selector(showTips(_:)))])
        let scan=row([button("Scan current folder…",#selector(chooseScan)),button("Recorded machine",#selector(recordedMachine)),recent,button("Refresh",#selector(refresh)),button("Load scan…",#selector(loadScan)),NSView(),tools])
        let settings=row([display,label("Color by"),color,palette,label("Detail"),depth,units,volume]);viewOptions=settings;settings.isHidden=true
        let controls=row([button("↑ Parent",#selector(goParent)),button("Zoom selection",#selector(zoomSelection)),label("Size measure"),measure,NSView(),button("Customize view…",#selector(toggleViewOptions))])
        measure.toolTip="Logical file data, allocated blocks or unique counted files. None is a prediction of reclaimable APFS space."
        summary.toolTip="This scan is a point-in-time observation; gaps and retained source limits remain explicit."
        summary.font=NSFont.systemFont(ofSize:11);summary.textColor = .secondaryLabelColor;legend.font=NSFont.systemFont(ofSize:11);legend.textColor = .secondaryLabelColor;location.font=NSFont.systemFont(ofSize:11);location.lineBreakMode = .byTruncatingMiddle
        canvas.translatesAutoresizingMaskIntoConstraints=false;canvas.heightAnchor.constraint(greaterThanOrEqualToConstant:450).isActive=true
        canvas.selection={[weak self] tile in guard !tile.virtual else {self?.status.stringValue=tile.label+" · aggregate only";return};self?.select(tile.node)}
        canvas.zoom={[weak self] tile in if !tile.virtual {self?.navigate(tile.node.directory ? tile.node.id:tile.node.parent)}}
        canvas.focus={[weak self] direction in if direction>0 {self?.focusUp()} else {self?.focusDown()}}
        canvas.preview={[weak self] in self?.showQuickLook()}
        canvas.zoomOut={[weak self] in self?.goParent()}
        search.placeholderString="Search file names across this scan";search.delegate=self
        table.delegate=self;table.dataSource=self;table.rowHeight=29;table.usesAlternatingRowBackgroundColors=true;table.target=self;table.doubleAction=#selector(openRow)
        for (id,title,width) in [("name","Observed sources",195.0),("size","Size",105.0)] {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=title;c.width=width;table.addTableColumn(c)}
        let list=NSScrollView();list.documentView=table;list.hasVerticalScroller=true;list.heightAnchor.constraint(equalToConstant:185).isActive=true
        pagePrevious.title="Previous 200";pagePrevious.target=self;pagePrevious.action=#selector(previousRows);pagePrevious.bezelStyle = .rounded
        pageNext.title="Next 200";pageNext.target=self;pageNext.action=#selector(nextRows);pageNext.bezelStyle = .rounded
        inspector.isEditable=false;inspector.isSelectable=true;inspector.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);inspector.textContainerInset=NSSize(width:10,height:10);inspector.textContainer?.widthTracksTextView=true;inspector.autoresizingMask = [.width]
        inspector.string="Hover to inspect. Click locks selection; double-click zooms. Arrow keys navigate; Space opens Quick Look after checking current metadata.\n\nMasks retain area. Filtered views and scans are separate private snapshots. Missing dates are labelled Unknown.\n\nAllocated totals do not predict reclaimable APFS space. Cloud placeholders are counted from metadata without downloading."
        let detail=NSScrollView();detail.documentView=inspector;detail.hasVerticalScroller=true;detail.heightAnchor.constraint(greaterThanOrEqualToConstant:210).isActive=true
        sourceActionButtons=[button("Open",#selector(openSelected)),button("Quick Look",#selector(showQuickLook)),button("Reveal",#selector(reveal))]
        let actions=row(sourceActionButtons)
        assignSourceButton.title="Assign source to draft";assignSourceButton.target=self;assignSourceButton.action=#selector(assign);assignSourceButton.bezelStyle = .rounded;assignSourceButton.isEnabled=false
        destination.target=self;destination.action=#selector(destinationChanged)
        for b in sourceActionButtons {b.isEnabled=false}
        let right=column([search,list,row([pagePrevious,pageNext]),detail,actions,destination,assignSourceButton,button("Review cleanup in Finder",#selector(reviewCleanup)),button("Scan notes…",#selector(notes)),button("File & folder viewer…",#selector(richPreview))]);right.widthAnchor.constraint(equalToConstant:340).isActive=true
        for v in [search,list,detail,destination] {v.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true}
        let center=column([location,canvas,legend]);let content=row([center,right]);content.alignment = .top
        canvas.widthAnchor.constraint(equalTo:center.widthAnchor).isActive=true;center.widthAnchor.constraint(equalTo:content.widthAnchor,constant:-348).isActive=true
        center.heightAnchor.constraint(equalTo:content.heightAnchor).isActive=true;right.heightAnchor.constraint(equalTo:content.heightAnchor).isActive=true
        let outer=column([head,scan,controls,settings,summary,content,status]);outer.detachesHiddenViews=true;outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18)])
        for v in [head,scan,controls,settings,summary,content,status] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        refreshDestinations()
    }
    func refreshDestinations() {guard isViewLoaded,let w=workspace?.store.value else{return};let previous=workspace?.focusedDestinationID ?? destination.selectedItem?.representedObject as? String;destination.removeAllItems();destination.addItem(withTitle:"Choose a draft destination…");for n in w.nodes {if let path=try? w.path(n.id) {destination.addItem(withTitle:path);destination.lastItem?.representedObject=n.id}};if let previous=previous,let item=destination.itemArray.first(where:{$0.representedObject as? String==previous}) {destination.select(item)}}
    func applyViewPreferences(_ value:LensPreferences) {
        preferences=value;_ = view
        measure.selectItem(at:LensMeasure.allCases.firstIndex(of:value.measure)!);display.selectItem(at:LensDisplay.allCases.firstIndex(of:value.display)!);color.selectItem(at:LensColor.allCases.firstIndex(of:value.color)!);palette.selectItem(at:LensPalette.allCases.firstIndex(of:value.palette)!)
        depth.selectItem(withTitle:value.depth==999 ? "All (adaptive)" : String(value.depth));units.selectItem(at:value.binaryUnits ? 0:1);volume.state=value.showVolume ? .on:.off
    }
    func show() {if window==nil {let w=NSWindow(contentRect:NSRect(x:0,y:0,width:1480,height:930),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false);w.title="KonMagic · Disk Lens";w.minSize=NSSize(width:1380,height:850);w.contentViewController=self;w.isReleasedWhenClosed=false;w.delegate=self;w.center();window=w};window?.makeKeyAndOrderFront(nil)}
    func amount(_ n:Int64)->String {ByteCountFormatter.string(fromByteCount:n,countStyle:preferences.binaryUnits ? .binary:.decimal)}
    func chooseFolder()->URL? {let p=NSOpenPanel();p.canChooseDirectories=true;p.canChooseFiles=false;p.canCreateDirectories=false;return p.runModal() == .OK ? p.url:nil}
    @objc func chooseScan() {guard !busy,let root=chooseFolder() else{return};workspace?.grant(root);beginScan(root:root.path)}
    @objc func chooseRecorded() {guard !busy,let root=chooseFolder() else{return};beginScan(root:root.path,recorded:true)}
    @objc func recordedMachine() {beginScan(root:"/",recorded:true)}
    func beginScan(root:String,recorded:Bool=false,incremental:Bool=false) {
        guard !busy,let workspace=workspace else{return};let previous=store,events=watcher,dir=directory,filter=preferences.defaultFilter,exclude=scanExclusion
        if preferences.retainPreviousWindow && store != nil {duplicate()}
        let ledger=URL(fileURLWithPath:workspace.catalog.path).deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path
        if !recorded && !incremental {watcher=LensWatcher(root:root)}
        busy=true;operationCancellation=CatalogueCancellation();let cancel=operationCancellation;spinner.startAnimation(nil);status.stringValue="Preparing a bounded metadata-only snapshot. Stop retains partial coverage."
        operations.async {[weak self] in
            let result:Result<LensStore,Error>=Result {
                let scanner=try LensScanner(directory:dir,cancellation:cancel)
                scanner.progress={count,issues in DispatchQueue.main.async {self?.status.stringValue="\(count) metadata entries · \(issues) exceptions · file bodies unopened"}}
                return try recorded ? scanner.recorded(root:root,ledger:ledger) : scanner.run(root:root,filter:filter,exclude:exclude,previous:incremental ? previous:nil,changes:incremental ? events?.consume():nil)
            }
            DispatchQueue.main.async {guard let self=self else{return};self.busy=false;self.spinner.stopAnimation(nil);switch result {case .success(let store):self.open(store);case .failure(let error):self.status.stringValue=error.localizedDescription}}
        }
    }
    func open(_ store:LensStore) {
        do {let info=try store.snapshot();self.store=store;self.info=info;selected=nil;updateSourceControls();focusNode=try store.node(1);mask=LensFilter();search.stringValue="";listOffset=0;canvas.locked=false
            preferences.recent.removeAll {$0==store.url.path};preferences.recent.insert(store.url.path,at:0);preferences.recent=Array(preferences.recent.prefix(12));try preferences.save(workspace!.store.directory)
            recent.removeAllItems();recent.addItem(withTitle:"Recent scans…");recent.addItems(withTitles:preferences.recent)
            summary.stringValue="\(info.source) · \(info.status) · \(info.entries) records · \(info.totals.count) unique counted files · \(amount(info.totals.bytes)) logical / \(amount(info.totals.allocated)) allocated · \(info.issues) coverage exceptions · \(info.cloud) cloud entries · \(info.duplicates) repeated hard-link entries. Counts describe this snapshot; allocated bytes are not guaranteed reclaimable space."
            render();loadRows();status.stringValue="Retained scan loaded. No original file moved, deleted or opened."
        } catch {status.stringValue=error.localizedDescription}
    }
    @objc func openRecent() {guard !busy,recent.indexOfSelectedItem>0,let path=recent.titleOfSelectedItem else{return};watcher=nil;open(LensStore(url:URL(fileURLWithPath:path)))}
    @objc func stop() {operationCancellation.cancel();mapCancellation.cancel();status.stringValue="Stopping at a metadata boundary and retaining the partial scan…"}
    @objc func refresh() {guard !busy,let info=info else{return};if watcher==nil {status.stringValue="This saved/recorded view has no live event history. Performing a full rescan for accurate current metadata."};beginScan(root:info.root,incremental:watcher != nil)}
    @objc func rescan() {guard let info=info else{return};beginScan(root:info.root)}
    @objc func settingsChanged() {
        preferences.measure=LensMeasure.allCases[measure.indexOfSelectedItem];preferences.display=LensDisplay.allCases[display.indexOfSelectedItem];preferences.color=LensColor.allCases[color.indexOfSelectedItem];preferences.palette=LensPalette.allCases[palette.indexOfSelectedItem];preferences.depth=[1,2,3,4,6,8,12,999][max(0,depth.indexOfSelectedItem)];preferences.binaryUnits=units.indexOfSelectedItem==0;preferences.showVolume=volume.state == .on
        try? preferences.save(workspace!.store.directory);render();table.reloadData()
    }
    func render() {
        guard let store=store,let info=info,let focus=focusNode else{return};generation+=1;let ticket=generation;mapCancellation.cancel();mapCancellation=CatalogueCancellation();let cancel=mapCancellation,p=preferences,mask=self.mask
        view.layoutSubtreeIfNeeded();let bounds=canvas.bounds
        location.stringValue=store.path(focus,info);status.stringValue="Laying out the recorded hierarchy off the UI thread…"
        drawing.async {[weak self] in
            let result=Result {try LensMapBuilder(store:store,info:info,preferences:p,mask:mask,cancellation:cancel).build(focus:focus,bounds:bounds)}
            DispatchQueue.main.async {guard let self=self,self.generation==ticket else{return};switch result {
            case .success(let result):self.canvas.preferences=p;self.canvas.result=result;self.canvas.needsDisplay=true
                if !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {self.canvas.alphaValue=0.85;NSAnimationContext.runAnimationGroup({context in context.duration=0.12;self.canvas.animator().alphaValue=1})}
                self.legend.stringValue="Area: \(p.measure.title). Color: \(p.color.title) / \(p.palette.rawValue). \(result.omittedZero) zero-area entries at visited levels; \(result.collapsed) compact groups (zoom to resolve). Masked areas retain space. Directory overhead, APFS clones and snapshots prevent a reclaimable-space estimate."
                self.status.stringValue="\(result.tiles.count) visible rectangles · scope \(focus.total.count) files · \(self.amount(focus.total.weight(p.measure))) recorded weight. Small branches are grouped; the full scan remains searchable/exportable."
            case .failure(let error):self.status.stringValue=error.localizedDescription}
            }
        }
    }
    func windowDidResize(_ notification:Notification) {debounce?.cancel();let task=DispatchWorkItem {[weak self] in self?.render()};debounce=task;DispatchQueue.main.asyncAfter(deadline:.now()+0.2,execute:task)}
    func windowShouldClose(_ sender:NSWindow)->Bool {if busy {status.stringValue="Stop the scan first; its partial snapshot will be retained.";return false};return true}
    func navigate(_ id:Int64,synchronize:Bool=true) {
        guard let store=store,let node=try? store.node(id),node.directory else{return};focusNode=node;selected=nil;updateSourceControls();canvas.locked=false;search.stringValue="";listOffset=0;render();loadRows()
        if synchronize,let group=twinGroup {for other in workspace?.navigation?.workspaces.flatMap(\.lenses) ?? workspace?.lenses ?? [] where other !== self && other.twinGroup==group && other.store?.url==store.url {other.navigate(id,synchronize:false)}}
    }
    @objc func goParent() {if let node=focusNode,node.parent>0 {navigate(node.parent)}}
    @objc func zoomSelection() {if let selected=selected {navigate(selected.directory ? selected.id:selected.parent)}}
    @objc func focusUp() {if let n=selected,n.parent>0,let node=try? store?.node(n.parent) {select(node);canvas.selected=node.id;canvas.needsDisplay=true}}
    @objc func focusDown() {if let n=selected,let node=canvas.result.tiles.first(where:{$0.node.parent==n.id && !$0.virtual})?.node {select(node);canvas.selected=node.id;canvas.needsDisplay=true}}
    func loadRows() {
        guard let store=store,let focus=focusNode else{return};let query=String(search.stringValue.prefix(300)),offset=listOffset;listGeneration+=1;let ticket=listGeneration
        drawing.async {[weak self] in
            let result=Result {query.isEmpty ? try store.nodes(values:[String(focus.id)],limit:201,offset:offset) : try store.nodes(where:"instr(lower(n.name),lower(?))>0",values:[query],limit:201,offset:offset)}
            DispatchQueue.main.async {guard let self=self,self.listGeneration==ticket else{return};switch result {case .success(let rows):self.rows=Array(rows.prefix(200));self.pagePrevious.isEnabled=offset>0;self.pageNext.isEnabled=rows.count>200;self.table.deselectAll(nil);self.table.reloadData();case .failure(let error):self.status.stringValue=error.localizedDescription}}
        }
    }
    @objc func previousRows() {listOffset=max(0,listOffset-200);loadRows()}
    @objc func nextRows() {listOffset+=200;loadRows()}
    func controlTextDidChange(_ obj:Notification) {debounce?.cancel();listOffset=0;let work=DispatchWorkItem {[weak self] in self?.loadRows()};debounce=work;DispatchQueue.main.asyncAfter(deadline:.now()+0.3,execute:work)}
    func numberOfRows(in tableView:NSTableView)->Int {rows.count}
    func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView? {let n=rows[row];return label(column?.identifier.rawValue=="name" ? (n.directory ? "▸ ":"")+n.name : preferences.measure == .tally ? String(n.total.count)+" files":amount(n.total.weight(preferences.measure)),size:11)}
    func tableViewSelectionDidChange(_ notification:Notification) {let i=table.selectedRow;guard i>=0,i<rows.count else{return};select(rows[i]);canvas.selected=rows[i].id;canvas.needsDisplay=true}
    @objc func openRow() {let i=table.clickedRow;guard i>=0,i<rows.count else{return};if rows[i].directory {navigate(rows[i].id)} else {select(rows[i])}}
    func select(_ node:LensNode) {
        guard let store=store,let info=info else{return};selected=node;updateSourceControls();canvas.selectedRelative=node.relative;canvas.selectedDirectory=node.directory;canvas.needsDisplay=true;let path=store.path(node,info)
        func date(_ value:Int64)->String {value>0 ? ISO8601DateFormatter().string(from:Date(timeIntervalSince1970:Double(value))) : "Unknown in this observation"}
        inspector.string="RETAINED METADATA\n\(path)\n\n\(node.kindName) · package: \(node.package)\nLogical: \(amount(node.bytes))\nAllocated: \(amount(node.allocated))\nSubtree: \(node.total.count) counted files\nCreated: \(date(node.created))\nModified: \(date(node.modified))\nAccessed: \(date(node.accessed))\nLinks: \(node.links==0 ? "Unknown":String(node.links)) · repeated: \(node.duplicate)\nCloud placeholder: \(node.cloud)\nColor category: \(canvas.value(LensTile(node:node,frame:.zero,label:node.name,path:path)))\n\n\(node.error)\n\nSnapshot: \(info.status). Current identity is checked before opening/previewing. A scan does not verify byte contents."
        if let w=workspace?.store.value,let a=w.assignments.first(where:{$0.source==path}) {inspector.string+="\n\nDRAFT PREVIEW\n"+path+"\n→ "+((try? w.destination(a)) ?? "Invalid destination")}
        // Retained Atlas evidence is joined by the exact source path, with no content-body read.
        let catalog=workspace?.catalog;drawing.async {[weak self] in
            let result:CatalogItem? = try? catalog?.observation(at:path)
            DispatchQueue.main.async {guard let self=self,self.selected?.id==node.id,self.store?.url==store.url,let item=result else{return};self.inspector.string+="\n\nATLAS CONTENT & METACONTENT\n"+item.tags.sorted {$0.key<$1.key}.map {$0.key+": "+$0.value}.joined(separator:"\n")+"\nReading: "+item.state+"\nEvidence: "+item.evidence.joined(separator:"; ")}
        }
    }
    @objc func destinationChanged() {workspace?.focusedDestinationID=destination.selectedItem?.representedObject as? String;updateSourceControls()}
    @objc func updateSourceControls() {
        let real=selected.map {$0.kind==0 || $0.directory} ?? false
        let preview=real && selected?.cloud != true && selected.map {!SafeFS.guardedName($0.name)}==true
        for (i,b) in sourceActionButtons.enumerated() {b.isEnabled=i==2 ? selected != nil : preview}
        assignSourceButton.isEnabled=real && selected?.cloud != true && destination.selectedItem?.representedObject != nil && workspace?.busy != true
    }
    func currentURL() throws -> URL {
        guard let store=store,let info=info,let node=selected,node.kind==0 || node.directory else {throw KonMagicError("Select a real ordinary file or folder.")}
        let path=store.path(node,info),parent=try SafeFS.openDirectory(URL(fileURLWithPath:path).deletingLastPathComponent().path);defer {close(parent)}
        guard !(try SafeFS.components(path)).contains(where:SafeFS.guardedName) else {throw KonMagicError("Protected source ancestry is held from opening or content preview.")}
        let st=try SafeFS.info(parent,URL(fileURLWithPath:path).lastPathComponent)
        guard (node.directory && SafeFS.isDirectory(st)) || (node.kind==0 && SafeFS.isFile(st)),Int64(st.st_dev)==node.device,node.inode==Int64(bitPattern:UInt64(st.st_ino)),st.st_size==node.bytes,Int64(st.st_mtimespec.tv_sec)==node.modified else {throw KonMagicError("Source changed or is held since this scan. Rescan and review before opening.")}
        return URL(fileURLWithPath:path)
    }
    @objc func openSelected() {do {let url=try currentURL();guard !SafeFS.guardedName(url.lastPathComponent) else {throw KonMagicError("Protected collections stay in place; inspect metadata or reveal in Finder.")};NSWorkspace.shared.open(url)} catch {status.stringValue=error.localizedDescription}}
    @objc func reveal() {if let store=store,let info=info,let selected=selected {NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath:store.path(selected,info))])}}
    @objc func showQuickLook() {do {previewURL=try currentURL();guard let url=previewURL,!SafeFS.guardedName(url.lastPathComponent) else {throw KonMagicError("Protected collections are held from preview.")};let panel=QLPreviewPanel.shared()!;panel.dataSource=self;panel.delegate=self;panel.reloadData();panel.makeKeyAndOrderFront(nil)} catch {status.stringValue=error.localizedDescription}}
    func numberOfPreviewItems(in panel:QLPreviewPanel!)->Int {previewURL==nil ? 0:1}
    func previewPanel(_ panel:QLPreviewPanel!,previewItemAt index:Int)->QLPreviewItem! {previewURL as NSURL?}
    @objc func assign() {guard let w=workspace,!w.busy,let store=store,let info=info,let selected=selected,let id=destination.selectedItem?.representedObject as? String else{return};do {let path=store.path(selected,info);try w.store.change {try $0.assign([path],to:id)};w.plan=nil;w.focusedDestinationID=id;w.refreshDraft();select(selected);status.stringValue="Source assigned to your chosen draft destination. Exact paths are visible. No filesystem action ran.";w.status.stringValue=status.stringValue;w.presentAssignments([path])} catch {status.stringValue=error.localizedDescription}}
    @objc func reviewCleanup() {guard let store=store,let info=info,let selected=selected else{return};let path=store.path(selected,info);let a=NSAlert();a.messageText="Review this source in Finder";a.informativeText=path+"\n\nThis selects the real source in Finder for your review. KonMagic retains its read-only source policy. A filtered rectangle does not represent every file in a folder; hidden and newly created files may exist. No item is moved to Trash.";a.addButton(withTitle:"Reveal for review");a.addButton(withTitle:"Cancel");if a.runModal() == .alertFirstButtonReturn {reveal()}}
    @objc func returnToToolkit() {workspace?.showToolkit()}
    @objc func toggleViewOptions() {viewOptions?.isHidden.toggle()}
    func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool {
        if item.action==#selector(showVolumeContext) {return !busy}
        if [#selector(chooseRecorded),#selector(scanFilters),#selector(filterLibrary),#selector(typeColors)].contains(item.action) {return !busy}
        return store != nil && !busy
    }
    @objc func showCatalogue() {guard let w=workspace else{return};let path: String? = {guard let store=store,let info=info else{return nil};if let node=selected,node.directory {return store.path(node,info)};if let focus=focusNode {return store.path(focus,info)};return info.root}();w.showExplorer();if let path=path {w.explorer?.showRecordedFolder(path)}}
    @objc func duplicate() {guard let host=workspace?.navigation?.open(.storage),let other=host.workspace.lenses.first else{return};other.applyViewPreferences(preferences);if let store=store {other.open(store);other.mask=mask;if let focus=focusNode {other.navigate(focus.id,synchronize:false)}}}
    @objc func twin() {guard store != nil else{return};if twinGroup==nil {twinGroup=UUID().uuidString};guard let host=workspace?.navigation?.open(.storage),let other=host.workspace.lenses.first,let store=store else{return};other.twinGroup=twinGroup;other.applyViewPreferences(preferences);other.open(store);other.mask=mask;if let focus=focusNode {other.navigate(focus.id,synchronize:false)}}
    @objc func editMask() {if let filter=LensFilterEditor(mask).edit() {mask=filter;remember(filter);render()}}
    func remember(_ filter:LensFilter) {preferences.filters.removeAll {$0.name==filter.name};preferences.filters.append(filter);preferences.filters=Array(preferences.filters.suffix(32));try? preferences.save(workspace!.store.directory)}
    @objc func filterView() {guard !busy,let store=store,let filter=LensFilterEditor(mask).edit() else{return};remember(filter);perform("Creating a separately retained filtered view…") {try LensScanner.filter(store,using:filter,directory:self.directory,cancellation:self.operationCancellation)} completed:{self.open($0)}}
    @objc func scanFilters() {let alert=NSAlert();alert.messageText="Scan filter settings";alert.informativeText="An inclusion filter tests files while still traversing parent folders. An exclusion filter skips matching files and entire directory subtrees. Both record omitted coverage in the scan.";alert.addButton(withTitle:"Include matching files…");alert.addButton(withTitle:"Exclude matching subtrees…");alert.addButton(withTitle:"Cancel");let response=alert.runModal();if response == .alertFirstButtonReturn,let f=LensFilterEditor(preferences.defaultFilter).edit() {preferences.defaultFilter=f;remember(f)} else if response == .alertSecondButtonReturn,let f=LensFilterEditor(scanExclusion).edit() {scanExclusion=f;preferences.scanExclusion=f;remember(f)}}
    @objc func filterLibrary() {guard !preferences.filters.isEmpty else {status.stringValue="Create a mask, view filter or scan filter first; named tests are stored privately and can be reused here.";return};let a=NSAlert();a.messageText="Saved filters";let p=NSPopUpButton(frame:NSRect(x:0,y:0,width:380,height:28));p.addItems(withTitles:preferences.filters.map(\.name));a.accessoryView=p;a.addButton(withTitle:"Use as mask");a.addButton(withTitle:"Edit");a.addButton(withTitle:"Remove");a.addButton(withTitle:"Cancel");let response=a.runModal(),index=p.indexOfSelectedItem;guard index>=0,index<preferences.filters.count else{return};let filter=preferences.filters[index];if response == .alertFirstButtonReturn {mask=filter;render()} else if response == .alertSecondButtonReturn,let changed=LensFilterEditor(filter).edit() {preferences.filters.remove(at:index);remember(changed)} else if response == .alertThirdButtonReturn {preferences.filters.remove(at:index);try? preferences.save(workspace!.store.directory)}}
    @objc func typeColors() {let a=NSAlert();a.messageText="Custom file-type color categories";a.informativeText="Map extensions to your preferred categories, one extension=category per line. This changes coloring only; Atlas tags and source files remain unchanged.";let text=NSTextView(frame:NSRect(x:0,y:0,width:480,height:220));text.string=preferences.typeMappings.sorted {$0.key<$1.key}.map {$0.key+"="+$0.value}.joined(separator:"\n");a.accessoryView=text;a.addButton(withTitle:"Save colors");a.addButton(withTitle:"Cancel");if a.runModal() == .alertFirstButtonReturn {var mapping:[String:String]=[:];for line in text.string.split(separator:"\n").prefix(100) {let parts=line.split(separator:"=",maxSplits:1).map {String($0).trimmingCharacters(in:.whitespaces)};if parts.count==2,parts[0].count<=30,parts[1].count<=100,!parts[0].contains("/") {mapping[parts[0].lowercased()]=parts[1]}};preferences.typeMappings=mapping;try? preferences.save(workspace!.store.directory);render()}}
    func perform<T>(_ title:String,_ body:@escaping ()throws->T,completed:@escaping (T)->Void) {guard !busy else{return};busy=true;operationCancellation=CatalogueCancellation();spinner.startAnimation(nil);status.stringValue=title;operations.async {[weak self] in let result=Result(catching:body);DispatchQueue.main.async {guard let self=self else{return};self.busy=false;self.spinner.stopAnimation(nil);switch result {case .success(let value):completed(value);case .failure(let error):self.status.stringValue=error.localizedDescription}}}}
    @objc func loadScan() {guard !busy else{return};let p=NSOpenPanel();p.canChooseDirectories=false;p.allowedContentTypes=[UTType(exportedAs:"org.madfam.konmagic.scan",conformingTo:.database)];if p.runModal() == .OK,let url=p.url {watcher=nil;open(LensStore(url:url))}}
    @objc func saveScan() {guard let store=store else{return};let p=NSSavePanel();p.nameFieldStringValue="Disk scan.konmagic-scan";p.allowedContentTypes=[UTType(exportedAs:"org.madfam.konmagic.scan",conformingTo:.database)];if p.runModal() == .OK,let url=p.url {perform("Saving a separate scan copy…",{try store.copy(to:url);return url}) {_ in self.status.stringValue="Scan saved privately; originals unchanged."}}}
    @objc func notes() {guard let store=store,let info=info else{return};let a=NSAlert();a.messageText="Notes for this observation";let t=NSTextField(frame:NSRect(x:0,y:0,width:500,height:85));t.stringValue=info.comments;a.accessoryView=t;a.addButton(withTitle:"Save separate snapshot");a.addButton(withTitle:"Cancel");if a.runModal() == .alertFirstButtonReturn {let text=t.stringValue;perform("Saving scan notes…",{try store.comments(text,directory:self.directory)}) {self.open(LensStore(url:$0))}}}
    @objc func compareScan() {
        guard let store=store,!busy else{return}
        let p=NSOpenPanel();p.allowedContentTypes=[UTType(exportedAs:"org.madfam.konmagic.scan",conformingTo:.database)];p.message="Choose a baseline scan of the same root"
        if p.runModal() == .OK,let url=p.url {
            let comparison=ScanComparisonController(current:store,baseline:LensStore(url:url));comparisonControllers.append(comparison);if let host=workspace?.pageHost {host.showDetail(comparison,title:"Storage / Scan comparison") {_ in ScanComparisonController(current:store,baseline:LensStore(url:url))}} else {comparison.show()}
        }
    }
    var comparisonControllers:[ScanComparisonController]=[]
    var duplicateControllers:[DuplicateReviewController]=[]
    var comparisonWindows:[NSWindow]=[]
    @objc func exportImage() {let p=NSSavePanel();p.allowedContentTypes=[.png,.tiff];p.nameFieldStringValue="Disk map.png";if p.runModal() == .OK,let url=p.url,let image=canvas.bitmapImageRepForCachingDisplay(in:canvas.bounds) {canvas.effectiveAppearance.performAsCurrentDrawingAppearance {canvas.cacheDisplay(in:canvas.bounds,to:image)};if let data=image.representation(using:url.pathExtension=="tiff" ? .tiff:.png,properties:[:]) {do {try SafeFS.destinationClear(url.path);try data.write(to:url,options:.withoutOverwriting);try FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:url.path);status.stringValue="Current visible map exported; masked areas and grouping are retained."} catch {status.stringValue=error.localizedDescription}}}}
    @objc func exportText() {guard let store=store else{return};let p=NSSavePanel();p.allowedContentTypes=[.tabSeparatedText];p.nameFieldStringValue="Disk scan.tsv"
        let fields=["path","name","kind","logical","allocated","counted_logical","counted_allocated","files","modified","created","accessed","hard_links","cloud","package","issue"]
        let labels=["Source path","Name","File or folder","Logical bytes","Allocated bytes","Unique logical bytes","Unique allocated bytes","Counted files","Modified date","Created date","Accessed date","Hard links","Cloud state","Package flag","Coverage issue"]
        let checks=labels.map {NSButton(checkboxWithTitle:$0,target:nil,action:nil)};for c in checks {c.state = .on}
        let grid=NSGridView(views:stride(from:0,to:checks.count,by:3).map {Array(checks[$0..<min($0+3,checks.count)])});grid.columnSpacing=16;grid.rowSpacing=8
        p.accessoryView=dialogAccessory([grid])
        if p.runModal() == .OK,let url=p.url {let selected=zip(fields,checks).filter {$0.1.state == .on}.map {$0.0};perform("Exporting all recorded rows, independent of display focus and mask…",{try store.export(to:url,fields:selected,cancellation:self.operationCancellation)}) {_ in self.status.stringValue="Complete retained scan exported as escaped TSV. Unknown dates are zero; no source bodies read."}}
    }
}
