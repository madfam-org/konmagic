import AppKit
import SQLite3
import CryptoKit
import Darwin

struct DuplicateSizeGroup {let bytes:Int64;let count:Int64}
struct DuplicateProof {
    var matches:[String:[String]]=[:]
    var held:[String]=[]
    var checked=0
    var details:String {
        var lines=["COMPLETE FILE-DATA HASH REVIEW","\(checked) files checked · \(matches.count) equal-data groups · \(held.count) held","","Equal hashes describe the data fork at verification time. Resource forks, extended attributes, metadata, hard links and APFS shared blocks need separate preservation review. No file is marked safe to delete and no reclaimable-byte claim is made."]
        for (hash,paths) in matches.sorted(by:{$0.key<$1.key}) {lines += ["","SHA-256: "+hash]+paths}
        if !held.isEmpty {lines += ["","HELD"]+held}
        return lines.joined(separator:"\n")
    }
}
extension LensStore {
    func duplicateSizes(cursor:Int64?=nil,cancellation:CatalogueCancellation) throws -> (groups:[DuplicateSizeGroup],next:Int64?) {
        let reader=try AtlasDatabase(url.path,seconds:60,cancellation:cancellation);var groups:[DuplicateSizeGroup]=[]
        let whereClause="kind=0 AND duplicate=0 AND bytes>0 AND flags & 1073741824=0"+(cursor == nil ? "" : " AND bytes<?")
        try reader.rows("SELECT bytes,count(*) FROM nodes WHERE "+whereClause+" GROUP BY bytes HAVING count(*)>1 ORDER BY bytes DESC LIMIT 201",cursor.map {[String($0)]} ?? []) {s in groups.append(DuplicateSizeGroup(bytes:sqlite3_column_int64(s,0),count:sqlite3_column_int64(s,1)))}
        let more=groups.count>200;if more {groups.removeLast()};return (groups,more ? groups.last?.bytes : nil)
    }
    func duplicateMembers(bytes:Int64) throws -> [LensNode] {
        try nodes(where:"n.kind=0 AND n.duplicate=0 AND n.bytes=? AND n.flags & 1073741824=0",values:[String(bytes)],order:"n.id",limit:101)
    }
    func proveDuplicates(nodes:[LensNode],cancellation:CatalogueCancellation,allowFixture:Bool=false) throws -> DuplicateProof {
        var total:Int64=0
        for n in nodes {let sum=total.addingReportingOverflow(n.bytes);guard n.bytes>=0,!sum.overflow,sum.partialValue<=SafeFS.byteLimit else {throw KonMagicError("Candidate group exceeds the 100 GiB verification bound.")};total=sum.partialValue}
        guard nodes.count>=2,nodes.count<=100,nodes.allSatisfy({$0.kind==0}) else {throw KonMagicError("Verify 2–100 regular files. Narrow large candidate groups before reading any file bodies.")}
        let info=try snapshot();var proof=DuplicateProof(),all:[String:[String]]=[:],identities=Set<String>()
        for node in nodes {
            guard !cancellation.cancelled else {throw KonMagicError("Duplicate verification stopped. No files were changed.")}
            let path=path(node,info)
            do {
                if !allowFixture {try SafeFS.sourceGuard(path)}
                guard !node.cloud,!SafeFS.guardedName(node.name) else {throw KonMagicError("Protected or cloud-only source")}
                let parent=try SafeFS.openDirectory(URL(fileURLWithPath:path).deletingLastPathComponent().path);defer {close(parent)}
                let st=try SafeFS.info(parent,node.name)
                guard SafeFS.isFile(st),Int64(st.st_dev)==node.device,Int64(bitPattern:UInt64(st.st_ino))==node.inode,st.st_size==node.bytes,Int64(st.st_mtimespec.tv_sec)==node.modified else {throw KonMagicError("Current metadata differs from this scan")}
                if let finished=info.finished {
                    let modified=Double(st.st_mtimespec.tv_sec)+Double(st.st_mtimespec.tv_nsec)/1_000_000_000
                    let changed=Double(st.st_ctimespec.tv_sec)+Double(st.st_ctimespec.tv_nsec)/1_000_000_000
                    guard max(modified,changed)<=finished.timeIntervalSince1970 else {throw KonMagicError("Source changed after this scan; refresh before hashing")}
                }
                let id=String(st.st_dev)+":"+String(st.st_ino)
                guard identities.insert(id).inserted else {throw KonMagicError("Same inode already checked; hard links are not independent duplicate copies")}
                let fd=openat(parent,node.name,O_RDONLY|O_NOFOLLOW|O_NONBLOCK);guard fd>=0 else {throw SafeFS.fail("Cannot safely open candidate")};defer {close(fd)}
                var opened=stat();guard fstat(fd,&opened)==0,Identity(opened)==Identity(st),opened.st_flags & 0x40000000==0 else {throw KonMagicError("Source identity changed while opening")}
                let hash=try cancellableHash(fd,cancellation:cancellation)
                all[hash,default:[]].append(path);proof.checked+=1
            } catch {if cancellation.cancelled {throw error};proof.held.append(path+" — "+error.localizedDescription)}
        }
        proof.matches=all.filter {$0.value.count>1};return proof
    }
}
private func cancellableHash(_ fd:Int32,cancellation:CatalogueCancellation) throws -> String {
    // Same complete SHA-256 and identity checks as the copy engine, with a stop
    // check between bounded reads. Hashes never authorize deletion.
    var before=stat();guard fstat(fd,&before)==0,SafeFS.isFile(before),lseek(fd,0,SEEK_SET)>=0 else {throw SafeFS.fail("Cannot hash candidate")}
    var hash=SHA256(),buffer=[UInt8](repeating:0,count:1024*1024)
    while true {
        guard !cancellation.cancelled else {throw KonMagicError("Duplicate verification stopped")}
        let n=read(fd,&buffer,buffer.count)
        if n==0 {break};if n<0 {if errno==EINTR {continue};throw SafeFS.fail("Incomplete candidate read")}
        hash.update(data:Data(buffer.prefix(n)))
    }
    var after=stat();guard fstat(fd,&after)==0,Identity(before)==Identity(after) else {throw KonMagicError("Candidate changed during hashing")}
    return hash.finalize().map {String(format:"%02x",$0)}.joined()
}

