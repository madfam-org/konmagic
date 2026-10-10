import AppKit
import Darwin

final class ExplorerNode:NSObject {
    var item:CatalogItem?
    var title:String
    var choices:[CatalogueDimension:String]=[:]
    var children:[ExplorerNode]?
    var level=0
    var nextCursor:String?
    var diskOffset=0
    var more=false
    weak var parent:ExplorerNode?
    init(_ item:CatalogItem) {self.item=item;title=item.name}
    init(title:String,choices:[CatalogueDimension:String],level:Int) {self.title=title;self.choices=choices;self.level=level}
}

final class CatalogueExplorerController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,
    NSOutlineViewDataSource,NSOutlineViewDelegate,NSSearchFieldDelegate {
    weak var workspace:KonMagicController?
    var window:NSWindow?
    let dataset=NSPopUpButton(),dimension=NSPopUpButton(),destination=NSPopUpButton(),search=NSSearchField()
    let searchMode=NSPopUpButton(),metric=NSPopUpButton()
    let mode=NSSegmentedControl(labels:["List","Folder tree","Tag tree","Treemap","Connections"],trackingMode:.selectOne,target:nil,action:nil)
    let overview=NSTextField(wrappingLabelWithString:"Connecting retained Atlas observations…")
    let filterLabel=NSTextField(wrappingLabelWithString:"No filters"),status=NSTextField(labelWithString:""),location=NSTextField(labelWithString:"")
    let facetTable=NSTableView(),table=NSTableView(),tree=NSOutlineView(),inspector=NSTextView(),map=CatalogueMapView()
    let contentHost=NSView(),bodyButton=NSButton(),nextButton=NSButton(),previousButton=NSButton()
    var listScroll:NSScrollView!,treeScroll:NSScrollView!
    var records:[CatalogItem]=[],roots:[ExplorerNode]=[],facets:[CatalogueFacet]=[]
    var filters:[CatalogueDimension:String]=[:],folder:String?,cursor:String?,cursorHistory:[String?]=[]
    var diskOffset=0,nextCursor:String?,nextDiskOffset:Int?
    var summary:CatalogueSummary?,allSummary:CatalogueSummary?,diskOverview:DiskOverview?
    var generation=0,summaryGeneration=0
    var debounce:DispatchWorkItem?
    var pageCancellation=CatalogueCancellation(),summaryCancellation=CatalogueCancellation()
    let browsing=DispatchQueue(label:"org.madfam.konmagic.explorer-pages",qos:.userInitiated)
    let aggregating=DispatchQueue(label:"org.madfam.konmagic.explorer-aggregates",qos:.utility)
    var displayedView=0
    var metadataTicket=0
    var tagged:Bool {dataset.indexOfSelectedItem==0}
    var disk:DiskCatalogue {DiskCatalogue(path:URL(fileURLWithPath:workspace?.catalog.path ?? "").deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path)}
    var activeDimension:CatalogueDimension {CatalogueDimension.allCases[max(0,dimension.indexOfSelectedItem)]}
    init(workspace:KonMagicController) {self.workspace=workspace;super.init(nibName:nil,bundle:nil)}
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
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1480,height:900))
        dataset.addItems(withTitles:["Tagged catalogue","Whole-disk metadata","Coverage exceptions"]);dataset.target=self;dataset.action=#selector(changeDataset)
        dimension.addItems(withTitles:CatalogueDimension.allCases.map(\.title));dimension.target=self;dimension.action=#selector(changeDimension)
        searchMode.addItems(withTitles:["Names, paths & tags","Indexed content"]);searchMode.target=self;searchMode.action=#selector(searchChanged)
        search.placeholderString="Search retained observations";search.delegate=self
        metric.addItems(withTitles:["Entries","Logical file bytes"]);metric.target=self;metric.action=#selector(changeMetric)
        mode.selectedSegment=0;mode.target=self;mode.action=#selector(changeVisualization)
        overview.font=NSFont.systemFont(ofSize:11);overview.textColor = .secondaryLabelColor
        let header=row([text("Atlas Explorer",size:21,weight:.bold),dataset,NSView(),button("Edit destinations",#selector(editDestinations))])
        let query=row([search,searchMode,button("Clear filters",#selector(clearFilters)),button("Refresh",#selector(refresh))])
        search.widthAnchor.constraint(greaterThanOrEqualToConstant:260).isActive=true

        setupTable(facetTable,columns:[("group","Facet",155),("count","Entries",72)]);facetTable.rowHeight=32;facetTable.target=self;facetTable.action=#selector(selectFacet)
        facetTable.setAccessibilityLabel("Complete catalogue facet groups. Selecting a group filters observations.")
        let facetScroll=scroll(facetTable),left=column([text("DICE THE CATALOGUE",size:11,weight:.semibold),dimension,facetScroll])
        left.widthAnchor.constraint(equalToConstant:245).isActive=true
        facetScroll.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true

        setupTable(table,columns:[("name","Files & folders",285),("tags","Tags & reading",230),("size","Size",95)])
        table.allowsMultipleSelection=true;table.target=self;table.doubleAction=#selector(openObservation)
        table.setAccessibilityLabel("Retained observations, including protected and metadata-only records")
        table.setDraggingSourceOperationMask(.copy,forLocal:true)
        listScroll=scroll(table);treeScroll=scroll(tree)
        tree.delegate=self;tree.dataSource=self;tree.headerView=nil;tree.rowHeight=30;tree.allowsMultipleSelection=true
        let treeColumn=NSTableColumn(identifier:NSUserInterfaceItemIdentifier("tree"));treeColumn.width=500;tree.addTableColumn(treeColumn);tree.outlineTableColumn=treeColumn
        tree.target=self;tree.doubleAction=#selector(openTreeSelection);tree.setDraggingSourceOperationMask(.copy,forLocal:true)
        tree.setAccessibilityLabel("Observed folder tree or tag hierarchy. Expand lazily; double-click to list contents. Virtual tag groups cannot be assigned as source folders.")
        for child in [listScroll!,treeScroll!,map] {
            child.translatesAutoresizingMaskIntoConstraints=false;contentHost.addSubview(child)
            NSLayoutConstraint.activate([child.leadingAnchor.constraint(equalTo:contentHost.leadingAnchor),child.trailingAnchor.constraint(equalTo:contentHost.trailingAnchor),child.topAnchor.constraint(equalTo:contentHost.topAnchor),child.bottomAnchor.constraint(equalTo:contentHost.bottomAnchor)])
        }
        treeScroll.isHidden=true;map.isHidden=true
        map.activated={[weak self] choices in guard let self=self,!choices.isEmpty else{return};for (d,v) in choices {self.filters[d]=v};self.mode.selectedSegment=0;self.updateMode();self.resetPaging();self.loadPage();self.loadSummary()}
        nextButton.title="Next 200";nextButton.target=self;nextButton.action=#selector(nextPage);nextButton.bezelStyle = .rounded
        previousButton.title="Previous";previousButton.target=self;previousButton.action=#selector(previousPage);previousButton.bezelStyle = .rounded
        location.font=NSFont.systemFont(ofSize:10);location.textColor = .secondaryLabelColor
        let center=column([row([mode,metric]),filterLabel,row([button("↑ Parent",#selector(parentFolder)),location]),contentHost,row([previousButton,nextButton]),status])
        contentHost.heightAnchor.constraint(greaterThanOrEqualToConstant:410).isActive=true
        for v in [contentHost,filterLabel,status] {v.widthAnchor.constraint(equalTo:center.widthAnchor).isActive=true}
        center.widthAnchor.constraint(greaterThanOrEqualToConstant:570).isActive=true

        inspector.isEditable=false;inspector.isSelectable=true;inspector.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);inspector.textContainerInset=NSSize(width:12,height:12)
        inspector.isVerticallyResizable=true;inspector.autoresizingMask = [.width];inspector.textContainer?.widthTracksTextView=true
        inspector.string="Select a file or whole folder to inspect its tags, evidence, reading status and current metadata.\n\nMaps and virtual tag groups filter observations. Assign only real sources to a destination you choose.\n\nYour exact source → destination preview appears in the workspace before any filesystem action."
        let detailScroll=scroll(inspector)
        bodyButton.title="Show retained content excerpt";bodyButton.target=self;bodyButton.action=#selector(showReading);bodyButton.bezelStyle = .rounded;bodyButton.isEnabled=false
        let right=column([text("CONTENT & METACONTENT",size:11,weight:.semibold),detailScroll,bodyButton,button("Reveal source in Finder",#selector(revealSource)),text("ASSIGN TO YOUR DRAFT",size:11,weight:.semibold),destination,button("Assign selected drops / buckets",#selector(assignSelected)),text("Exact preview appears in the workspace.",size:11)])
        right.widthAnchor.constraint(equalToConstant:340).isActive=true
        detailScroll.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true;detailScroll.heightAnchor.constraint(greaterThanOrEqualToConstant:430).isActive=true
        destination.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true
        let content=row([left,center,right]);content.alignment = .top
        let outer=column([header,overview,query,content]);outer.spacing=14;outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:16),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-16)])
        for v in [header,overview,query,content] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        for v in [left,center,right] {v.heightAnchor.constraint(equalTo:content.heightAnchor).isActive=true}
        center.widthAnchor.constraint(equalTo:content.widthAnchor,constant:-601).isActive=true
        refreshDestinations();loadPage();loadSummary()
    }
    func refreshDestinations() {
        guard isViewLoaded,let w=workspace?.store.value else{return}
        let selected=destination.selectedItem?.representedObject as? String
        destination.removeAllItems()
        destination.addItem(withTitle:"Choose a draft destination…")
        for n in w.nodes {if let path=try? w.path(n.id) {destination.addItem(withTitle:path);destination.lastItem?.representedObject=n.id}}
        if let selected=selected,let item=destination.itemArray.first(where:{$0.representedObject as? String==selected}) {destination.select(item)}
    }
    func slice()->CatalogueSlice {var s=CatalogueSlice();s.folder=folder;s.directChildren=folder != nil && search.stringValue.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty;s.search=search.stringValue;s.contentSearch=searchMode.indexOfSelectedItem==1;s.facets=filters;s.cursor=cursor;return s}
    func resetPaging() {cursor=nil;cursorHistory=[];diskOffset=0;nextCursor=nil;nextDiskOffset=nil}
    @objc func searchChanged() {resetPaging();loadPage();loadSummary()}
    func controlTextDidChange(_ note:Notification) {debounce?.cancel();let next=DispatchWorkItem {[weak self] in self?.searchChanged()};debounce=next;DispatchQueue.main.asyncAfter(deadline:.now()+0.3,execute:next)}
    @objc func clearFilters() {filters=[:];folder=nil;search.stringValue="";resetPaging();loadPage();loadSummary();if mode.selectedSegment==1 {loadRoots()}}
    @objc func refresh() {allSummary=nil;resetPaging();loadPage();loadSummary();if mode.selectedSegment==1 {loadRoots()}}
    @objc func changeDataset() {
        filters=[:];folder=nil;search.stringValue="";resetPaging();mode.selectedSegment=0;updateMode()
        searchMode.isEnabled=tagged;dimension.isEnabled=tagged;metric.isEnabled=tagged
        dimension.removeAllItems();dimension.addItems(withTitles:tagged ? CatalogueDimension.allCases.map(\.title) : ["Protection · global disk counts"])
        if !tagged {metric.selectItem(at:0)}
        for i in [2,4] {mode.setEnabled(tagged,forSegment:i)}
        mode.setEnabled(dataset.indexOfSelectedItem != 2,forSegment:3)
        mode.setEnabled(dataset.indexOfSelectedItem != 2,forSegment:1)
        loadPage();loadSummary()
    }
    @objc func changeDimension() {renderSummary()}
    @objc func changeMetric() {renderSummary()}
    @objc func changeVisualization() {updateMode();if mode.selectedSegment==1 {loadRoots()} else if mode.selectedSegment==2 {loadTagTree()} else if mode.selectedSegment>=3 {loadSummary()}}
    func updateMode() {
        displayedView=mode.selectedSegment;listScroll.isHidden=displayedView != 0;treeScroll.isHidden=displayedView != 1 && displayedView != 2;map.isHidden=displayedView<3
        bodyButton.isEnabled=false
        if displayedView==1 {status.stringValue="Physical hierarchy · retained observations · facets apply to lists and maps."}
        if displayedView==2 {status.stringValue="Owner → project → family · double-click a tag group to list its real sources."}
        if displayedView==4 {status.stringValue="Top 12 groups per axis · edges count matching observations · complete categories remain in the facet list."}
    }
    @objc func selectFacet() {let row=facetTable.selectedRow;guard row>=0,row<facets.count else{return};guard tagged else {status.stringValue="These are whole-disk boundary totals. Browse their physical folders in Folder tree; semantic intersections are available in Tagged catalogue.";return};filters[activeDimension]=facets[row].value;mode.selectedSegment=0;updateMode();resetPaging();loadPage();loadSummary()}
    func loadPage() {
        guard let reader=workspace?.catalog else{return}
        pageCancellation.cancel();pageCancellation=CatalogueCancellation();let cancellation=pageCancellation
        generation+=1;let serial=generation,s=slice(),source=dataset.indexOfSelectedItem,diskReader=disk,start=diskOffset
        let folder=folder,query=search.stringValue
        var descriptions:[String]=[]
        for d in CatalogueDimension.allCases {if let value=filters[d] {descriptions.append(d.title+" = "+value)}}
        filterLabel.stringValue=descriptions.isEmpty ? "All observations · no semantic filters" : descriptions.joined(separator:" · ")
        location.stringValue=folder ?? (source==0 ? "All tagged roots" : source==1 ? "Recorded disk roots" : "Recorded access and traversal exceptions")
        status.stringValue="Loading one bounded page…"
        browsing.async {[weak self] in
            let result:Result<([CatalogItem],String?,Int?,String),Error>=Result {
                if source==0 {let page=try reader.cataloguePage(s,cancellation:cancellation);return (page.items,page.next,nil,"Retained tagged observations · protected records stay held")}
                if source==2 {let rows=try diskReader.exceptions(offset:start);return (rows,nil,rows.count==200 ? start+200 : nil,"Coverage exceptions · no missing body is claimed as read")}
                if let folder=folder {let page=try diskReader.folder(folder,offset:start,search:query);return (page.items,nil,page.next,"Metadata only · \(page.total) recorded direct children · source bodies unopened")}
                return (try diskReader.roots(),nil,nil,"Choose a root or expand the Folder tree to browse the complete disk ledger")
            }
            DispatchQueue.main.async {guard let self=self,self.generation==serial else{return}
                switch result {
                case .success(let page):self.table.deselectAll(nil);self.records=page.0;self.nextCursor=page.1;self.nextDiskOffset=page.2;self.table.reloadData();self.status.stringValue="\(page.0.count) entries on this page · "+page.3
                case .failure(let error):self.records=[];self.nextCursor=nil;self.nextDiskOffset=nil;self.table.reloadData();self.status.stringValue=error.localizedDescription
                }
                self.nextButton.isEnabled=self.nextCursor != nil || self.nextDiskOffset != nil;self.previousButton.isEnabled = !self.cursorHistory.isEmpty || self.diskOffset>0
            }
        }
    }
    func loadSummary() {
        guard let reader=workspace?.catalog,let cache=workspace?.store.directory else{return}
        summaryCancellation.cancel();summaryCancellation=CatalogueCancellation();let cancellation=summaryCancellation
        summaryGeneration+=1;let serial=summaryGeneration,s=slice(),diskReader=disk,source=dataset.indexOfSelectedItem,existing=allSummary
        overview.stringValue="Preparing retained aggregate counts in the background. Browsing and draft editing remain available."
        aggregating.async {[weak self] in
            let diskResult=try? diskReader.overview()
            let result:Result<(CatalogueSummary,CatalogueSummary?),Error>=Result {
                if source != 0 {return (CatalogueSummary(partitions:[]),existing)}
                if s.search.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty,s.folder==nil {let all=try existing ?? reader.cachedSummary(in:cache,cancellation:cancellation);return (all.sliced(s.facets),all)}
                return (try reader.summary(s,cancellation:cancellation),existing)
            }
            DispatchQueue.main.async {guard let self=self,self.summaryGeneration==serial else{return}
                self.diskOverview=diskResult
                switch result {
                case .success(let value):self.summary=value.0;self.allSummary=value.1;self.renderSummary()
                case .failure(let error):self.overview.stringValue=error.localizedDescription
                }
            }
        }
    }
    func number(_ n:Int64)->String {NumberFormatter.localizedString(from:NSNumber(value:n),number:.decimal)}
    func renderSummary() {
        guard let summary=summary else{return}
        if tagged {
            facets=summary.groups(activeDimension);facetTable.reloadData()
            var text=number(summary.count)+" matching tagged observations · "+number(summary.readings)+" full/partial readings · "+ByteCountFormatter.string(fromByteCount:summary.bytes,countStyle:.file)+" logical file bytes"
            if let disk=diskOverview {text+="\nWhole-disk ledger: "+number(disk.count)+" metadata entries · "+number(disk.exceptions)+" exceptions · "+disk.updated+". Counts overlap; these are retained observations, not current verified files or reclaimable space."}
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
        guard let reader=workspace?.catalog else{return};let source=dataset.indexOfSelectedItem,diskReader=disk
        browsing.async {[weak self] in
            let result:Result<[CatalogItem],Error>=Result {if source==0 {return try reader.catalogueRoots()};return try diskReader.roots()}
            DispatchQueue.main.async {guard let self=self,self.mode.selectedSegment==1,self.dataset.indexOfSelectedItem==source else{return};switch result {case .success(let items):self.roots=items.map(ExplorerNode.init);self.tree.reloadData();case .failure(let error):self.status.stringValue=error.localizedDescription}}
        }
    }
    func loadTagTree() {
        guard let summary=summary else{return}
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
        let source=dataset.indexOfSelectedItem,diskReader=disk,next=node.nextCursor,start=node.diskOffset
        status.stringValue="Loading recorded children; no live traversal…"
        browsing.async {[weak self,weak node] in
            let result:Result<([CatalogItem],String?,Int?),Error>=Result {
                if source==0 {var s=CatalogueSlice();s.folder=item.path;s.directChildren=true;s.cursor=next;let page=try reader.cataloguePage(s);return (page.items,page.next,nil)}
                let page=try diskReader.folder(item.path,offset:start);return (page.items,nil,page.next)
            }
            DispatchQueue.main.async {guard let self=self,let node=node,self.mode.selectedSegment==1,self.dataset.indexOfSelectedItem==source else{return};switch result {
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
    func outlineViewSelectionDidChange(_ note:Notification) {showMetadata()}
    func outlineView(_ outline:NSOutlineView,pasteboardWriterForItem item:Any)->NSPasteboardWriting? {guard let record=(item as? ExplorerNode)?.item else{return nil};return URL(fileURLWithPath:record.path) as NSURL}
    func selectedRecords()->[CatalogItem] {
        if displayedView==0 {return table.selectedRowIndexes.compactMap {$0<records.count ? records[$0] : nil}}
        if displayedView==1 {return tree.selectedRowIndexes.compactMap {(tree.item(atRow:$0) as? ExplorerNode)?.item}}
        return []
    }
    @objc func openTreeSelection() {
        guard let node=tree.item(atRow:tree.clickedRow) as? ExplorerNode else{return}
        if node.more,let parent=node.parent {tree.collapseItem(parent);loadChildren(parent);return}
        if mode.selectedSegment==2 {for (d,v) in node.choices {filters[d]=v};folder=nil;mode.selectedSegment=0;updateMode();resetPaging();loadPage();loadSummary();return}
        if let item=node.item {open(item)}
    }
    @objc func openObservation() {let row=table.clickedRow;guard row>=0,row<records.count else{return};open(records[row])}
    func open(_ item:CatalogItem) {if item.kind=="directory" {folder=item.path;mode.selectedSegment=0;updateMode();search.stringValue="";resetPaging();loadPage();loadSummary()} else {showMetadata()}}
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
    func tableViewSelectionDidChange(_ note:Notification) {if let selected=note.object as? NSTableView,selected === table {showMetadata()}}
    func tableView(_ tableView:NSTableView,pasteboardWriterForRow row:Int)->NSPasteboardWriting? {guard tableView===table else{return nil};return URL(fileURLWithPath:records[row].path) as NSURL}
    func showMetadata() {
        let selected=selectedRecords();guard let item=selected.first else {bodyButton.isEnabled=false;metadataTicket+=1;inspector.string="Select a real file or folder to inspect its tags, provenance, reading limits and current metadata.\n\nDouble-click a tag group or click a map region to list its real sources. Virtual groups are filters.\n\nChoose a destination explicitly, then assign sources to the draft. Exact previews and full verification happen in the workspace; originals remain in place.";return}
        var lines:[String]=["RETAINED OBSERVATION",item.name,item.path,"","Origin: "+item.origin,"Kind: "+item.kind,"Reading: "+item.state,"Boundary: "+(item.barrier.isEmpty ? "user_data" : item.barrier),"Recorded logical bytes: "+String(item.bytes)]
        if let confidence=item.confidence {lines.append("Tag confidence: "+String(format:"%.0f%%",confidence*100)+(item.manual ? " · human reviewed" : " · inference"))}
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
        browsing.async {[weak self] in
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
    @objc func showReading() {
        guard let item=selectedRecords().first,let reader=workspace?.catalog else{return};metadataTicket+=1;bodyButton.isEnabled=false;status.stringValue="Reading a bounded retained excerpt; original file unopened…"
        browsing.async {[weak self] in let result:Result<String,Error>=Result {try reader.storedReading(item)}
            DispatchQueue.main.async {guard let self=self,self.selectedRecords().first?.path==item.path else{return};switch result {case .success(let text):self.inspector.string="RETAINED CONTENT · "+item.state+"\n"+item.path+"\n\n"+text;self.status.stringValue="Stored excerpt only; partial reading and inference limits remain applicable.";case .failure(let error):self.status.stringValue=error.localizedDescription}}
        }
    }
    @objc func revealSource() {if let item=selectedRecords().first {NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath:item.path)])}}
    @objc func editDestinations() {workspace?.view.window?.makeKeyAndOrderFront(nil)}
    @objc func assignSelected() {
        guard let workspace=workspace,let id=destination.selectedItem?.representedObject as? String else{return}
        guard !workspace.busy else {status.stringValue="Wait for the active verification or copy to finish before changing its draft.";return}
        let paths=selectedRecords().filter {$0.kind=="file" || $0.kind=="directory"}.map(\.path)
        guard !paths.isEmpty else {status.stringValue="Select real files or folders in List or Folder tree. Virtual tag/map groups are filters, not source folders.";return}
        do {try workspace.store.change {try $0.assign(paths,to:id)};workspace.plan=nil;workspace.refreshDraft();showMetadata();status.stringValue="\(paths.count) drops / buckets assigned in the draft. Exact source → destination paths are visible; no filesystem action ran."}
        catch {status.stringValue=error.localizedDescription}
    }
    func show() {
        if window==nil {let w=NSWindow(contentRect:NSRect(x:0,y:0,width:1480,height:900),styleMask:[.titled,.closable,.miniaturizable,.resizable],backing:.buffered,defer:false);w.title="KonMagic · Atlas Explorer";w.minSize=NSSize(width:1230,height:800);w.contentViewController=self;w.isReleasedWhenClosed=false;w.setFrameAutosaveName("KonMagicExplorer");w.center();window=w}
        refreshDestinations();window?.makeKeyAndOrderFront(nil)
    }
}
