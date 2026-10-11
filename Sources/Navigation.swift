import AppKit

enum KonMagicPage:Int,CaseIterable {
    case toolkit,storage,content,structure,review
    var title:String {["Toolkit","Storage","Content","Structure","Review"][rawValue]}
    var minimum:NSSize {
        switch self {
        case .toolkit:return NSSize(width:1050,height:0) // Toolkit already owns its vertical scroll surface.
        case .storage:return NSSize(width:1380,height:880)
        case .content:return NSSize(width:1380,height:800)
        case .structure:return NSSize(width:1180,height:800)
        case .review:return NSSize(width:1440,height:820)
        }
    }
}

// A window owns its views and navigation; private decisions have one shared owner.
// Never attach an NSView to two windows, or create a second WorkspaceStore on disk.
final class KonMagicNavigation:NSObject,NSUserInterfaceValidations {
    weak var root:KonMagicController?
    var main:PageHostController!
    var additional:[PageHostController]=[]
    init(workspace:KonMagicController) {root=workspace;super.init();workspace.navigation=self;main=PageHostController(workspace:workspace,navigation:self,primary:true)}
    var hosts:[PageHostController] {[main]+additional}
    var workspaces:[KonMagicController] {hosts.map(\.workspace)}
    var transferBusy:Bool {workspaces.contains {$0.transferBusy}}
    var observationBusy:Bool {hosts.contains {$0.observationBusy}}
    var active:PageHostController {NSApp.keyWindow?.contentViewController as? PageHostController ?? NSApp.mainWindow?.contentViewController as? PageHostController ?? main}
    func refreshDraft() {
        for workspace in workspaces {
            if let plan=workspace.plan,(try? SafeFS.workspaceHash(workspace.store.value)) != plan.workspaceHash {workspace.plan=nil}
            workspace.refreshDraftLocally()
        }
        refreshActivity()
    }
    func refreshActivity() {for host in hosts {if host.isViewLoaded {host.updateNavigation()}}}
    func knowledgeChanged() {
        for workspace in workspaces {
            workspace.plan=nil;workspace.explorer?.reloadKnowledge()
            if workspace.isViewLoaded {workspace.loadSources()}
        }
        refreshDraft()
    }
    func connectCatalogue(_ path:String) {
        for workspace in workspaces {
            workspace.catalog=Catalog(path:path,knowledge:workspace.knowledge)
            workspace.explorer?.refresh();workspace.toolkit?.refresh()
            if workspace.isViewLoaded {workspace.loadSources()}
        }
        refreshDraft()
    }
    @discardableResult func open(_ page:KonMagicPage,from origin:PageHostController?=nil)->PageHostController? {
        guard let root=root else{return nil}
        do {
            let workspace=try KonMagicController(store:root.store,catalog:root.catalog,knowledge:root.knowledge)
            workspace.focusedDestinationID=origin?.workspace.focusedDestinationID
            workspace.navigation=self
            let host=PageHostController(workspace:workspace,navigation:self,primary:false)
            additional.append(host);host.makeWindow();host.navigate(page)
            if let source=origin {
                if page == .content,let before=source.workspace.explorer,let after=workspace.explorer {
                    after.dataset.selectItem(at:before.dataset.indexOfSelectedItem);after.changeDataset()
                    after.folder=before.folder;after.filters=before.filters;after.search.stringValue=before.search.stringValue
                    after.searchMode.selectItem(at:before.searchMode.indexOfSelectedItem);after.mode.selectedSegment=before.mode.selectedSegment
                    after.dimension.selectItem(at:before.dimension.indexOfSelectedItem);after.metric.selectItem(at:before.metric.indexOfSelectedItem)
                    after.updateMode();after.resetPaging();after.loadPage();after.loadSummary();if after.mode.selectedSegment==1 {after.loadRoots()}
                }
                if page == .storage,let before=source.workspace.lenses.first,let after=workspace.lenses.first {
                    after.applyViewPreferences(before.preferences)
                    if let store=before.store {after.open(store);after.mask=before.mask;if let focus=before.focusNode {after.navigate(focus.id,synchronize:false)}}
                    after.resolution.selectItem(at:before.resolution.indexOfSelectedItem);after.setMapFocus(before.mapFocused)
                    if after.inspectorVisible != before.inspectorVisible {after.toggleMapInspector()}
                    after.mapViewport.magnification=before.mapViewport.magnification;after.opticalZoomChanged()
                }
            }
            return host
        } catch {root.showError(error);return nil}
    }
    func closed(_ host:PageHostController) {additional.removeAll {$0 === host}}
    @objc func showToolkit() {active.navigate(.toolkit)}
    @objc func showStorage() {active.navigate(.storage)}
    @objc func showContent() {active.navigate(.content)}
    @objc func showStructure() {active.navigate(.structure)}
    @objc func showReview() {active.navigate(.review)}
    @objc func back() {active.goBack()}
    @objc func forward() {active.goForward()}
    @objc func openCurrent() {active.openCurrent()}
    @objc func chooseScope() {active.navigate(.structure);active.workspace.chooseScope()}
    @objc func connectCatalog() {active.workspace.connectCatalog()}
    @objc func chooseOutput() {active.navigate(.review);active.workspace.chooseOutput()}
    @objc func verifyPreview() {active.navigate(.review);active.workspace.verifyPreview()}
    @objc func undoDraft() {active.workspace.undoDraft()}
    @objc func showGuide() {active.workspace.showGuide()}
    @objc func showPreferences() {active.workspace.showPreferences()}
    @objc func toggleHidden(_ sender:NSMenuItem) {active.navigate(.structure);active.workspace.toggleHidden(sender)}
    func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool {
        if item.action==#selector(back) {return !active.history.isEmpty}
        if item.action==#selector(forward) {return !active.future.isEmpty}
        if item.action==#selector(verifyPreview) {return !transferBusy && !active.workspace.store.value.assignments.isEmpty}
        if [#selector(chooseScope),#selector(connectCatalog),#selector(chooseOutput),#selector(undoDraft)].contains(item.action) {return !transferBusy}
        return true
    }
    @objc func openPage(_ sender:NSMenuItem) {if let page=KonMagicPage(rawValue:sender.tag) {_ = open(page,from:active)}}
    @objc func showRunning() {
        for host in hosts {
            if host.workspace.transferBusy {host.navigate(.review);return}
            if let lens=host.workspace.lenses.first(where:{$0.busy}) {
                if lens === host.workspace.lenses.first {host.navigate(.storage)} else {lens.show()};return
            }
            if let detail=host.entries.values.first(where:{$0.busy}) {host.show(detail);return}
        }
    }
}

final class PageEntry {
    let id:String,title:String,controller:NSViewController,minimum:NSSize
    let base:KonMagicPage?
    let duplicate:((KonMagicController)->NSViewController)?
    init(id:String,title:String,controller:NSViewController,minimum:NSSize,base:KonMagicPage?=nil,duplicate:((KonMagicController)->NSViewController)?=nil) {
        self.id=id;self.title=title;self.controller=controller;self.minimum=minimum;self.base=base;self.duplicate=duplicate
    }
    var busy:Bool {
        if let c=controller as? ScanComparisonController {return c.busy}
        if let c=controller as? DuplicateReviewController {return c.busy}
        if let c=controller as? SourcePreviewController {return c.busy}
        return false
    }
}

private final class PageDocument:NSView {override var isFlipped:Bool {true}}
private final class PageViewport:NSScrollView {
    var minimum:NSSize
    var sizing=false
    init(controller:NSViewController,minimum:NSSize) {
        self.minimum=minimum;super.init(frame:.zero)
        hasVerticalScroller=true;hasHorizontalScroller=true;autohidesScrollers=true;borderType = .noBorder;drawsBackground=false
        let document=PageDocument(frame:NSRect(origin:.zero,size:minimum))
        let content=controller.view;content.translatesAutoresizingMaskIntoConstraints=true;content.frame=document.bounds;content.autoresizingMask=[.width,.height]
        document.addSubview(content);documentView=document
    }
    required init?(coder:NSCoder) {fatalError("Use page content")}
    override func tile() {
        super.tile();guard !sizing,let document=documentView else{return};sizing=true;defer {sizing=false}
        let size=NSSize(width:max(minimum.width,contentView.bounds.width),height:max(minimum.height,contentView.bounds.height))
        if document.frame.size != size {
            let origin=contentView.bounds.origin
            document.setFrameSize(size);contentView.scroll(to:origin);reflectScrolledClipView(contentView)
        }
    }
}

final class PageHostController:NSViewController,NSWindowDelegate {
    let workspace:KonMagicController,primary:Bool
    weak var navigation:KonMagicNavigation?
    var window:NSWindow?
    var entries:[String:PageEntry]=[:],presentations:[ObjectIdentifier:NSScrollView]=[:]
    var current:PageEntry?,history:[String]=[],future:[String]=[]
    let slot=NSView(),pageControl=NSSegmentedControl(labels:KonMagicPage.allCases.map(\.title),trackingMode:.selectOne,target:nil,action:nil)
    let back=NSButton(),forward=NSButton(),popout=NSButton(),activity=NSButton(),context=NSTextField(labelWithString:"")
    let guidance=NSTextField(wrappingLabelWithString:""),nextStep=NSButton()
    var navigationHeader:NSStackView?,navigationLine:NSBox?,normalSlotTop:NSLayoutConstraint?,focusedSlotTop:NSLayoutConstraint?
    init(workspace:KonMagicController,navigation:KonMagicNavigation,primary:Bool) {self.workspace=workspace;self.navigation=navigation;self.primary=primary;super.init(nibName:nil,bundle:nil);workspace.pageHost=self}
    required init?(coder:NSCoder) {fatalError("Use a workspace")}
    func makeWindow(_ existing:NSWindow?=nil,saveFrame:Bool=true) {
        let w=existing ?? NSWindow(contentRect:NSRect(x:0,y:0,width:1480,height:960),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false)
        window=w;w.contentViewController=self;w.delegate=self;w.isReleasedWhenClosed=false;w.titlebarAppearsTransparent=true
        w.minSize=NSSize(width:1100,height:740);w.title="KonMagic"
        let restored=primary && saveFrame && w.setFrameUsingName("KonMagicMain")
        if !restored {
            let available=(w.screen ?? NSScreen.main)?.visibleFrame.size ?? NSSize(width:1520,height:1040)
            w.setContentSize(NSSize(width:min(1480,max(1100,available.width-40)),height:min(960,max(740,available.height-60))));w.center()
        }
        if primary && saveFrame {w.setFrameAutosaveName("KonMagicMain")}
        w.makeKeyAndOrderFront(nil)
    }
    override func loadView() {
        view=FriendlyCanvas(frame:NSRect(x:0,y:0,width:1480,height:960))
        func setup(_ b:NSButton,_ title:String,_ symbol:String?,_ action:Selector) {
            b.title=title;b.target=self;b.action=action;b.bezelStyle = .rounded
            if let symbol=symbol {b.image=NSImage(systemSymbolName:symbol,accessibilityDescription:title);b.imagePosition=title.isEmpty ? .imageOnly:.imageLeading}
        }
        setup(back,"","chevron.left",#selector(goBack));back.toolTip="Back (⌘[)";back.setAccessibilityLabel("Previous page")
        setup(forward,"","chevron.right",#selector(goForward));forward.toolTip="Forward (⌘])";forward.setAccessibilityLabel("Next page")
        setup(popout,"Open page in new window","rectangle.on.rectangle",#selector(openCurrent));popout.toolTip="Open an independent view of this page (⇧⌘N). Private decisions stay shared."
        pageControl.target=self;pageControl.action=#selector(changePage);pageControl.setAccessibilityLabel("Pages in this window. Command 0 through 4.")
        pageControl.segmentStyle = .rounded;pageControl.controlSize = .large;pageControl.font=NSFont.systemFont(ofSize:13,weight:.medium)
        for (i,symbol) in ["house","internaldrive","doc.text","folder","checkmark.circle"].enumerated() {pageControl.setImage(NSImage(systemSymbolName:symbol,accessibilityDescription:nil),forSegment:i);pageControl.setWidth(108,forSegment:i)}
        for page in KonMagicPage.allCases {pageControl.setToolTip(["Choose a workflow · ⌘0","Observe disk size and physical structure · ⌘1","Browse, filter and correct retained content · ⌘2","Edit virtual destinations and assign sources · ⌘3","Inspect exact paths before separate verification and approval · ⌘4"][page.rawValue],forSegment:page.rawValue)}
        let top=NSStackView(views:[back,forward,pageControl,NSView(),popout]);top.spacing=10;top.orientation = .horizontal
        if !primary {let b=NSButton(title:"Main window",target:self,action:#selector(showMain));b.bezelStyle = .rounded;top.addArrangedSubview(b)}
        context.font=NSFont.systemFont(ofSize:15,weight:.semibold)
        guidance.font=NSFont.systemFont(ofSize:12);guidance.textColor = .secondaryLabelColor;guidance.maximumNumberOfLines=2
        setup(nextStep,"","arrow.right",#selector(continueJourney));nextStep.imagePosition = .imageTrailing;nextStep.setAccessibilityLabel("Contextual next step")
        setup(activity,"","arrow.triangle.2.circlepath",#selector(showRunning));activity.font=NSFont.systemFont(ofSize:11);activity.isBordered=false
        let words=NSStackView(views:[context,guidance]);words.orientation = .vertical;words.alignment = .leading;words.spacing=3
        let info=NSStackView(views:[words,NSView(),activity,nextStep]);info.spacing=12;guidance.widthAnchor.constraint(lessThanOrEqualToConstant:850).isActive=true
        let line=NSBox();line.boxType = .separator
        let header=NSStackView(views:[top,info]);header.orientation = .vertical;header.alignment = .leading;header.spacing=6
        navigationHeader=header;navigationLine=line
        header.translatesAutoresizingMaskIntoConstraints=false;line.translatesAutoresizingMaskIntoConstraints=false;slot.translatesAutoresizingMaskIntoConstraints=false
        for v in [header,line,slot] {view.addSubview(v)}
        normalSlotTop=slot.topAnchor.constraint(equalTo:line.bottomAnchor);focusedSlotTop=slot.topAnchor.constraint(equalTo:view.topAnchor)
        NSLayoutConstraint.activate([header.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:16),header.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-16),header.topAnchor.constraint(equalTo:view.topAnchor,constant:10),top.widthAnchor.constraint(equalTo:header.widthAnchor),info.widthAnchor.constraint(equalTo:header.widthAnchor),line.leadingAnchor.constraint(equalTo:view.leadingAnchor),line.trailingAnchor.constraint(equalTo:view.trailingAnchor),line.topAnchor.constraint(equalTo:header.bottomAnchor,constant:8),normalSlotTop!,slot.leadingAnchor.constraint(equalTo:view.leadingAnchor),slot.trailingAnchor.constraint(equalTo:view.trailingAnchor),slot.bottomAnchor.constraint(equalTo:view.bottomAnchor)])
    }
    func entry(_ page:KonMagicPage)->PageEntry {
        let id=String(page.rawValue);if let existing=entries[id] {return existing}
        let controller:NSViewController
        switch page {
        case .toolkit:
            if workspace.toolkit==nil {workspace.toolkit=ToolkitController(workspace:workspace)};controller=workspace.toolkit!
        case .content:
            if workspace.explorer==nil {workspace.explorer=CatalogueExplorerController(workspace:workspace)};controller=workspace.explorer!
        case .storage:
            if workspace.lenses.isEmpty {workspace.lenses.append(DiskLensController(workspace:workspace))};controller=workspace.lenses[0]
        case .structure:controller=workspace
        case .review:
            if workspace.review==nil {workspace.review=ReorganizationReviewController(workspace:workspace)};controller=workspace.review!
        }
        let e=PageEntry(id:id,title:page.title,controller:controller,minimum:page.minimum,base:page);entries[id]=e;return e
    }
    func navigate(_ page:KonMagicPage) {show(entry(page))}
    func show(_ entry:PageEntry,remember:Bool=true) {
        _ = view
        if remember,let old=current,old.id != entry.id {history.append(old.id);history=Array(history.suffix(32));future=[]}
        if let old=current,old.id != entry.id,let viewer=old.controller as? SourcePreviewController {viewer.clearContents()}
        if let old=current,old.id != entry.id,let explorer=old.controller as? CatalogueExplorerController {explorer.gallery.clear()}
        let first=presentations[ObjectIdentifier(entry.controller)]==nil
        current=entry
        let scroll:NSScrollView
        if let existing=presentations[ObjectIdentifier(entry.controller)] {scroll=existing}
        else {
            if entry.controller.parent==nil {addChild(entry.controller)}
            scroll=PageViewport(controller:entry.controller,minimum:entry.minimum)
            presentations[ObjectIdentifier(entry.controller)]=scroll
        }
        if scroll.superview !== slot {
            slot.subviews.forEach {$0.removeFromSuperview()};scroll.translatesAutoresizingMaskIntoConstraints=false;slot.addSubview(scroll)
            NSLayoutConstraint.activate([scroll.leadingAnchor.constraint(equalTo:slot.leadingAnchor),scroll.trailingAnchor.constraint(equalTo:slot.trailingAnchor),scroll.topAnchor.constraint(equalTo:slot.topAnchor),scroll.bottomAnchor.constraint(equalTo:slot.bottomAnchor)])
        }
        updateMapFocus();view.layoutSubtreeIfNeeded();updateNavigation()
        if entry.controller === workspace {if first {workspace.arrangeInitialPanes()};workspace.refreshDraft();if let id=workspace.focusedDestinationID {workspace.selectDestination(id)}}
        if let review=entry.controller as? ReorganizationReviewController {review.refresh()}
        if let hub=entry.controller as? ToolkitController {hub.updateDraft()}
        if let explorer=entry.controller as? CatalogueExplorerController {explorer.refreshDestinations()}
        if let lens=entry.controller as? DiskLensController {
            if first,let path=lens.preferences.recent.first,FileManager.default.fileExists(atPath:path) {lens.open(LensStore(url:URL(fileURLWithPath:path)))}
            else if lens.store != nil {lens.render()}
        }
        window?.makeKeyAndOrderFront(nil)
    }
    func showDetail(_ controller:NSViewController,title:String,duplicate:@escaping(KonMagicController)->NSViewController) {
        let changed:()->Void = {[weak navigation] in navigation?.refreshActivity()}
        if let c=controller as? ScanComparisonController {c.activityChanged=changed}
        if let c=controller as? DuplicateReviewController {c.activityChanged=changed}
        if let c=controller as? SourcePreviewController {c.activityChanged=changed}
        let e=PageEntry(id:UUID().uuidString,title:title,controller:controller,minimum:controller is SourcePreviewController ? NSSize(width:1260,height:850):NSSize(width:1050,height:700),duplicate:duplicate);entries[e.id]=e;show(e)
    }
    func updateNavigation() {
        back.isEnabled = !history.isEmpty;forward.isEnabled = !future.isEmpty;popout.isEnabled=current != nil
        pageControl.selectedSegment=current?.base?.rawValue ?? -1
        let title=current?.title ?? "Toolkit"
        let count=workspace.store.value.assignments.count,selected=workspace.explorer?.selectedRecords().count ?? 0
        let heading:String,hint:String,action:String
        switch current?.base {
        case .toolkit:heading="A little clarity, one decision at a time";hint="Observe → discover → shape → review. Your private draft stays with you across every page.";action=count>0 ? "Review draft (\(count))":"Find my content"
        case .storage:heading="Understand where your space goes";hint="Click to inspect, double-click to zoom. Continue into Content with this physical folder as your scope.";action="Browse this folder in Content"
        case .content:
            heading=selected>0 ? "\(selected) \(selected==1 ? "observation":"observations") selected":"Discover the context behind your files"
            let mode=workspace.explorer?.displayedView ?? 0
            hint=selected>0 ? "Inspect the evidence and proposed placement on the right. Choose an explicit destination before adding these sources to your draft." : ["Double-click a folder to explore. Select real sources to inspect evidence, correct tags and preview placement.","Expand physical folders lazily; double-click to list their contents. Semantic filters apply to lists and maps.","Expand owner → project → family. Double-click a group to list real sources, then return with Back to tag tree.","Click a region to narrow the collection. Back to map restores your previous scope, query and visualization.","Click a group or connection to inspect its real sources. Back to map restores the previous intersection.","Select cards to inspect their evidence. Load thumbnails explicitly; sources stay in place."][min(5,max(0,mode))]
            action=count>0 ? "Review draft (\(count))":"Shape destinations"
        case .structure:heading="Build a home for the things you know";hint="Choose a destination, then drop files or whole folders onto it. Every edit changes your virtual draft.";action=count>0 ? "Review exact paths (\(count))":"Discover sources"
        case .review:heading=workspace.busy ? "Verification or copying is underway":workspace.plan==nil ? "Know exactly where everything will go":"Your exact preview is verified";hint="Inspect each assignment and its full paths. Verification reads current hashes; copying still requires your separate approval.";action="Find more content"
        case nil:heading=title;hint="This analysis shares your private draft. Back returns to your previous page and keeps its context.";action="Return to Storage"
        }
        context.stringValue=heading+(primary ? "":" · Shared draft")
        guidance.stringValue=hint;nextStep.title=action;nextStep.toolTip=hint;nextStep.setAccessibilityLabel(action)
        window?.title="KonMagic · "+title
        let running=navigation?.transferBusy==true || navigation?.observationBusy==true
        activity.title=running ? "Work continues · Show activity" : "";activity.isHidden = !running
    }
    func updateMapFocus() {
        let lens=current?.controller as? DiskLensController,focused=lens?.mapFocused==true
        normalSlotTop?.isActive=false;focusedSlotTop?.isActive=false
        navigationHeader?.isHidden=focused;navigationLine?.isHidden=focused
        if focused {focusedSlotTop?.isActive=true} else {normalSlotTop?.isActive=true}
        if let current=current,let viewport=presentations[ObjectIdentifier(current.controller)] as? PageViewport {
            let minimum=focused ? NSSize(width:lens?.inspectorVisible==true ? 1380:1100,height:500):current.minimum
            if viewport.minimum != minimum {viewport.minimum=minimum;viewport.contentView.scroll(to:.zero);viewport.tile()}
        }
        view.layoutSubtreeIfNeeded()
    }
    @objc func continueJourney() {
        switch current?.base {
        case .toolkit: navigate(workspace.store.value.assignments.isEmpty ? .content:.review)
        case .storage:workspace.lenses.first?.showCatalogue()
        case .content:navigate(workspace.store.value.assignments.isEmpty ? .structure:.review)
        case .structure:navigate(workspace.store.value.assignments.isEmpty ? .content:.review)
        case .review:navigate(.content)
        case nil:navigate(.storage)
        }
    }
    @objc func changePage() {if let page=KonMagicPage(rawValue:pageControl.selectedSegment) {navigate(page)}}
    @objc func goBack() {guard let id=history.popLast(),let e=entries[id] else{return};if let old=current {future.append(old.id)};show(e,remember:false)}
    @objc func goForward() {guard let id=future.popLast(),let e=entries[id] else{return};if let old=current {history.append(old.id)};show(e,remember:false)}
    @objc func showMain() {navigation?.main.window?.makeKeyAndOrderFront(nil)}
    @objc func showRunning() {navigation?.showRunning()}
    @objc func openCurrent() {
        guard let current=current,let navigation=navigation else{return}
        if let page=current.base {_ = navigation.open(page,from:self)}
        else if let duplicate=current.duplicate,let host=navigation.open(.toolkit) {host.showDetail(duplicate(host.workspace),title:current.title,duplicate:duplicate)}
    }
    var observationBusy:Bool {workspace.lenses.contains {$0.busy || $0.comparisonControllers.contains {$0.busy} || $0.duplicateControllers.contains {$0.busy}} || entries.values.contains {$0.busy}}
    var canClose:Bool {!workspace.transferBusy && !observationBusy}
    func windowShouldClose(_ sender:NSWindow)->Bool {
        if !canClose {let a=NSAlert();a.messageText="Work is still running in this window";a.informativeText="Keep this window open until verification, copying or export finishes. Stop scans or hash verification in their page to retain partial work.";a.addButton(withTitle:"Keep window open");a.runModal();return false};return true
    }
    func windowWillClose(_ notification:Notification) {
        if !primary {navigation?.closed(self);window?.contentViewController=nil;window=nil}
    }
    func windowDidResize(_ notification:Notification) {if let lens=current?.controller as? DiskLensController {lens.windowDidResize(notification)}}
}