final class DuplicateReviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    let store:LensStore
    let queue=DispatchQueue(label:"org.madfam.konmagic.duplicate-review",qos:.utility)
    let table=NSTableView(),detail=KonMagicInspector(),status=NSTextField(wrappingLabelWithString:""),next=NSButton(),previous=NSButton(),verify=NSButton(),stop=NSButton()
    var groups:[DuplicateSizeGroup]=[],members:[LensNode]=[],window:NSWindow?,cursor:Int64?,nextCursor:Int64?,history:[Int64?]=[],ticket=0,cancellation=CatalogueCancellation()
    var activityChanged:(()->Void)?
    var busy=false {didSet {activityChanged?()}}
    init(store:LensStore) {self.store=store;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use scan")}
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1050,height:700))
        let title=NSTextField(wrappingLabelWithString:"Duplicate review · equal size is a candidate, not proof. Hard-link aliases and cloud placeholders are excluded from candidate counts. Select a group to inspect its paths; verify reads full data only after a separate confirmation. Files always remain in place.")
        table.dataSource=self;table.delegate=self;table.usesAlternatingRowBackgroundColors=true;table.rowHeight=32
        for (id,name,width) in [("size","Same logical size",160.0),("count","Candidate files",110.0)] {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=name;c.width=width;table.addTableColumn(c)}
        let list=NSScrollView();list.documentView=table;list.hasVerticalScroller=true;list.widthAnchor.constraint(equalToConstant:290).isActive=true
        detail.isEditable=false;detail.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);detail.textContainerInset=NSSize(width:12,height:12);detail.autoresizingMask=[.width];detail.textContainer?.widthTracksTextView=true;detail.string="Select a same-size group. Every displayed candidate remains unverified until a complete current hash succeeds."
        let content=NSScrollView();content.documentView=detail;content.hasVerticalScroller=true
        let panels=NSStackView(views:[list,content]);panels.orientation = .horizontal;panels.spacing=10;panels.heightAnchor.constraint(greaterThanOrEqualToConstant:500).isActive=true
        previous.title="Previous 200";previous.target=self;previous.action=#selector(goPrevious)
        next.title="Next 200";next.target=self;next.action=#selector(goNext)
        verify.title="Verify this group's full hashes…";verify.target=self;verify.action=#selector(prove)
        stop.title="Stop verification";stop.target=self;stop.action=#selector(cancel)
        for b in [previous,next,verify,stop] {b.bezelStyle = .rounded}
        let controls=NSStackView(views:[previous,next,verify,stop]);controls.spacing=10
        let outer=NSStackView(views:[title,panels,controls,status]);outer.orientation = .vertical;outer.spacing=12;outer.alignment = .leading;outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18),title.widthAnchor.constraint(equalTo:outer.widthAnchor),panels.widthAnchor.constraint(equalTo:outer.widthAnchor),content.widthAnchor.constraint(equalTo:panels.widthAnchor,constant:-300),status.widthAnchor.constraint(equalTo:outer.widthAnchor)])
        load()
    }
    func show() {let w=NSWindow(contentRect:NSRect(x:0,y:0,width:1050,height:700),styleMask:[.titled,.closable,.resizable],backing:.buffered,defer:false);w.title="KonMagic · Duplicate evidence";w.minSize=NSSize(width:900,height:660);w.contentViewController=self;w.isReleasedWhenClosed=false;w.center();window=w;w.makeKeyAndOrderFront(nil)}
    func numberOfRows(in tableView:NSTableView)->Int {groups.count}
    func tableView(_ tableView:NSTableView,objectValueFor tableColumn:NSTableColumn?,row:Int)->Any? {tableColumn?.identifier.rawValue=="size" ? ByteCountFormatter.string(fromByteCount:groups[row].bytes,countStyle:.binary) : String(groups[row].count)}
    func load() {
        guard !busy else{return};busy=true;controls();status.stringValue="Grouping retained metadata; original file bodies unopened…";let cursor=cursor;cancellation=CatalogueCancellation()
        queue.async {[weak self] in guard let self=self else{return};let result=Result {try self.store.duplicateSizes(cursor:cursor,cancellation:self.cancellation)}
            DispatchQueue.main.async {self.busy=false;switch result {case .success(let page):self.groups=page.groups;self.nextCursor=page.next;self.status.stringValue="Page \(self.history.count+1) · \(page.groups.count) size groups · metadata candidates only";case .failure(let e):self.groups=[];self.nextCursor=nil;self.status.stringValue=e.localizedDescription};self.members=[];self.table.reloadData();self.controls()}
        }
    }
    func controls() {next.isEnabled = !busy && nextCursor != nil;previous.isEnabled = !busy && !history.isEmpty;verify.isEnabled = !busy && members.count>=2 && members.count<=100;stop.isEnabled=busy;table.isEnabled = !busy}
    func tableViewSelectionDidChange(_ notification:Notification) {
        guard !busy,table.selectedRow>=0,table.selectedRow<groups.count else{return};let group=groups[table.selectedRow];ticket+=1;let serial=ticket;members=[];controls()
        queue.async {[weak self] in guard let self=self else{return};let result=Result {try self.store.duplicateMembers(bytes:group.bytes)}
            DispatchQueue.main.async {guard self.ticket==serial else{return};switch result {case .success(let nodes):self.members=nodes;let info=try? self.store.snapshot();self.detail.string="\(group.count) equal-size candidates · \(group.bytes) logical bytes each\n\n"+(nodes.count>100 ? "First 101 shown. Group is too large to hash here; select a narrower folder scan.\n\n" : "Current identities and every data byte remain unchecked.\n\n")+nodes.map {self.store.path($0,info ?? LensSnapshot())}.joined(separator:"\n");case .failure(let e):self.detail.string=e.localizedDescription};self.controls()}
        }
    }
    @objc func goNext() {guard !busy,let next=nextCursor else{return};history.append(cursor);cursor=next;ticket+=1;load()}
    @objc func goPrevious() {guard !busy,!history.isEmpty else{return};cursor=history.removeLast();ticket+=1;load()}
    @objc func cancel() {cancellation.cancel()}
    @objc func prove() {
        guard !busy,members.count>=2,members.count<=100 else{return};let nodes=members,total=nodes.reduce(Int64(0),{$0+$1.bytes})
        let a=NSAlert();a.messageText="Read full data for this exact candidate group?";a.informativeText="Verify \(nodes.count) listed files, totaling "+ByteCountFormatter.string(fromByteCount:total,countStyle:.binary)+". This reads complete data to calculate SHA-256. Protected paths, symlinks, changed identities and cloud placeholders remain held. Hashing does not authorize removal. No files will move or change.";a.addButton(withTitle:"Read & verify");a.addButton(withTitle:"Keep reviewing")
        guard a.runModal() == .alertFirstButtonReturn else{return}
        busy=true;cancellation=CatalogueCancellation();let cancel=cancellation;controls();status.stringValue="Checking identities and complete hashes. Stop is safe; sources remain unchanged…"
        queue.async {[weak self] in guard let self=self else{return};let result=Result {try self.store.proveDuplicates(nodes:nodes,cancellation:cancel)}
            DispatchQueue.main.async {self.busy=false;switch result {case .success(let proof):self.detail.string=proof.details;self.status.stringValue="\(proof.checked) complete hashes checked · \(proof.matches.count) equal-data groups · sources retained";case .failure(let e):self.status.stringValue=e.localizedDescription};self.controls()}
        }
    }
}
extension DiskLensController {
    @objc func duplicateReview() {guard let store=store else{return};let c=DuplicateReviewController(store:store);duplicateControllers.append(c);if let host=workspace?.pageHost {host.showDetail(c,title:"Storage / Duplicate evidence") {_ in DuplicateReviewController(store:store)}} else {c.show()}}
}
