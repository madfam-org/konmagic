import AppKit
import Darwin
import Quartz

struct ExplorerDrillContext {
    let folder:String?,filters:[CatalogueDimension:String],query:String
    let visualization:Int,dimension:Int,metric:Int,searchMode:Int
}

final class ExplorerNode:NSObject {
    var item:CatalogItem?
    var title:String
    var choices:[CatalogueDimension:String]=[:]
    var children:[ExplorerNode]?
    var level=0
    var nextCursor:String?
    var diskOffset=0
    var more=false
    var tagStamp:String?
    weak var parent:ExplorerNode?
    init(_ item:CatalogItem) {self.item=item;title=item.name}
    init(title:String,choices:[CatalogueDimension:String],level:Int) {self.title=title;self.choices=choices;self.level=level}
}

final class CatalogueExplorerController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,
    NSOutlineViewDataSource,NSOutlineViewDelegate,NSSearchFieldDelegate {
    weak var workspace:KonMagicController?
    var window:NSWindow?
    let dataset=NSPopUpButton(),dimension=NSPopUpButton(),destination=NSPopUpButton(),search=NSSearchField()
    let searchMode=NSPopUpButton(),metric=NSPopUpButton(),places=NSPopUpButton()
    let mode=NSSegmentedControl(labels:["List","Folders","Tags","Map","Connections","Gallery"],trackingMode:.selectOne,target:nil,action:nil)
    let overview=NSTextField(wrappingLabelWithString:"Connecting retained Atlas observations…")
    let filterLabel=NSTextField(wrappingLabelWithString:"No filters"),status=NSTextField(labelWithString:""),location=NSTextField(labelWithString:"")
    let facetTable=NSTableView(),table=NSTableView(),tree=NSOutlineView(),inspector=KonMagicInspector(),map=CatalogueMapView()
    let contentHost=NSView(),bodyButton=NSButton(),nextButton=NSButton(),previousButton=NSButton()
    let correctButton=NSButton(),assignButton=NSButton(),revealButton=NSButton(),previewSourceButton=NSButton()
    let proposedPath=NSTextField(wrappingLabelWithString:"Choose a destination to preview placement."),backToMap=NSButton(),filterChips=NSStackView(),chipScroll=NSScrollView()
    var drillContext:ExplorerDrillContext?
    var listScroll:NSScrollView!,treeScroll:NSScrollView!
    var records:[CatalogItem]=[],roots:[ExplorerNode]=[],facets:[CatalogueFacet]=[]
    var filters:[CatalogueDimension:String]=[:],folder:String?,cursor:String?,cursorHistory:[String?]=[]
    var diskOffset=0,nextCursor:String?,nextDiskOffset:Int?
    var summary:CatalogueSummary?,allSummary:CatalogueSummary?,diskOverview:DiskOverview?
    var generation=0,summaryGeneration=0
    var debounce:DispatchWorkItem?,metadataDebounce:DispatchWorkItem?
    var pageCancellation=CatalogueCancellation(),summaryCancellation=CatalogueCancellation()
    let browsing=DispatchQueue(label:"org.madfam.konmagic.explorer-pages",qos:.userInitiated)
    let aggregating=DispatchQueue(label:"org.madfam.konmagic.explorer-aggregates",qos:.utility)
    var displayedView=0
    var metadataTicket=0
    var helpPopover:NSPopover?
    var pageLoading=false,summaryLoading=false,treeLoading=false,pageError:String?,summaryError:String?,treeError:String?,treeGeneration=0
    var selectionPending:Bool {handoffLoading || ((displayedView==0 || displayedView==5) ? pageLoading : displayedView==1 && treeLoading)}
    lazy var resultState=ContentResultState(owner:self)
    let classificationSummary=FriendlyUI.label("Select material to see its classification.",size:11,wrapping:true)
    let journeyHint=FriendlyUI.label("Inspect → refine tags → choose a destination → review",size:11,wrapping:true)
    let previewPlacementButton=NSButton()
    lazy var gallery=ContentGallery(owner:self)
    var galleryScroll:NSScrollView!
    let selectionImage=NSImageView(),selectionName=FriendlyUI.label("Choose a file or folder",size:15,weight:.semibold,wrapping:true),selectionSummary=FriendlyUI.label("",size:11,wrapping:true),selectionSource=FriendlyUI.label("",size:10,wrapping:true)
    let familyButtons=NSStackView()
    var detailScroll:NSScrollView?
    let focusContentButton=NSButton(),sourcesToggle=NSButton(),contentInspectorToggle=NSButton(),sourcePreviewToolbar=NSButton(),mapFitButton=NSButton(),density=NSPopUpButton()
    let thumbnailButton=NSButton(),releaseImagesButton=NSButton(),handoffButton=NSButton()
    let compactSelection=FriendlyUI.label("Originals stay in place",size:10)
    lazy var contentMapViewport=LensViewport(canvas:map)
    let inlinePreview=QLPreviewView(frame:.zero,style:.normal)!
    var inlinePreviewPath:String?,inlinePreviewGeneration=0
    let previewWork=DispatchQueue(label:"org.madfam.konmagic.inline-preview",qos:.userInitiated)
    var contentFocused=false,sourcesVisible=true,contentInspectorVisible=true
    var contentChrome:[NSView]=[],contentEdges:[NSLayoutConstraint]=[]
    var sourcesPanel:FriendlyPanel?,contentInspectorPanel:FriendlyPanel?,contentCenterPanel:FriendlyPanel?
    var contentOuter:NSStackView?,contentColumns:NSStackView?,contentCenter:NSStackView?,contentWidth:NSLayoutConstraint?,handoffBar:NSStackView?
    var physicalTreeState:ContentTreeState?,tagTreeState:ContentTreeState?,physicalTreeKey:String?,tagTreeKey:String?
    var handoff:ContentHandoff?,handoffSelected=false,handoffLoading=false,handoffRevision=0
    var tagged:Bool {dataset.indexOfSelectedItem==0}
    var disk:DiskCatalogue {DiskCatalogue(path:URL(fileURLWithPath:workspace?.catalog.path ?? "").deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path,knowledge:workspace?.knowledge)}
    var activeDimension:CatalogueDimension {CatalogueDimension.allCases[max(0,dimension.indexOfSelectedItem)]}
    init(workspace:KonMagicController) {self.workspace=workspace;folder=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use a workspace")}
    func text(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField {
        let label=NSTextField(labelWithString:value);label.font=NSFont.systemFont(ofSize:size,weight:weight);label.lineBreakMode = .byTruncatingMiddle;return label
    }
    func button(_ title:String,_ action:Selector)->NSButton {let b=NSButton(title:title,target:self,action:action);b.bezelStyle = .rounded;return b}
    func row(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .horizontal;s.spacing=8;s.alignment = .centerY;return s}
    func column(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .vertical;s.spacing=10;s.alignment = .leading;return s}
    func scroll(_ view:NSView)->NSScrollView {let s=NSScrollView();s.documentView=view;s.hasVerticalScroller=true;s.autohidesScrollers=true;s.borderType = .noBorder;return s}
    func setupTable(_ table:NSTableView,columns:[(String,String,CGFloat)]) {
        table.delegate=self;table.dataSource=self;table.rowHeight=48;table.usesAlternatingRowBackgroundColors=true;table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        for (id,title,width) in columns {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=title;c.width=width;c.minWidth=60;table.addTableColumn(c)}
    }
    override func loadView() {
        let canvas=ContentStageHost(frame:NSRect(x:0,y:0,width:1480,height:900));canvas.owner=self;view=canvas
        dataset.addItems(withTitles:["Content & tags","Recorded disk","Access exceptions"]);dataset.target=self;dataset.action=#selector(changeDataset)
        dimension.addItems(withTitles:CatalogueDimension.allCases.map(\.title));dimension.target=self;dimension.action=#selector(changeDimension)
        searchMode.addItems(withTitles:["Names, paths & tags","Indexed content"]);searchMode.target=self;searchMode.action=#selector(searchChanged)
        search.placeholderString="Search retained observations";search.delegate=self
        metric.addItems(withTitles:["Entries","Logical file bytes"]);metric.target=self;metric.action=#selector(changeMetric)
        mode.selectedSegment=0;mode.target=self;mode.action=#selector(changeVisualization)
        overview.font=NSFont.systemFont(ofSize:11);overview.textColor = .secondaryLabelColor
        let mascot=FriendlyMascot(kind:0);mascot.widthAnchor.constraint(equalToConstant:68).isActive=true;mascot.heightAnchor.constraint(equalToConstant:76).isActive=true
        let heading=column([FriendlyUI.label("KONMAGIC  /  DISCOVER",size:10,weight:.semibold),FriendlyUI.label("Content",size:32,weight:.bold),FriendlyUI.label("What is this material, and what belongs together?",size:12)])
        let header=row([mascot,heading,NSView(),button("Tips",#selector(showTips(_:))),button("Collections…",#selector(collectionsMenu)),button("Rules…",#selector(rulesMenu))])
        places.addItem(withTitle:"All retained content")
        for name in ["Downloads","Documents","Desktop","Pictures","Movies","Music"] {places.addItem(withTitle:name);places.lastItem?.representedObject=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(name).path}
        places.selectItem(at:1);places.target=self;places.action=#selector(changePlace)
        places.toolTip="Browse a familiar folder, or choose All retained content for the whole tagged catalogue. Searches within a folder include its descendants."
        let tools=NSPopUpButton(frame:.zero,pullsDown:true);tools.addItem(withTitle:"More");tools.menu?.items.first?.image=NSImage(systemSymbolName:"ellipsis.circle",accessibilityDescription:"Content tools")
        for (title,action) in [("Clear search & filters",#selector(clearFilters)),("Refresh observation",#selector(refresh)),("Collections…",#selector(collectionsMenu)),("Rules…",#selector(rulesMenu)),("Content guide",#selector(contentGuide)),("Return to Storage",#selector(returnToStorage))] {let item=NSMenuItem(title:title,action:action,keyEquivalent:"");item.target=self;tools.menu?.addItem(item)}
        tools.widthAnchor.constraint(equalToConstant:68).isActive=true;tools.setAccessibilityLabel("Content tools, collections, rules and help")
        let query=row([dataset,search,searchMode,tools]);dataset.controlSize = .small;dataset.widthAnchor.constraint(equalToConstant:152).isActive=true;searchMode.widthAnchor.constraint(equalToConstant:140).isActive=true;searchMode.controlSize = .small
        searchMode.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        focusContentButton.title="Focus content";focusContentButton.target=self;focusContentButton.action=#selector(toggleContentFocus);focusContentButton.keyEquivalent="m";focusContentButton.keyEquivalentModifierMask=[.command,.shift]
        for (b,title,action) in [(sourcesToggle,"Sources",#selector(toggleContentSources)),(contentInspectorToggle,"Inspector",#selector(toggleContentInspector))] {b.title=title;b.target=self;b.action=action;b.setButtonType(.pushOnPushOff);b.state = .on}
        for b in [sourcesToggle,contentInspectorToggle,focusContentButton] {b.bezelStyle = .rounded}
        sourcePreviewToolbar.title="Preview";sourcePreviewToolbar.target=self;sourcePreviewToolbar.action=#selector(previewInInspector);sourcePreviewToolbar.bezelStyle = .rounded;sourcePreviewToolbar.toolTip="Explicitly view one file with native Quick Look, or open a folder viewer. Selection alone reads no file body."
        density.addItems(withTitles:["Small cards","Comfortable","Large cards"]);density.selectItem(at:1);density.target=self;density.action=#selector(galleryDensityChanged);density.widthAnchor.constraint(equalToConstant:110).isActive=true
        mapFitButton.title="Fit map";mapFitButton.target=self;mapFitButton.action=#selector(contentFitMap);mapFitButton.bezelStyle = .rounded
        mode.segmentStyle = .rounded;mode.controlSize = .small;mode.toolTip="Switch views without requerying an unchanged slice. ⌥⌘1–6 · ⌘F searches. Maps are semantic aggregates; virtual groups never become source assignments."
        let workspaceBar=row([FriendlyUI.image("doc.text",tint:FriendlyUI.violet,size:18),mode,NSView(),density,mapFitButton,sourcePreviewToolbar,sourcesToggle,contentInspectorToggle,focusContentButton,button("Full screen",#selector(contentFullScreen))]);workspaceBar.detachesHiddenViews=true
        handoffButton.target=self;handoffButton.action=#selector(selectStorageHandoff);handoffButton.bezelStyle = .rounded
        let handoffRow=row([handoffButton,NSView(),button("Return to Storage",#selector(returnToStorage)),button("Clear",#selector(clearStorageHandoff))]);handoffBar=handoffRow;handoffRow.isHidden=true
        search.widthAnchor.constraint(greaterThanOrEqualToConstant:200).isActive=true

        setupTable(facetTable,columns:[("group","Facet",155),("count","Entries",72)]);facetTable.rowHeight=32;facetTable.target=self;facetTable.action=#selector(selectFacet)
        facetTable.setAccessibilityLabel("Complete catalogue facet groups. Selecting a group filters observations.")
        familyButtons.orientation = .vertical;familyButtons.alignment = .leading;familyButtons.spacing=6
        let facetScroll=scroll(facetTable),left=column([FriendlyUI.label("SOURCES & COLLECTIONS",size:11,weight:.semibold),places,button("All retained files",#selector(clearFilters)),familyButtons,FriendlyUI.label("REFINE THIS SLICE",size:10,weight:.semibold),dimension,facetScroll,button("Edit destinations",#selector(editDestinations))])
        left.widthAnchor.constraint(equalToConstant:210).isActive=true
        facetScroll.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true

        setupTable(table,columns:[("name","Files & folders",285),("tags","Tags & reading",230),("size","Size",95)])
        table.allowsMultipleSelection=true;table.target=self;table.doubleAction=#selector(openObservation)
        table.setAccessibilityLabel("Retained observations, including protected and metadata-only records")
        table.setDraggingSourceOperationMask(.copy,forLocal:true)
        listScroll=scroll(table);treeScroll=scroll(tree);galleryScroll=scroll(gallery);gallery.autoresizingMask = [.width];galleryScroll.drawsBackground=false
        tree.delegate=self;tree.dataSource=self;tree.headerView=nil;tree.rowHeight=30;tree.allowsMultipleSelection=true
        let treeColumn=NSTableColumn(identifier:NSUserInterfaceItemIdentifier("tree"));treeColumn.width=500;tree.addTableColumn(treeColumn);tree.outlineTableColumn=treeColumn
        tree.target=self;tree.doubleAction=#selector(openTreeSelection);tree.setDraggingSourceOperationMask(.copy,forLocal:true)
        tree.setAccessibilityLabel("Observed folder tree or tag hierarchy. Expand lazily; double-click to list contents. Virtual tag groups cannot be assigned as source folders.")
        for child in [listScroll!,treeScroll!,contentMapViewport,galleryScroll!] {
            child.translatesAutoresizingMaskIntoConstraints=false;contentHost.addSubview(child)
            NSLayoutConstraint.activate([child.leadingAnchor.constraint(equalTo:contentHost.leadingAnchor),child.trailingAnchor.constraint(equalTo:contentHost.trailingAnchor),child.topAnchor.constraint(equalTo:contentHost.topAnchor),child.bottomAnchor.constraint(equalTo:contentHost.bottomAnchor)])
        }
        treeScroll.isHidden=true;contentMapViewport.isHidden=true;galleryScroll.isHidden=true
        resultState.translatesAutoresizingMaskIntoConstraints=false;contentHost.addSubview(resultState)
        NSLayoutConstraint.activate([resultState.centerXAnchor.constraint(equalTo:contentHost.centerXAnchor),resultState.centerYAnchor.constraint(equalTo:contentHost.centerYAnchor),resultState.widthAnchor.constraint(equalTo:contentHost.widthAnchor,constant:-40)])
        resultState.isHidden=true
        map.activated={[weak self] choices in guard self?.summaryLoading==false else{return};self?.drillInto(choices)}
        nextButton.title="Next 200";nextButton.target=self;nextButton.action=#selector(nextPage);nextButton.bezelStyle = .rounded
        previousButton.title="Previous";previousButton.target=self;previousButton.action=#selector(previousPage);previousButton.bezelStyle = .rounded
        location.font=NSFont.systemFont(ofSize:10);location.textColor = .secondaryLabelColor
        backToMap.title="Back to map";backToMap.target=self;backToMap.action=#selector(restoreDrillContext);backToMap.bezelStyle = .rounded;backToMap.isHidden=true
        filterChips.orientation = .horizontal;filterChips.spacing=6;chipScroll.documentView=filterChips;chipScroll.hasHorizontalScroller=true;chipScroll.autohidesScrollers=true;chipScroll.drawsBackground=false;chipScroll.heightAnchor.constraint(equalToConstant:30).isActive=true;chipScroll.isHidden=true
        thumbnailButton.title="Thumbnails";thumbnailButton.target=self;thumbnailButton.action=#selector(loadGalleryThumbnails);thumbnailButton.bezelStyle = .rounded
        releaseImagesButton.title="Clear images";releaseImagesButton.target=self;releaseImagesButton.action=#selector(clearGalleryImages);releaseImagesButton.bezelStyle = .rounded
        let paging=row([previousButton,nextButton,NSView(),thumbnailButton,releaseImagesButton]);paging.detachesHiddenViews=true
        let center=column([query,row([backToMap,filterLabel,NSView(),metric]),chipScroll,row([button("↑ Parent",#selector(parentFolder)),location]),contentHost,paging,status]);contentCenter=center;center.detachesHiddenViews=true
        location.lineBreakMode = .byTruncatingMiddle;location.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        status.lineBreakMode = .byTruncatingMiddle;status.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        compactSelection.lineBreakMode = .byTruncatingMiddle;compactSelection.textColor=FriendlyUI.muted;compactSelection.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        contentHost.heightAnchor.constraint(greaterThanOrEqualToConstant:330).isActive=true
        query.widthAnchor.constraint(equalTo:center.widthAnchor).isActive=true
        for v in [query,contentHost,chipScroll,status] {v.widthAnchor.constraint(equalTo:center.widthAnchor).isActive=true}
        center.widthAnchor.constraint(greaterThanOrEqualToConstant:480).isActive=true

        inspector.isEditable=false;inspector.isSelectable=true;inspector.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);inspector.textContainerInset=NSSize(width:12,height:12)
        inspector.isVerticallyResizable=true;inspector.autoresizingMask = [.width];inspector.textContainer?.widthTracksTextView=true
        inspector.string="Select a file or whole folder to inspect its tags, evidence, reading status and current metadata.\n\nMaps and virtual tag groups filter observations. Assign only real sources to a destination you choose.\n\nYour exact source → destination preview appears in the workspace before any filesystem action."
        let detailScroll=scroll(inspector);self.detailScroll=detailScroll;detailScroll.isHidden=true
        inspector.backgroundColor=FriendlyUI.surface;inspector.textColor=FriendlyUI.text
        correctButton.title="Refine selected tags…";correctButton.target=self;correctButton.action=#selector(correctTags)
        assignButton.title="Assign selected to draft";assignButton.target=self;assignButton.action=#selector(assignSelected)
        revealButton.title="Reveal source in Finder";revealButton.target=self;revealButton.action=#selector(revealSource)
        previewSourceButton.title="View file / folder…";previewSourceButton.target=self;previewSourceButton.action=#selector(previewSelectedSource)
        for b in [correctButton,assignButton,revealButton,previewSourceButton] {b.bezelStyle = .rounded;b.isEnabled=false}
        destination.target=self;destination.action=#selector(destinationChanged)
        filterLabel.maximumNumberOfLines=2
        bodyButton.title="Show retained content excerpt";bodyButton.target=self;bodyButton.action=#selector(showReading);bodyButton.bezelStyle = .rounded;bodyButton.isEnabled=false
        proposedPath.font=NSFont.systemFont(ofSize:11);proposedPath.textColor = .secondaryLabelColor;proposedPath.maximumNumberOfLines=3;proposedPath.lineBreakMode = .byTruncatingMiddle
        selectionImage.image=NSImage(systemSymbolName:"doc.text.magnifyingglass",accessibilityDescription:nil);selectionImage.imageScaling = .scaleProportionallyDown;selectionImage.contentTintColor=FriendlyUI.violet;selectionImage.heightAnchor.constraint(equalToConstant:100).isActive=true
        selectionSource.font=NSFont.monospacedSystemFont(ofSize:10,weight:.regular);selectionSource.isSelectable=true;selectionSource.maximumNumberOfLines=3;selectionSource.textColor=FriendlyUI.muted;selectionSummary.textColor=FriendlyUI.muted
        classificationSummary.textColor=FriendlyUI.muted;journeyHint.textColor=FriendlyUI.violet
        previewPlacementButton.title="Preview exact destinations…";previewPlacementButton.target=self;previewPlacementButton.action=#selector(previewPlacement);previewPlacementButton.bezelStyle = .rounded
        inlinePreview.autostarts=false;inlinePreview.isHidden=true;inlinePreview.setAccessibilityLabel("Explicit native Quick Look preview in Content inspector")
        inlinePreview.heightAnchor.constraint(equalToConstant:220).isActive=true;inlinePreview.widthAnchor.constraint(equalToConstant:310).isActive=true
        let right=column([journeyHint,inlinePreview,button("Preview here",#selector(previewInInspector)),button("Clear preview",#selector(clearContentPreview)),selectionImage,selectionName,selectionSummary,selectionSource,previewSourceButton,revealButton,button("Details & retained evidence",#selector(toggleContentDetails)),detailScroll,bodyButton,text("CLASSIFICATION",size:10,weight:.semibold),classificationSummary,correctButton]);right.detachesHiddenViews=true
        right.widthAnchor.constraint(equalToConstant:310).isActive=true
        detailScroll.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true;detailScroll.heightAnchor.constraint(equalToConstant:180).isActive=true
        for v in [destination,proposedPath,previewPlacementButton,assignButton] {v.widthAnchor.constraint(equalToConstant:310).isActive=true}
        for v in [places,familyButtons,dimension] {v.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true}
        for v in [journeyHint,classificationSummary,selectionImage,selectionName,selectionSummary,selectionSource] {v.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true}
        assignButton.bezelColor=FriendlyUI.violet;assignButton.controlSize = .large
        let placement=column([text("CHOOSE A DRAFT DESTINATION",size:10,weight:.semibold),destination,proposedPath,previewPlacementButton,assignButton]);placement.widthAnchor.constraint(equalToConstant:310).isActive=true
        let sourceScroll=FriendlyUI.scrollingContent(right);sourceScroll.heightAnchor.constraint(greaterThanOrEqualToConstant:180).isActive=true;sourceScroll.widthAnchor.constraint(equalToConstant:310).isActive=true
        sourceScroll.setContentHuggingPriority(.defaultLow,for:.vertical);placement.setContentHuggingPriority(.required,for:.vertical)
        let rail=column([sourceScroll,placement]);rail.widthAnchor.constraint(equalToConstant:310).isActive=true
        let leftPanel=FriendlyUI.panel(left,tint:FriendlyUI.violet,padding:14),centerPanel=FriendlyUI.panel(center,padding:14),rightPanel=FriendlyUI.panel(rail,padding:14);sourcesPanel=leftPanel;contentCenterPanel=centerPanel;contentInspectorPanel=rightPanel
        rightPanel.widthAnchor.constraint(equalToConstant:338).isActive=true
        let content=row([leftPanel,centerPanel,rightPanel]);contentColumns=content;content.spacing=16;content.alignment = .top;content.detachesHiddenViews=true;content.distribution = .fill
        contentWidth=centerPanel.widthAnchor.constraint(equalTo:content.widthAnchor,constant:-608);contentWidth?.isActive=true
        let outer=column([header,overview,workspaceBar,handoffRow,content,compactSelection]);contentOuter=outer;contentChrome=[header,overview];outer.detachesHiddenViews=true;outer.spacing=14;outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        contentEdges=[outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:16),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-16)];NSLayoutConstraint.activate(contentEdges)
        for v in [header,overview,workspaceBar,handoffRow,content,compactSelection] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        for v in [leftPanel,centerPanel,rightPanel] {v.heightAnchor.constraint(equalTo:content.heightAnchor).isActive=true}
        refreshDestinations();loadPage();loadSummary()
    }
    func refreshDestinations() {
        guard isViewLoaded,let w=workspace?.store.value else{return}
        let selected=workspace?.focusedDestinationID ?? destination.selectedItem?.representedObject as? String
        destination.removeAllItems()
        destination.addItem(withTitle:"Choose a draft destination…")
        for n in w.nodes {if let path=try? w.path(n.id) {destination.addItem(withTitle:path);destination.lastItem?.representedObject=n.id}}
        if let selected=selected,let item=destination.itemArray.first(where:{$0.representedObject as? String==selected}) {destination.select(item)}
        updateSelectionControls()
    }
    func drillInto(_ choices:[CatalogueDimension:String]) {
        guard !choices.isEmpty else{return}
        drillContext=ExplorerDrillContext(folder:folder,filters:filters,query:search.stringValue,visualization:mode.selectedSegment,dimension:dimension.indexOfSelectedItem,metric:metric.indexOfSelectedItem,searchMode:searchMode.indexOfSelectedItem)
        backToMap.title=mode.selectedSegment==2 ? "Back to tag tree":"Back to map";backToMap.isHidden=false
        for (d,v) in choices {filters[d]=v};mode.selectedSegment=0;updateMode();resetPaging();loadPage();loadSummary()
    }
    @objc func restoreDrillContext() {
        guard let c=drillContext else{return};folder=c.folder;filters=c.filters;search.stringValue=c.query;mode.selectedSegment=c.visualization;dimension.selectItem(at:c.dimension);metric.selectItem(at:c.metric);searchMode.selectItem(at:c.searchMode)
        drillContext=nil;backToMap.isHidden=true;updateMode();resetPaging();loadPage();loadSummary();if c.visualization==2 {loadTagTree()}
    }
    func updateFilterChips() {
        filterChips.arrangedSubviews.forEach {filterChips.removeArrangedSubview($0);$0.removeFromSuperview()}
        for d in CatalogueDimension.allCases {if let value=filters[d] {let b=button(d.title+": "+value+"  ×",#selector(removeFilter(_:)));b.tag=CatalogueDimension.allCases.firstIndex(of:d)!;b.controlSize = .small;b.toolTip="Remove only the "+d.title+" filter";b.setAccessibilityLabel(b.toolTip!);filterChips.addArrangedSubview(b)}}
        chipScroll.isHidden=filters.isEmpty;filterChips.frame=NSRect(origin:.zero,size:NSSize(width:filterChips.fittingSize.width,height:28))
    }
    @objc func removeFilter(_ sender:NSButton) {guard sender.tag>=0,sender.tag<CatalogueDimension.allCases.count else{return};filters.removeValue(forKey:CatalogueDimension.allCases[sender.tag]);resetPaging();loadPage();loadSummary();if mode.selectedSegment==2 {loadTagTree()}}
    func showRecordedFolder(_ path:String) {
        _ = view;dataset.selectItem(at:1);changeDataset();folder=path;resetPaging();mode.selectedSegment=0;updateMode();loadPage();loadSummary()
    }
    func slice()->CatalogueSlice {var s=CatalogueSlice();s.folder=folder;s.directChildren=folder != nil && search.stringValue.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty;s.search=search.stringValue;s.contentSearch=searchMode.indexOfSelectedItem==1;s.facets=filters;s.cursor=cursor;return s}
    func resetPaging() {cursor=nil;cursorHistory=[];diskOffset=0;nextCursor=nil;nextDiskOffset=nil}
    @objc func searchChanged() {resetPaging();loadPage();loadSummary()}
    func controlTextDidChange(_ note:Notification) {
        debounce?.cancel();pageCancellation.cancel();generation+=1;pageLoading=true;pageError=nil
        summaryCancellation.cancel();summaryGeneration+=1;summaryLoading=true;summaryError=nil
        nextButton.isEnabled=false;previousButton.isEnabled=false;updateResultState();showMetadata()
        let next=DispatchWorkItem {[weak self] in self?.searchChanged()};debounce=next;DispatchQueue.main.asyncAfter(deadline:.now()+0.3,execute:next)
    }
    @objc func clearFilters() {filters=[:];folder=nil;search.stringValue="";resetPaging();loadPage();loadSummary();if mode.selectedSegment==1 {loadRoots()}}
    @objc func refresh() {allSummary=nil;resetPaging();loadPage();loadSummary();if mode.selectedSegment==1 {physicalTreeState=nil;physicalTreeKey=nil;loadRoots()}}
    @objc func changeDataset() {
        drillContext=nil;backToMap.isHidden=true;handoff=nil;handoffSelected=false;handoffLoading=false;handoffRevision+=1;physicalTreeState=nil;physicalTreeKey=nil;tagTreeState=nil;tagTreeKey=nil
        filters=[:];folder=nil;search.stringValue="";resetPaging();mode.selectedSegment=0;updateMode()
        searchMode.isEnabled=tagged;dimension.isEnabled=tagged;metric.isEnabled=tagged;places.isEnabled=dataset.indexOfSelectedItem != 2;places.item(at:0)?.title=tagged ? "All retained content" : "Recorded roots"
        dimension.removeAllItems();dimension.addItems(withTitles:tagged ? CatalogueDimension.allCases.map(\.title) : ["Protection · global disk counts"])
        if !tagged {metric.selectItem(at:0)}
        for i in [2,4] {mode.setEnabled(tagged,forSegment:i)}
        mode.setEnabled(dataset.indexOfSelectedItem != 2,forSegment:3)
        mode.setEnabled(dataset.indexOfSelectedItem != 2,forSegment:1);mode.setEnabled(dataset.indexOfSelectedItem != 2,forSegment:5)
        loadPage();loadSummary()
    }
    @objc func changePlace() {folder=places.selectedItem?.representedObject as? String;filters=[:];search.stringValue="";resetPaging();loadPage();loadSummary();if mode.selectedSegment==1 {loadRoots()}}
    @objc func changeDimension() {renderSummary()}
    @objc func changeMetric() {renderSummary()}
    @objc func changeVisualization() {updateMode();if mode.selectedSegment==1 {loadRoots()} else if mode.selectedSegment==2 {loadTagTree()} else if mode.selectedSegment>=3 && mode.selectedSegment<=4 {if summary != nil {renderSummary()} else if !summaryLoading {loadSummary()}}}
    func updateMode() {
        if displayedView != mode.selectedSegment {saveContentTree(displayedView)}
        displayedView=mode.selectedSegment;listScroll.isHidden=displayedView != 0;treeScroll.isHidden=displayedView != 1 && displayedView != 2;contentMapViewport.isHidden=displayedView != 3 && displayedView != 4;galleryScroll.isHidden=displayedView != 5
        if displayedView==5 {gallery.rebuild()}
        if displayedView==1,physicalTreeKey != treeContextKey || (tagTreeKey != nil && roots.first?.item==nil) {roots=[];tree.reloadData()}
        if displayedView==2,roots.first?.item != nil {roots=[];tree.reloadData();tagTreeKey=nil}
        updateResultState();syncContentWorkspace()
        bodyButton.isEnabled=false
        metadataTicket+=1;updateSelectionControls();showMetadata();workspace?.pageHost?.updateNavigation()
        if displayedView==1 {status.stringValue="Physical hierarchy · retained observations · facets apply to lists and maps."}
        if displayedView==2 {status.stringValue="Owner → project → family · double-click a tag group to list its real sources."}
        if displayedView==4 {status.stringValue="Top 12 groups per axis · edges count matching observations · complete categories remain in the facet list."}
    }
    @objc func selectFacet() {let row=facetTable.selectedRow;guard row>=0,row<facets.count else{return};guard tagged else {status.stringValue="These are whole-disk boundary totals. Browse their physical folders in Folder tree; semantic intersections are available in Tagged catalogue.";return};filters[activeDimension]=facets[row].value;mode.selectedSegment=0;updateMode();resetPaging();loadPage();loadSummary()}
    func loadPage(preserving paths:Set<String>=[]) {
        guard let reader=workspace?.catalog else{return}
        pageLoading=true;pageError=nil
        if let h=handoff,(h.scope != folder || !filters.isEmpty || !search.stringValue.isEmpty) {handoffRevision+=1;handoff=nil;handoffSelected=false;handoffLoading=false}
        gallery.invalidatePage()
        if let item=places.itemArray.first(where:{($0.representedObject as? String)==self.folder}) {places.select(item)}
        else {if places.numberOfItems>7 {places.removeItem(at:7)};if let folder=self.folder {places.addItem(withTitle:URL(fileURLWithPath:folder).lastPathComponent);places.lastItem?.representedObject=folder;places.selectItem(at:7)} else {places.selectItem(at:0)}}
        pageCancellation.cancel();pageCancellation=CatalogueCancellation();let cancellation=pageCancellation
        generation+=1;let serial=generation,s=slice(),source=dataset.indexOfSelectedItem,diskReader=disk,start=diskOffset
        let folder=folder,query=search.stringValue
        var descriptions:[String]=[]
        for d in CatalogueDimension.allCases {if let value=filters[d] {descriptions.append(d.title+" = "+value)}}
        filterLabel.stringValue=descriptions.isEmpty ? "All observations · no semantic filters" : descriptions.joined(separator:" · ");filterLabel.toolTip=filterLabel.stringValue
        updateFilterChips();workspace?.pageHost?.updateNavigation()
        location.stringValue=folder ?? (source==0 ? "All tagged roots" : source==1 ? "Recorded disk roots" : "Recorded access and traversal exceptions")
        status.stringValue="Loading one bounded page…"
        nextButton.isEnabled=false;previousButton.isEnabled=false;updateResultState();showMetadata()
        browsing.async {[weak self] in
            let result:Result<([CatalogItem],String?,Int?,String),Error>=Result {
                if source==0 {let page=try reader.cataloguePage(s,cancellation:cancellation);return (page.items,page.next,nil,"Retained tagged observations · protected records stay held")}
                if source==2 {let rows=try diskReader.exceptions(offset:start);return (rows,nil,rows.count==200 ? start+200 : nil,"Coverage exceptions · no missing body is claimed as read")}
                if let folder=folder {let page=try diskReader.folder(folder,offset:start,search:query);return (page.items,nil,page.next,"Metadata only · \(page.total) recorded direct children · source bodies unopened")}
                return (try diskReader.roots(),nil,nil,"Choose a root or expand the Folder tree to browse the complete disk ledger")
            }
            DispatchQueue.main.async {guard let self=self,self.generation==serial else{return}
                switch result {
                case .success(let page):self.table.deselectAll(nil);self.records=page.0;self.nextCursor=page.1;self.nextDiskOffset=page.2;self.table.reloadData();self.status.stringValue="\(page.0.count) entries on this page · "+(source==0 && s.directChildren ? "direct folder children · " : "")+page.3
                    let indexes=IndexSet(self.records.indices.filter {paths.contains(self.records[$0].path)})
                    self.table.selectRowIndexes(indexes,byExtendingSelection:false)
                    if !indexes.isEmpty {self.table.scrollRowToVisible(indexes.first!)}
                    let removed=paths.count-indexes.count
                    if removed>0 {self.status.stringValue+=" · \(removed) previously selected sources no longer match this page; clear filters to find them."}
                case .failure(let error):self.records=[];self.nextCursor=nil;self.nextDiskOffset=nil;self.table.reloadData();self.pageError=error.localizedDescription;self.status.stringValue=error.localizedDescription
                }
                self.pageLoading=false;self.updateResultState();self.gallery.rebuild();self.showMetadata();self.nextButton.isEnabled=self.nextCursor != nil || self.nextDiskOffset != nil;self.previousButton.isEnabled = !self.cursorHistory.isEmpty || self.diskOffset>0
            }
        }
    }
    func loadSummary() {
        guard let reader=workspace?.catalog,let cache=workspace?.store.directory else{return}
        summaryLoading=true;summaryError=nil;summary=nil;facets=[];facetTable.reloadData();familyButtons.arrangedSubviews.forEach {familyButtons.removeArrangedSubview($0);$0.removeFromSuperview()};map.configure(CatalogueSummary(partitions:[]),dimension:activeDimension,connections:false,byBytes:false)
        summaryCancellation.cancel();summaryCancellation=CatalogueCancellation();let cancellation=summaryCancellation
        summaryGeneration+=1;let serial=summaryGeneration,s=slice(),diskReader=disk,source=dataset.indexOfSelectedItem,existing=allSummary
        overview.stringValue="Preparing retained aggregate counts in the background. Browsing and draft editing remain available.";updateResultState()
        aggregating.async {[weak self] in
            let diskResult=try? diskReader.overview()
            let result:Result<(CatalogueSummary,CatalogueSummary?),Error>=Result {
                if source != 0 {return (CatalogueSummary(partitions:[]),existing)}
                if s.search.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty,s.folder==nil {let all=try existing ?? reader.cachedSummary(in:cache,cancellation:cancellation);return (all.sliced(s.facets),all)}
                return (try reader.summary(s,cancellation:cancellation),existing)
            }
            DispatchQueue.main.async {guard let self=self,self.summaryGeneration==serial else{return}
                self.summaryLoading=false
                self.diskOverview=diskResult
                switch result {
                case .success(let value):self.summary=value.0;self.allSummary=value.1;self.renderSummary()
                case .failure(let error):self.summaryError=error.localizedDescription;self.overview.stringValue=error.localizedDescription
                };self.updateResultState()
            }
        }
    }
    func number(_ n:Int64)->String {NumberFormatter.localizedString(from:NSNumber(value:n),number:.decimal)}
    func renderSummary() {
        guard let summary=summary else{return}
        familyButtons.arrangedSubviews.forEach {familyButtons.removeArrangedSubview($0);$0.removeFromSuperview()}
        if tagged {for facet in summary.groups(.family).prefix(6) {let b=button(facet.value+"   "+number(facet.count),#selector(selectContentFamily(_:)));b.identifier=NSUserInterfaceItemIdentifier(facet.value);b.font=NSFont.systemFont(ofSize:11);familyButtons.addArrangedSubview(b)}}
        if tagged {
            facets=summary.groups(activeDimension);facetTable.reloadData()
            var text=number(summary.count)+" matching tagged observations · "+number(summary.readings)+" full/partial readings · "+ByteCountFormatter.string(fromByteCount:summary.bytes,countStyle:.file)+" logical file bytes"
            if let disk=diskOverview {text+="\nWhole-disk ledger: "+number(disk.count)+" metadata entries · "+number(disk.exceptions)+" exceptions · "+friendlyObservationDate(disk.updated)+" · retained scopes overlap; verify current sources before copying."}
            overview.stringValue=text
            let useBytes=metric.indexOfSelectedItem==1 && summary.bytes>0
            map.configure(summary,dimension:activeDimension,connections:mode.selectedSegment==4,byBytes:useBytes)
            if mode.selectedSegment==3 {status.stringValue="Complete matching aggregates · "+number(summary.count)+" entries · click a group to list its real sources. Other categories remain in the facet list."}
            if mode.selectedSegment==4 {status.stringValue="Top 12 groups per axis · edges count matching observations · complete categories remain in the facet list."}
            if mode.selectedSegment==2 {loadTagTree()}
        } else if let disk=diskOverview {
            facets=disk.boundaries.map {CatalogueFacet(value:$0.key,count:$0.value)}.sorted {$0.count>$1.count};facetTable.reloadData()
            overview.stringValue=number(disk.count)+" disk metadata observations · "+number(disk.exceptions)+" exceptions · "+disk.status+"\n"+disk.updated+" · overlaps the tagged catalogue · bodies not read · no global byte total is inferred from directory counts."
            map.configureDisk(disk.boundaries)
            if mode.selectedSegment==3 {status.stringValue="Complete disk boundary totals · counts overlap the tagged catalogue. Use Folder tree to inspect recorded physical sources."}
        } else {overview.stringValue="The optional disk ledger is unavailable. The tagged catalogue remains separately accessible."}
    }
    func loadRoots() {
        guard let reader=workspace?.catalog else{return};let source=dataset.indexOfSelectedItem,diskReader=disk,rootFolder=folder
        let key=treeContextKey
        if let cached=physicalTreeState,cached.key==key {physicalTreeKey=key;treeLoading=false;tree.isEnabled=true;restoreContentTree(cached);showMetadata();return}
        physicalTreeKey=nil
        treeGeneration+=1;let serial=treeGeneration;treeLoading=true;treeError=nil;tree.isEnabled=false;tree.deselectAll(nil);showMetadata()
        browsing.async {[weak self] in
            let result:Result<[CatalogItem],Error>=Result {
                if let path=rootFolder {
                    if source==0,let item=try reader.observation(at:path) {return [item]}
                    var item=CatalogItem(id:0,path:path,name:URL(fileURLWithPath:path).lastPathComponent,kind:"directory",bytes:0,context:"Selected recorded folder")
                    item.origin=source==0 ? "Atlas tagged catalogue" : "Whole-disk metadata";return [reader.knowledge?.snapshot().applying(to:item) ?? item]
                }
                if source==0 {return try reader.catalogueRoots()};return try diskReader.roots()
            }
            DispatchQueue.main.async {guard let self=self,self.treeGeneration==serial else{return};self.treeLoading=false;self.tree.isEnabled=true;guard self.mode.selectedSegment==1,self.dataset.indexOfSelectedItem==source,self.folder==rootFolder else{return};switch result {case .success(let items):self.roots=items.map(ExplorerNode.init);self.physicalTreeKey=key;self.tree.reloadData();self.saveContentTree(1);case .failure(let error):self.treeError=error.localizedDescription;self.status.stringValue=error.localizedDescription};self.showMetadata()}
        }
    }
    func loadTagTree() {
        guard let summary=summary else{return}
        let key=String(summaryGeneration)
        if displayedView==2,tagTreeKey==key {return}
        if let cached=tagTreeState,cached.key==key {tagTreeKey=key;restoreContentTree(cached);return}
        tagTreeKey=key
        roots=summary.groups(.owner).map {ExplorerNode(title:$0.value+" · "+number($0.count),choices:[.owner:$0.value],level:0)};tree.reloadData()
    }
    func outlineView(_ outline:NSOutlineView,numberOfChildrenOfItem item:Any?)->Int {(item as? ExplorerNode)?.children?.count ?? (item==nil ? roots.count : 0)}
    func outlineView(_ outline:NSOutlineView,child index:Int,ofItem item:Any?)->Any {if let node=item as? ExplorerNode {return node.children![index]};return roots[index]}
    func outlineView(_ outline:NSOutlineView,isItemExpandable item:Any)->Bool {guard let node=item as? ExplorerNode,!node.more else{return false};return node.item?.kind=="directory" || (node.item==nil && node.level<2)}
    func outlineView(_ outline:NSOutlineView,shouldExpandItem item:Any)->Bool {
        guard let node=item as? ExplorerNode else{return false}
        if node.children != nil {return true}
        if mode.selectedSegment==2,let summary=summary {
            let d:CatalogueDimension=node.level==0 ? .project : .family
            node.children=summary.sliced(node.choices).groups(d).map {g in var choices=node.choices;choices[d]=g.value;return ExplorerNode(title:g.value+" · "+number(g.count),choices:choices,level:node.level+1)}
            return true
        }
        loadChildren(node);return false
    }
    func loadChildren(_ node:ExplorerNode) {
        guard let item=node.item,let reader=workspace?.catalog else{return}
        let source=dataset.indexOfSelectedItem,diskReader=disk,next=node.nextCursor,start=node.diskOffset,context=treeContextKey
        status.stringValue="Loading recorded children; no live traversal…"
        browsing.async {[weak self,weak node] in
            let result:Result<([CatalogItem],String?,Int?),Error>=Result {
                if source==0 {var s=CatalogueSlice();s.folder=item.path;s.directChildren=true;s.cursor=next;let page=try reader.cataloguePage(s);return (page.items,page.next,nil)}
                let page=try diskReader.folder(item.path,offset:start);return (page.items,nil,page.next)
            }
            DispatchQueue.main.async {guard let self=self,let node=node,self.mode.selectedSegment==1,self.dataset.indexOfSelectedItem==source,self.treeContextKey==context else{return};switch result {
                case .success(let page):node.children=page.0.map(ExplorerNode.init);node.nextCursor=page.1;node.diskOffset=page.2 ?? 0
                    if page.1 != nil || page.2 != nil {let more=ExplorerNode(title:"Next 200 observed children…",choices:[:],level:0);more.more=true;more.parent=node;node.children?.append(more)}
                    self.tree.reloadItem(node,reloadChildren:true);self.tree.expandItem(node);self.status.stringValue="Recorded hierarchy · folders stay coherent · next-page nodes are navigation only."
                case .failure(let error):node.children=[];self.tree.reloadItem(node,reloadChildren:true);self.status.stringValue=error.localizedDescription
            }}
        }
    }
    func outlineView(_ outline:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any)->NSView? {
        guard let node=item as? ExplorerNode else{return nil};let label=text(node.title,size:12,weight:node.more ? .medium : .regular);label.toolTip=node.item?.path;return label
    }
    func outlineViewSelectionDidChange(_ note:Notification) {
        if !tree.selectedRowIndexes.isEmpty {handoffSelected=false}
        let stamp=workspace?.knowledge.snapshot().tagStamp
        if displayedView==1,!treeLoading,tree.selectedRowIndexes.contains(where:{(tree.item(atRow:$0) as? ExplorerNode)?.tagStamp != stamp}) {reloadSelectedTreeKnowledge()}
        else {showMetadata()}
    }
    func reloadSelectedTreeKnowledge() {
        guard let w=workspace,!treeLoading else{return}
        let nodes=tree.selectedRowIndexes.prefix(200).compactMap {tree.item(atRow:$0) as? ExplorerNode}.filter {$0.item != nil}
        guard !nodes.isEmpty else {showMetadata();return}
        let snapshot=w.knowledge.snapshot(),reader=w.catalog,source=dataset.indexOfSelectedItem
        treeGeneration+=1;let serial=treeGeneration;treeLoading=true;tree.isEnabled=false;showMetadata()
        browsing.async {[weak self] in
            let refreshed=nodes.map {node -> CatalogItem? in
                guard var item=node.item else{return nil}
                if source==0,item.id>0 {return try? reader.observation(at:item.path)}
                if source==1 {item.tags=MetadataLabels.tags(path:item.path,kind:item.kind,inherited:item.barrier)}
                else {for key in Knowledge.fields {item.tags.removeValue(forKey:key)}}
                item.manual=false;item.evidence.removeAll {$0.hasPrefix("Human tag correction for this exact path · ")}
                item.context=[item.tags["owner"],item.tags["project"],item.tags["family"]].compactMap {$0}.filter {!$0.isEmpty}.joined(separator:" / ")
                return snapshot.applying(to:item)
            }
            DispatchQueue.main.async {guard let self=self,self.treeGeneration==serial else{return};self.treeLoading=false;self.tree.isEnabled=true
                guard self.workspace?.knowledge.snapshot().tagStamp==snapshot.tagStamp else {self.reloadSelectedTreeKnowledge();return}
                for (node,item) in zip(nodes,refreshed) {if let item=item {node.item=item;node.tagStamp=snapshot.tagStamp}}
                self.showMetadata()
            }
        }
    }
    func outlineView(_ outline:NSOutlineView,pasteboardWriterForItem item:Any)->NSPasteboardWriting? {guard !selectionPending,let record=(item as? ExplorerNode)?.item else{return nil};return URL(fileURLWithPath:record.path) as NSURL}
    func selectedRecords()->[CatalogItem] {
        guard !selectionPending else{return []}
        if [0,1,5].contains(displayedView),handoffSelected,let item=handoff?.item {return [item]}
        if displayedView==0 || displayedView==5 {return table.selectedRowIndexes.compactMap {$0<records.count ? records[$0] : nil}}
        if displayedView==1 {return tree.selectedRowIndexes.compactMap {(tree.item(atRow:$0) as? ExplorerNode)?.item}}
        return []
    }
    @objc func openTreeSelection() {
        guard !selectionPending else{return}
        guard let node=tree.item(atRow:tree.clickedRow) as? ExplorerNode else{return}
        if node.more,let parent=node.parent {tree.collapseItem(parent);loadChildren(parent);return}
        if mode.selectedSegment==2 {drillInto(node.choices);return}
        if let item=node.item {open(item)}
    }
    @objc func openObservation() {let row=table.clickedRow;guard !selectionPending,row>=0,row<records.count else{return};open(records[row])}
    func open(_ item:CatalogItem) {guard !selectionPending else{return};if item.kind=="directory" {folder=item.path;mode.selectedSegment=0;updateMode();search.stringValue="";resetPaging();loadPage();loadSummary()} else {showMetadata()}}
    @objc func parentFolder() {guard let path=folder else{return};folder=path=="/" ? nil : URL(fileURLWithPath:path).deletingLastPathComponent().path;resetPaging();loadPage();loadSummary()}
    @objc func nextPage() {if tagged,let next=nextCursor {cursorHistory.append(cursor);cursor=next} else if let next=nextDiskOffset {diskOffset=next} else {return};loadPage()}
    @objc func previousPage() {if tagged {guard !cursorHistory.isEmpty else{return};cursor=cursorHistory.removeLast()} else {diskOffset=max(0,diskOffset-200)};loadPage()}
    func numberOfRows(in tableView:NSTableView)->Int {tableView===facetTable ? facets.count : records.count}
    func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView? {
        if tableView===facetTable {let facet=facets[row];return text(column?.identifier.rawValue=="count" ? number(facet.count) : facet.value,size:11)}
        let record=records[row],id=column?.identifier.rawValue ?? "name"
        let title:String,sub:String
        if id=="size" {title=record.kind=="file" ? ByteCountFormatter.string(fromByteCount:record.bytes,countStyle:.file) : record.kind;sub=""}
        else if id=="tags" {title=record.context;sub=record.state+" · "+(record.barrier.isEmpty ? "user_data" : record.barrier)}
        else {title=(record.kind=="directory" ? "▸ " : "")+record.name;sub=record.path}
        let cell=NSTableCellView(),a=text(title,size:12,weight:.medium),b=text(sub,size:10);b.textColor = .secondaryLabelColor
        let stack=self.column([a,b]);stack.spacing=3;stack.translatesAutoresizingMaskIntoConstraints=false;cell.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:cell.leadingAnchor,constant:5),stack.trailingAnchor.constraint(equalTo:cell.trailingAnchor,constant:-4),stack.centerYAnchor.constraint(equalTo:cell.centerYAnchor)])
        cell.textField=a;cell.toolTip=sub;return cell
    }
    func tableViewSelectionDidChange(_ note:Notification) {if let selected=note.object as? NSTableView,selected === table {if !table.selectedRowIndexes.isEmpty {handoffSelected=false};showMetadata()}}
    func tableView(_ tableView:NSTableView,pasteboardWriterForRow row:Int)->NSPasteboardWriting? {guard tableView===table,!selectionPending,row>=0,row<records.count else{return nil};return URL(fileURLWithPath:records[row].path) as NSURL}
    @objc func destinationChanged() {workspace?.focusedDestinationID=destination.selectedItem?.representedObject as? String;updateSelectionControls();workspace?.pageHost?.updateNavigation()}
    func updateSelectionControls() {
        let selected=selectedRecords()
        correctButton.isEnabled = !selected.isEmpty && selected.count<=200 && selected.allSatisfy {$0.kind=="file" || $0.kind=="directory"} && workspace?.busy != true
        revealButton.isEnabled = !selected.isEmpty
        previewSourceButton.isEnabled=selected.count==1 && selected.allSatisfy {$0.kind=="file" || $0.kind=="directory"}
        assignButton.isEnabled = !selected.isEmpty && selected.allSatisfy {$0.kind=="file" || $0.kind=="directory"} && destination.selectedItem?.representedObject != nil && workspace?.busy != true
        previewPlacementButton.isEnabled=assignButton.isEnabled
        assignButton.title=selected.isEmpty ? "Add selection to Review":"Add \(selected.count) to Review"
        journeyHint.stringValue=selectionPending ? "Updating results · actions resume when ready" : selected.isEmpty ? "Inspect → refine tags → choose a destination → review" : destination.selectedItem?.representedObject==nil ? "Inspect the material, refine tags, then choose its destination." : "Preview the exact paths, then add your choices to Review."
        if let item=selected.first,let w=workspace?.store.value,let id=destination.selectedItem?.representedObject as? String {
            var proposed=w.assignments.first {$0.source==item.path} ?? Assignment(source:item.path,node:id,outputName:item.name);proposed.node=id
            let to=(try? w.destination(proposed)) ?? "Invalid draft destination"
            proposedPath.stringValue="Proposed copy → "+to+(selected.count>1 ? "\nPlus \(selected.count-1) other selected sources.":"");proposedPath.toolTip=item.path+"\n→ "+to
            if let proposal=try? PlacementPreview.make(selected,node:id,workspace:w),proposal.exceedsCapacity {assignButton.isEnabled=false;proposedPath.stringValue+="\nThis selection exceeds the 100-assignment draft limit. Select fewer sources; exact paths remain available."}
        } else {proposedPath.stringValue=selected.isEmpty ? "Select real sources in List, Gallery or Folder tree to preview placement.":"Choose a destination to preview placement.";proposedPath.toolTip=nil}
        workspace?.pageHost?.updateNavigation()
    }
    func showMetadata() {
        metadataDebounce?.cancel()
        updateSelectionControls();updateResultState()
        let current=selectedRecords().first
        if inlinePreviewPath != current?.path {clearInlinePreview()}
        syncContentWorkspace()
        selectionName.stringValue=current?.name ?? "Choose a file or folder";selectionSource.stringValue=current?.path ?? ""
        selectionSummary.stringValue=current.map {($0.kind=="directory" ? "Folder":ByteCountFormatter.string(fromByteCount:$0.bytes,countStyle:.file))+" · "+$0.state+"\n"+$0.tags.sorted {$0.key<$1.key}.filter {["owner","project","family"].contains($0.key)}.map {$0.value}.joined(separator:" · ")} ?? "Select to inspect evidence. Thumbnails are an explicit content request."
        classificationSummary.stringValue=current.map {item in (item.manual ? "Your reviewed tags":"Retained tags · refine any value")+"\n"+Knowledge.fields.map {$0.capitalized+": "+((item.tags[$0]?.isEmpty==false) ? item.tags[$0]! : "Unassigned")}.joined(separator:"\n") } ?? "Select material to see its classification."
        if selectedRecords().count>1 {selectionName.stringValue="\(selectedRecords().count) sources selected";selectionSummary.stringValue="Showing evidence for the first source. Tag edits apply to every selected exact path."}
        gallery.syncSelection()
        let selected=selectedRecords();guard let item=selected.first else {bodyButton.isEnabled=false;metadataTicket+=1;inspector.string="Select a real file or folder to inspect its tags, provenance, reading limits and current metadata.\n\nDouble-click a tag group or click a map region to list its real sources. Virtual groups are filters.\n\nChoose a destination explicitly, then assign sources to the draft. Exact previews and full verification happen in the workspace; originals remain in place.";return}
        var lines:[String]=["RETAINED OBSERVATION",item.name,item.path,"","Origin: "+item.origin,"Kind: "+item.kind,"Reading: "+item.state,"Boundary: "+(item.barrier.isEmpty ? "user_data" : item.barrier),"Recorded logical bytes: "+String(item.bytes)]
        if item.manual {lines.append("Classification: human reviewed")}
        if let confidence=item.confidence {lines.append("Retained confidence: "+String(format:"%.0f%%",confidence*100)+" · original evidence preserved")}
        if item.modified>0 {let date=Date(timeIntervalSince1970:Double(item.modified)/1_000_000_000);let format=ISO8601DateFormatter();lines.append("Modified (UTC; not event date): "+format.string(from:date))}
        lines += ["","TAGS"]
        for key in item.tags.keys.sorted() {lines.append(key+": "+(item.tags[key] ?? ""))}
        if !item.visualLabels.isEmpty {lines += ["","BROAD VISUAL LABELS · inferred, may overlap"]+item.visualLabels}
        lines += ["","EVIDENCE"]+item.evidence
        if !item.reason.isEmpty {lines += ["","READING EXCEPTION",item.reason]}
        if selected.count>1 {lines += ["","\(selected.count) real sources selected. Whole folders preserve their hierarchy."]}
        lines += ["","This retained observation may predate changes. An exact copy preview rechecks current identities and every byte hash before any destination is created."]
        if let w=workspace?.store.value {for a in w.assignments where selected.contains(where:{$0.path==a.source}) {lines += ["","DRAFT SOURCE · retained",a.source,"CHOSEN DESTINATION · proposed copy",(try? w.destination(a)) ?? "Invalid destination"]}}
        inspector.string=lines.joined(separator:"\n")
        bodyButton.isEnabled=item.id>0 && ["extracted","partial"].contains(item.state) && !["credentials","audit"].contains(item.barrier) && !SafeFS.guardedName(item.name)
        metadataTicket+=1;let ticket=metadataTicket
        let request=DispatchWorkItem {[weak self] in
            guard let self=self,self.metadataTicket==ticket else{return}
        self.browsing.async {[weak self] in
            let current:String
            do {
                let parent=URL(fileURLWithPath:item.path).deletingLastPathComponent().path
                let fd=try SafeFS.openDirectory(parent);defer {close(fd)}
                let s=try SafeFS.info(fd,URL(fileURLWithPath:item.path).lastPathComponent)
                if !SafeFS.isFile(s) && !SafeFS.isDirectory(s) {current="Held: linked or special source; no traversal."}
                else if item.modified>0 {
                    let time=Int64(s.st_mtimespec.tv_sec)*1_000_000_000+Int64(s.st_mtimespec.tv_nsec)
                    current=s.st_size==item.bytes && time==item.modified ? "Matches recorded size/time. Full byte identity is still unchecked." : "Changed since ingestion. Tags and excerpts describe the retained observation; review before assigning."
                } else {current="Current metadata is available. This root has no recorded byte identity."}
            } catch {current="Unavailable or held now: "+error.localizedDescription}
            DispatchQueue.main.async {guard let self=self,self.metadataTicket==ticket,self.selectedRecords().first?.path==item.path else{return};self.inspector.string+="\n\nCURRENT METADATA CHECK · no file body read\n"+current}
        }
        }
        metadataDebounce=request;DispatchQueue.main.asyncAfter(deadline:.now()+0.12,execute:request)
    }
    @objc func showReading() {
        detailScroll?.isHidden=false
        guard let item=selectedRecords().first,let reader=workspace?.catalog else{return};metadataTicket+=1;let ticket=metadataTicket;bodyButton.isEnabled=false;status.stringValue="Reading a bounded retained excerpt; original file unopened…"
        browsing.async {[weak self] in let result:Result<String,Error>=Result {try reader.storedReading(item)}
            DispatchQueue.main.async {guard let self=self,self.metadataTicket==ticket,self.selectedRecords().first?.path==item.path else{return};switch result {case .success(let text):self.inspector.string="RETAINED CONTENT · "+item.state+"\n"+item.path+"\n\n"+text;self.status.stringValue="Stored excerpt only; partial reading and inference limits remain applicable.";case .failure(let error):self.status.stringValue=error.localizedDescription}}
        }
    }
    @objc func toggleContentDetails() {detailScroll?.isHidden.toggle()}
    @objc func selectContentFamily(_ sender:NSButton) {guard let name=sender.identifier?.rawValue else{return};filters[.family]=name;resetPaging();loadPage();loadSummary()}
    @objc func loadGalleryThumbnails() {guard dataset.indexOfSelectedItem != 2 else {status.stringValue="Choose Content & tags or Recorded disk for file thumbnails.";return};mode.selectedSegment=5;updateMode();gallery.loadThumbnails()}
    @objc func clearGalleryImages() {gallery.clear();status.stringValue="Content images released. Your catalogue and draft are unchanged."}
    func updateResultState() {
        guard isViewLoaded else{return}
        let aggregate=[2,3,4].contains(displayedView),physical=displayedView==1
        let pending=aggregate ? summaryLoading:physical ? treeLoading:pageLoading
        let empty=aggregate ? (displayedView==2 ? roots.isEmpty:map.tiles.isEmpty):physical ? roots.isEmpty:records.isEmpty
        let error=aggregate ? summaryError:physical ? treeError:pageError
        resultState.isHidden = !pending && !empty
        table.isEnabled = !pageLoading
        if pending {resultState.title.stringValue="Updating your view…";resultState.detail.stringValue=aggregate ? "Preparing retained aggregates; previous groups stay held until ready.":physical ? "Loading retained hierarchy; source actions resume when ready.":"Loading one bounded page. Previous results cannot be assigned while this view changes.";resultState.spinner.startAnimation(nil);resultState.clear.isHidden=true}
        else {resultState.spinner.stopAnimation(nil);resultState.clear.isHidden=false
            resultState.title.stringValue=error==nil ? "No matches in this view":"This view could not be loaded"
            resultState.detail.stringValue=error ?? "Try a broader search, remove a filter, or choose another source. Your catalogue and draft remain intact."
        }
        resultState.spinner.isHidden = !pending
    }

    @objc func previewPlacement() {
        guard let w=workspace,let node=destination.selectedItem?.representedObject as? String,!w.busy else{return}
        do {
            let p=try PlacementPreview.make(selectedRecords(),node:node,workspace:w.store.value)
            let a=NSAlert();a.messageText="Exact destinations · \(p.pairs.count) sources"
            a.informativeText="Every chosen source and proposed destination is shown below. Folders retain their internal hierarchy. This is a draft calculation; source identities, collisions, capacity and hashes are checked separately in Review."
            let t=KonMagicInspector();t.isEditable=false;t.isSelectable=true;t.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular)
            t.string=p.pairs.map {pair -> String in
                let hierarchy=pair.kind=="directory" ? "\nBucket · every relative path is retained":""
                return pair.source+"\n→ "+pair.destination+hierarchy
            }.joined(separator:"\n\n")
            let sc=scroll(t);sc.frame=NSRect(x:0,y:0,width:720,height:400);t.frame=sc.bounds;t.isVerticallyResizable=true;t.autoresizingMask = [.width];t.textContainer?.widthTracksTextView=true
            a.accessoryView=sc;a.addButton(withTitle:"Keep reviewing");a.runModal()
        } catch {status.stringValue=error.localizedDescription}
    }
    override func viewDidLayout() {super.viewDidLayout();if galleryScroll != nil {gallery.arrange()}}
    @objc func revealSource() {if let item=selectedRecords().first {NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath:item.path)])}}
    @objc func returnToToolkit() {workspace?.showToolkit()}
    @objc func editDestinations() {if let id=destination.selectedItem?.representedObject as? String {workspace?.focusedDestinationID=id};workspace?.showWorkspace()}
    @objc func assignSelected() {
        guard let workspace=workspace,let id=destination.selectedItem?.representedObject as? String else{return}
        guard !workspace.busy else {status.stringValue="Wait for the active verification or copy to finish before changing its draft.";return}
        let paths=selectedRecords().filter {$0.kind=="file" || $0.kind=="directory"}.map(\.path)
        guard !paths.isEmpty else {status.stringValue="Select real files or folders in List or Folder tree. Virtual tag/map groups are filters, not source folders.";return}
        do {try workspace.store.change {try $0.assign(paths,to:id)};workspace.plan=nil;workspace.focusedDestinationID=id;workspace.refreshDraft();showMetadata();status.stringValue="\(paths.count) drops / buckets assigned in the draft. Exact source → destination paths are visible; no filesystem action ran.";workspace.status.stringValue=status.stringValue;workspace.presentAssignments(paths)}
        catch {status.stringValue=error.localizedDescription}
    }
    func show() {
        if window==nil {let w=NSWindow(contentRect:NSRect(x:0,y:0,width:1480,height:900),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false);w.title="KonMagic · Content Explorer";w.minSize=NSSize(width:1230,height:800);w.contentViewController=self;w.isReleasedWhenClosed=false;w.setFrameAutosaveName("KonMagicExplorer");w.center();window=w}
        refreshDestinations();window?.makeKeyAndOrderFront(nil)
    }
}
