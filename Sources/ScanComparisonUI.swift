import AppKit

final class ScanComparisonController:NSViewController,NSTableViewDataSource {
    let current:LensStore,baseline:LensStore
    let table=NSTableView(),status=NSTextField(wrappingLabelWithString:""),next=NSButton(),previous=NSButton()
    let queue=DispatchQueue(label:"org.madfam.konmagic.comparison",qos:.utility)
    var window:NSWindow?,rows:[LensDifference]=[],cursor:String?,nextCursor:String?,history:[String?]=[],busy=false
    var cancellation=CatalogueCancellation()
    init(current:LensStore,baseline:LensStore) {self.current=current;self.baseline=baseline;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use scans")}
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1050,height:650))
        let title=NSTextField(wrappingLabelWithString:"Metadata changes between observations. Filters, exclusions and access gaps can produce added/removed records; this does not prove deletion or byte equality. Browse every change in pages, or export the full comparison.")
        table.dataSource=self;table.usesAlternatingRowBackgroundColors=true;table.rowHeight=30;table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        for (id,label,width) in [("status","Change",90.0),("before","Before",110.0),("after","After",110.0),("path","Relative path",700.0)] {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=label;c.width=width;table.addTableColumn(c)}
        let scroll=NSScrollView();scroll.documentView=table;scroll.hasVerticalScroller=true
        previous.title="Previous 500";previous.target=self;previous.action=#selector(goPrevious);previous.bezelStyle = .rounded
        next.title="Next 500";next.target=self;next.action=#selector(goNext);next.bezelStyle = .rounded
        let export=NSButton(title:"Export all changes…",target:self,action:#selector(exportAll));export.bezelStyle = .rounded
        let buttons=NSStackView(views:[previous,next,export]);buttons.spacing=10
        let stack=NSStackView(views:[title,scroll,buttons,status]);stack.orientation = .vertical;stack.alignment = .leading;stack.spacing=12;stack.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),stack.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),stack.topAnchor.constraint(equalTo:view.topAnchor,constant:18),stack.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18),scroll.heightAnchor.constraint(greaterThanOrEqualToConstant:420),scroll.widthAnchor.constraint(equalTo:stack.widthAnchor),title.widthAnchor.constraint(equalTo:stack.widthAnchor),status.widthAnchor.constraint(equalTo:stack.widthAnchor)])
        load()
    }
    func show() {let w=NSWindow(contentRect:NSRect(x:0,y:0,width:1050,height:650),styleMask:[.titled,.closable,.resizable],backing:.buffered,defer:false);w.title="KonMagic · Complete scan comparison";w.minSize=NSSize(width:800,height:600);w.contentViewController=self;w.isReleasedWhenClosed=false;w.center();window=w;w.makeKeyAndOrderFront(nil)}
    func numberOfRows(in tableView:NSTableView)->Int {rows.count}
    func tableView(_ tableView:NSTableView,objectValueFor tableColumn:NSTableColumn?,row:Int)->Any? {
        let r=rows[row]
        switch tableColumn?.identifier.rawValue {case "status":return r.status;case "before":return ByteCountFormatter.string(fromByteCount:r.before,countStyle:.binary);case "after":return ByteCountFormatter.string(fromByteCount:r.after,countStyle:.binary);default:return r.path}
    }
    func load() {
        guard !busy else{return};busy=true;next.isEnabled=false;previous.isEnabled=false;status.stringValue="Comparing retained metadata in the background…"
        let cursor=cursor
        queue.async {[weak self] in guard let self=self else{return};let result=Result {try self.current.differencePage(self.baseline,cursor:cursor,cancellation:self.cancellation)}
            DispatchQueue.main.async {self.busy=false;switch result {case .success(let page):self.rows=page.rows;self.nextCursor=page.next;self.status.stringValue="Page \(self.history.count+1) · \(page.rows.count) changes"+(page.next==nil ? " · end of comparison" : " · more changes available");case .failure(let e):self.rows=[];self.nextCursor=nil;self.status.stringValue=e.localizedDescription};self.table.reloadData();self.next.isEnabled=self.nextCursor != nil;self.previous.isEnabled = !self.history.isEmpty}
        }
    }
    @objc func goNext() {guard !busy,let next=nextCursor else{return};history.append(cursor);cursor=next;load()}
    @objc func goPrevious() {guard !busy,!history.isEmpty else{return};cursor=history.removeLast();load()}
    @objc func exportAll() {
        guard !busy else{return};let p=NSSavePanel();p.nameFieldStringValue="Scan changes.tsv"
        guard p.runModal() == .OK,let url=p.url else{return}
        busy=true;next.isEnabled=false;previous.isEnabled=false;status.stringValue="Exporting every retained metadata change. Originals remain unchanged…"
        queue.async {[weak self] in guard let self=self else{return};let result=Result {try self.current.exportDifferences(self.baseline,to:url,cancellation:self.cancellation)}
            DispatchQueue.main.async {self.busy=false;switch result {case .success(let count):self.status.stringValue="Exported all \(count) changes privately.";case .failure(let e):self.status.stringValue=e.localizedDescription};self.next.isEnabled=self.nextCursor != nil;self.previous.isEnabled = !self.history.isEmpty}
        }
    }
}
