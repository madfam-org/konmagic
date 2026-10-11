import AppKit

// This page renders draft paths and an already verified manifest. It never
// traverses sources; all verification and execution keep the existing guards.
final class ReorganizationReviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate {
    weak var workspace:KonMagicController?
    let table=NSTableView(),search=NSSearchField(),inspector=KonMagicInspector()
    let summary=NSTextField(wrappingLabelWithString:""),message=NSTextField(wrappingLabelWithString:"")
    let source=NSTextField(wrappingLabelWithString:""),destination=NSTextField(wrappingLabelWithString:""),output=NSTextField(labelWithString:"")
    let viewSource=NSButton(),verify=NSButton(),copy=NSButton(),rename=NSButton(),remove=NSButton(),export=NSButton(),previous=NSButton(),next=NSButton()
    var assignments:[Assignment]=[],selectedIDs=Set<String>(),recordOffset=0,refreshing=false
    let manifestTable=NSTableView(),evidenceButton=NSButton()
    var manifestRecords:[FileRecord]=[],detailsScroll:NSScrollView?,manifestScroll:NSScrollView?,showExactEvidence=false
    init(workspace:KonMagicController) {self.workspace=workspace;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use workspace")}
    func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField {let t=NSTextField(labelWithString:value);t.font=NSFont.systemFont(ofSize:size,weight:weight);return t}
    func row(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.spacing=10;s.orientation = .horizontal;s.alignment = .centerY;return s}
    func column(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.spacing=12;s.orientation = .vertical;s.alignment = .leading;return s}
    func button(_ b:NSButton,_ title:String,_ action:Selector) {b.title=title;b.target=self;b.action=action;b.bezelStyle = .rounded}
    let verificationTitle=FriendlyUI.label("Awaiting verification",size:16,weight:.semibold,wrapping:true)
    let verificationDetails=FriendlyUI.label("",size:11,wrapping:true),receiptDetails=FriendlyUI.label("",size:10,wrapping:true)
    let selectionHeading=FriendlyUI.label("Your reorganization preview",size:20,weight:.semibold,wrapping:true)
    func pathCard(_ title:String,_ field:NSTextField,_ symbol:String)->FriendlyPanel {
        field.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);field.textColor=FriendlyUI.text;field.isSelectable=true;field.maximumNumberOfLines=0;field.setAccessibilityLabel(title)
        let words=column([FriendlyUI.row([FriendlyUI.image(symbol,tint:FriendlyUI.violet,size:20),FriendlyUI.label(title,size:11,weight:.semibold)]),field]);words.spacing=10
        field.widthAnchor.constraint(equalTo:words.widthAnchor).isActive=true
        return FriendlyUI.panel(words,tint:FriendlyUI.violet,padding:14)
    }
    override func loadView() {
        view=FriendlyCanvas(frame:NSRect(x:0,y:0,width:1480,height:900))
        search.placeholderString="Search outputs, files, or destinations";search.delegate=self;search.setAccessibilityLabel("Filter proposed assignments")
        table.delegate=self;table.dataSource=self;table.rowHeight=68;table.headerView=nil;table.usesAlternatingRowBackgroundColors=false;table.backgroundColor=FriendlyUI.surface;table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier("assignment"));c.width=390;table.addTableColumn(c);table.setAccessibilityLabel("Proposed source to destination assignments")
        let list=NSScrollView();list.documentView=table;list.hasVerticalScroller=true;list.autohidesScrollers=true;list.drawsBackground=false
        button(rename,"Rename output…",#selector(renameSelected));button(remove,"Remove assignment",#selector(removeSelected))
        let left=column([search,FriendlyUI.row([FriendlyUI.image("rectangle.split.2x2",tint:FriendlyUI.teal),FriendlyUI.label("Planned outputs",size:15,weight:.semibold)]),list]);left.widthAnchor.constraint(equalToConstant:390).isActive=true
        for v in [search,list] {v.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true}
        summary.font=NSFont.systemFont(ofSize:12,weight:.medium);summary.textColor=FriendlyUI.muted;summary.maximumNumberOfLines=2
        let sourceCard=pathCard("Source retained",source,"house"),destinationCard=pathCard("Proposed destination",destination,"folder")
        let paths=row([sourceCard,destinationCard]);paths.distribution = .fillEqually
        inspector.isEditable=false;inspector.isSelectable=true;inspector.isVerticallyResizable=true;inspector.autoresizingMask = [.width];inspector.textContainer?.widthTracksTextView=true;inspector.textContainerInset=NSSize(width:14,height:12);inspector.backgroundColor=FriendlyUI.surface;inspector.textColor=FriendlyUI.text
        inspector.setAccessibilityLabel("Verified file paths and complete SHA-256 hashes")
        let details=NSScrollView();details.documentView=inspector;details.hasVerticalScroller=true;details.autohidesScrollers=true
        detailsScroll=details
        manifestTable.delegate=self;manifestTable.dataSource=self;manifestTable.rowHeight=34;manifestTable.usesAlternatingRowBackgroundColors=true;manifestTable.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        manifestTable.setAccessibilityLabel("Verified manifest page; exact source/destination paths and full hashes available in evidence")
        for (id,title,width) in [("name","File or folder",180.0),("relative","Relative path",150.0),("bytes","Size",80.0),("hash","SHA-256",150.0)] {let col=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));col.title=title;col.width=width;manifestTable.addTableColumn(col)}
        let manifest=NSScrollView();manifest.documentView=manifestTable;manifest.hasVerticalScroller=true;manifest.hasHorizontalScroller=true;manifest.autohidesScrollers=true;manifest.isHidden=true;manifestScroll=manifest
        let inventory=NSView();for v in [details,manifest] {v.translatesAutoresizingMaskIntoConstraints=false;inventory.addSubview(v);NSLayoutConstraint.activate([v.leadingAnchor.constraint(equalTo:inventory.leadingAnchor),v.trailingAnchor.constraint(equalTo:inventory.trailingAnchor),v.topAnchor.constraint(equalTo:inventory.topAnchor),v.bottomAnchor.constraint(equalTo:inventory.bottomAnchor)])}
        inventory.heightAnchor.constraint(greaterThanOrEqualToConstant:200).isActive=true
        button(evidenceButton,"Exact paths & hashes",#selector(toggleExactEvidence))
        button(previous,"Previous 200",#selector(previousRecords));button(next,"Next 200",#selector(nextRecords));button(export,"Export manifest…",#selector(exportManifest))
        let choose=FriendlyUI.button("Choose output…",symbol:"folder",target:workspace,action:#selector(KonMagicController.chooseOutput))
        let edit=FriendlyUI.button("Edit structure",symbol:"pencil",target:self,action:#selector(editStructure))
        button(verify,"Verify exact preview",#selector(verifyDraft));button(copy,"Review & copy…",#selector(copyDraft));copy.bezelColor=FriendlyUI.violet;copy.controlSize = .large;verify.controlSize = .large
        viewSource.title="View source…";viewSource.target=self;viewSource.action=#selector(previewSelectedSource);viewSource.bezelStyle = .rounded
        output.font=NSFont.monospacedSystemFont(ofSize:10,weight:.regular);output.textColor=FriendlyUI.muted;output.lineBreakMode = .byTruncatingMiddle;output.toolTip=output.stringValue
        let right=column([selectionHeading,summary,paths,row([edit,rename,remove]),row([viewSource,choose]),row([FriendlyUI.label("Verified manifest",size:13,weight:.semibold),NSView(),evidenceButton]),inventory,row([previous,next,NSView(),export])]);right.widthAnchor.constraint(greaterThanOrEqualToConstant:570).isActive=true
        for v in [selectionHeading,summary,paths,inventory] {v.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true}
        verificationDetails.textColor=FriendlyUI.muted;receiptDetails.textColor=FriendlyUI.muted;receiptDetails.isSelectable=true
        let checks=column([FriendlyUI.label("Verification status",size:13,weight:.semibold),verificationTitle,verificationDetails,verify]);checks.widthAnchor.constraint(equalToConstant:222).isActive=true
        for v in [verificationTitle,verificationDetails,verify] {v.widthAnchor.constraint(equalTo:checks.widthAnchor).isActive=true}
        let checkCard=FriendlyUI.panel(checks,tint:FriendlyUI.teal,padding:14)
        let receipts=FriendlyUI.button("Receipts & recovery",symbol:"clock.arrow.circlepath",target:workspace,action:#selector(KonMagicController.openJournal))
        let receiptColumn=column([FriendlyUI.label("Receipts & history",size:13,weight:.semibold),receiptDetails,receipts]);receiptColumn.widthAnchor.constraint(equalToConstant:222).isActive=true;receiptDetails.widthAnchor.constraint(equalTo:receiptColumn.widthAnchor).isActive=true
        let receiptCard=FriendlyUI.panel(receiptColumn,padding:14)
        let copyWords=FriendlyUI.label("Verification does not copy your files. Approval is separate, and your originals remain intact. Draft edits require a new verification.",size:11,wrapping:true);copyWords.textColor=FriendlyUI.muted
        let approvalColumn=column([FriendlyUI.label("Copy approval",size:14,weight:.semibold),copyWords,copy,FriendlyUI.label("Output root",size:10,weight:.semibold),output]);approvalColumn.widthAnchor.constraint(equalToConstant:222).isActive=true
        for v in [copyWords,copy,output] {v.widthAnchor.constraint(equalTo:approvalColumn.widthAnchor).isActive=true}
        let approval=FriendlyUI.panel(approvalColumn,tint:FriendlyUI.orange,padding:14)
        let sidebar=column([checkCard,receiptCard,approval]);sidebar.widthAnchor.constraint(equalToConstant:250).isActive=true
        let leftPanel=FriendlyUI.panel(left,padding:14),centerPanel=FriendlyUI.panel(right,padding:14),sidePanel=FriendlyUI.scrollingPanel(sidebar,width:278,padding:14)
        let body=row([leftPanel,centerPanel,sidePanel]);body.alignment = .top;body.spacing=16
        centerPanel.widthAnchor.constraint(equalTo:body.widthAnchor,constant:-728).isActive=true
        for v in [leftPanel,centerPanel,sidePanel] {v.heightAnchor.constraint(equalTo:body.heightAnchor).isActive=true}
        let mascot=FriendlyMascot(kind:2);mascot.widthAnchor.constraint(equalToConstant:68).isActive=true;mascot.heightAnchor.constraint(equalToConstant:76).isActive=true
        let heading=column([FriendlyUI.label("KONMAGIC  /  TRUST CENTER",size:10,weight:.semibold),FriendlyUI.label("Review",size:32,weight:.bold),FriendlyUI.label("See exactly what would be created. Verify first, approve separately.",size:12)])
        let head=row([mascot,heading,NSView(),FriendlyUI.button("Review guide",symbol:"book",target:self,action:#selector(reviewGuide))])
        message.font=NSFont.systemFont(ofSize:11);message.textColor=FriendlyUI.muted;message.maximumNumberOfLines=2
        let outer=column([head,body,message]);outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:22),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-22),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18)])
        for v in [head,body,message] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        refresh()
    }
    @objc func reviewGuide() {KonMagicDocumentation.open("guide/review/")}
    func updateVerificationPresentation() {
        guard let w=workspace else{return}
        selectionHeading.stringValue=selected?.outputName ?? "Your reorganization preview"
        if let plan=w.plan {
            verificationTitle.stringValue=w.busy ? "Work in progress":"Verified proposal"
            verificationTitle.textColor=FriendlyUI.green
            verificationDetails.stringValue="Full hashes checked: \(plan.fileCount) files\nDestination suitability checked\nCollision checks passed\nCapacity checked at verification\n\nCurrent checks repeat before copying."
            let date=DateFormatter();date.dateStyle = .medium;date.timeStyle = .short
            receiptDetails.stringValue="Preview prepared "+date.string(from:plan.prepared)+"\n\nPreview ID: "+plan.id+"\n\nA preview is not a copy receipt. Open receipts for operation history."
        } else {
            verificationTitle.stringValue=w.busy ? "Work in progress":"Awaiting verification";verificationTitle.textColor=FriendlyUI.muted
            verificationDetails.stringValue="Source identities · Pending\nFull hashes · Pending\nCollisions · Pending\nCapacity · Pending\n\nVerification creates no output."
            receiptDetails.stringValue="No verified preview for this draft. Completed copy operations have durable receipts available below."
        }
    }
    func refresh() {
        guard isViewLoaded,let w=workspace else{return};refreshing=true
        let query=search.stringValue.trimmingCharacters(in:.whitespacesAndNewlines).lowercased()
        assignments=w.store.value.assignments.filter {query.isEmpty || ($0.source+" "+((try? w.store.value.destination($0)) ?? "")).lowercased().contains(query)}
        table.reloadData()
        let index=assignments.firstIndex {selectedIDs.contains($0.id)} ?? (assignments.isEmpty ? nil:0)
        if let i=index {selectedIDs=[assignments[i].id];table.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false)} else {selectedIDs=[];table.deselectAll(nil)}
        refreshing=false
        output.stringValue=w.store.value.output;output.toolTip=output.stringValue
        verify.isEnabled = !w.busy && !w.store.value.assignments.isEmpty;copy.isEnabled = !w.busy && w.plan != nil
        viewSource.isEnabled=index != nil && !w.busy
        rename.isEnabled = !w.busy && index != nil;remove.isEnabled=rename.isEnabled;export.isEnabled=w.plan != nil
        refreshStatus();renderSelection();updateVerificationPresentation()
    }
    func refreshStatus() {
        guard isViewLoaded,let w=workspace else{return}
        let status=w.status.stringValue
        let operation=["Checking capacity","Verified ","Preview held.","Copy stopped.","The draft changed","No transfers have run.","Verifying and copying."].contains {status.hasPrefix($0)}
        if w.busy || operation {message.stringValue=status}
        else if let plan=w.plan {message.stringValue="Verified \(plan.fileCount) files. Inspect exact paths and the manifest; copy approval remains separate."}
        else {message.stringValue="\(w.store.value.assignments.count) proposed assignments. Choose an output, inspect exact paths, then verify. Your originals stay in place."}
    }
    func select(paths:[String]) {selectedIDs=Set(workspace?.store.value.assignments.filter {paths.contains($0.source)}.map(\.id) ?? []);recordOffset=0;refresh()}
    var selected:Assignment? {let r=table.selectedRow;return r>=0 && r<assignments.count ? assignments[r]:nil}
    func renderSelection() {
        guard let w=workspace else{return}
        manifestRecords=[];manifestTable.reloadData();detailsScroll?.isHidden=false;manifestScroll?.isHidden=true;evidenceButton.isEnabled=false
        let total=w.store.value.assignments.count
        summary.stringValue=w.plan.map {"Verified · \($0.fileCount) files · \(ByteCountFormatter.string(fromByteCount:$0.bytes,countStyle:.file))"} ?? (total==0 ? "Your draft is ready for its first assignment" : "\(total) proposed assignments · awaiting verification")
        source.stringValue=selected?.source ?? "Select a file or whole folder in Content, choose its destination, then add it to this draft."
        destination.stringValue=selected.flatMap {try? w.store.value.destination($0)} ?? (total==0 ? "Shape destinations in Structure. Your virtual folders are created only by a separately approved copy." : "No assignment matches this search.")
        source.toolTip=source.stringValue;destination.toolTip=destination.stringValue
        previous.isEnabled=false;next.isEnabled=false
        guard let a=selected else {inspector.string=total==0 ? "START WITH SOMETHING YOU KNOW\nFamily memories, an active project or a research collection.\n\n1. Browse its files or whole folders in Content.\n2. Choose an explicit destination.\n3. Add the selection to your draft.\n4. Inspect these exact paths, then verify when ready." : "Clear or refine the assignment search to see its exact paths.";return}
        guard let bucket=w.plan?.buckets.first(where:{$0.assignment.id==a.id}) else {inspector.string="PATH PREVIEW · UNVERIFIED\nThe two paths above are your exact proposed placement.\n\nWhole folders preserve every relative path and empty folder. Their contents have not been verified for this draft.\n\nVerify exact preview checks current source identities, protected boundaries, collisions, available capacity and full SHA-256 hashes. It creates no destination folders.\n\nOriginals remain in place. Copy requires a separate approval.";return}
        recordOffset=min(recordOffset,max(0,((bucket.records.count-1)/200)*200))
        let end=min(bucket.records.count,recordOffset+200)
        manifestRecords=Array(bucket.records[recordOffset..<end]);manifestTable.reloadData();evidenceButton.isEnabled=true;updateInventoryPresentation()
        var blocks=["VERIFIED CONTENTS · \(bucket.records.count) entries\nShowing \(recordOffset+1)–\(end). Export the manifest for the complete batch."]
        for record in bucket.records[recordOffset..<end] {
            let from=record.relative.isEmpty ? a.source:URL(fileURLWithPath:a.source).appendingPathComponent(record.relative).path
            let to=record.relative.isEmpty ? bucket.destination:URL(fileURLWithPath:bucket.destination).appendingPathComponent(record.relative).path
            blocks.append((record.directory ? "FOLDER":"FILE")+"\nSOURCE · retained\n"+from+"\nCHOSEN DESTINATION · proposed copy\n"+to+(record.hash.map {"\nSHA-256 "+$0} ?? ""))
        }
        inspector.string=blocks.joined(separator:"\n\n");previous.isEnabled=recordOffset>0;next.isEnabled=end<bucket.records.count
    }
    func numberOfRows(in tableView:NSTableView)->Int {tableView===manifestTable ? manifestRecords.count:assignments.count}
    func tableView(_ tableView:NSTableView,viewFor tableColumn:NSTableColumn?,row:Int)->NSView? {
        if tableView===manifestTable {
            let record=manifestRecords[row],value:String
            switch tableColumn?.identifier.rawValue {
            case "name":value=record.relative.isEmpty ? (selected?.outputName ?? "Root"):URL(fileURLWithPath:record.relative).lastPathComponent
            case "relative":value=record.relative.isEmpty ? "/":record.relative
            case "bytes":value=record.directory ? "Folder":ByteCountFormatter.string(fromByteCount:record.identity.bytes,countStyle:.file)
            default:value=record.hash.map {String($0.prefix(12))+"…"+String($0.suffix(4))} ?? "—"
            }
            let field=label(value,size:11);field.lineBreakMode = .byTruncatingMiddle;field.isSelectable=true;field.toolTip=record.relative+"\n"+(record.hash ?? "Empty folder retained");return field
        }
        let a=assignments[row],cell=NSTableCellView(),name=label(a.outputName,size:13,weight:.medium),path=label((try? workspace?.store.value.path(a.node)) ?? "Invalid destination",size:11)
        path.textColor = .secondaryLabelColor;path.lineBreakMode = .byTruncatingMiddle
        let stack=column([name,path]);stack.spacing=4;stack.translatesAutoresizingMaskIntoConstraints=false;cell.addSubview(stack);cell.textField=name;cell.toolTip=a.source
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:cell.leadingAnchor,constant:10),stack.trailingAnchor.constraint(equalTo:cell.trailingAnchor,constant:-10),stack.centerYAnchor.constraint(equalTo:cell.centerYAnchor)])
        return cell
    }
    func tableViewSelectionDidChange(_ notification:Notification) {guard (notification.object as? NSTableView) === table,!refreshing else{return};selectedIDs=Set(selected.map {[$0.id]} ?? []);recordOffset=0;refresh();workspace?.pageHost?.updateNavigation()}
    func updateInventoryPresentation() {detailsScroll?.isHidden = !showExactEvidence;manifestScroll?.isHidden=showExactEvidence;evidenceButton.title=showExactEvidence ? "Manifest table":"Exact paths & hashes"}
    @objc func toggleExactEvidence() {showExactEvidence.toggle();updateInventoryPresentation()}
    func controlTextDidChange(_ notification:Notification) {recordOffset=0;refresh()}
    func selectWorkspaceAssignment() {guard let w=workspace,let a=selected,let i=w.store.value.assignments.firstIndex(where:{$0.id==a.id}) else{return};_ = w.view;w.draft.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false)}
    @objc func renameSelected() {selectWorkspaceAssignment();workspace?.renameOutput()}
    @objc func removeSelected() {selectWorkspaceAssignment();workspace?.removeAssignment()}
    @objc func verifyDraft() {workspace?.verifyPreview()}
    @objc func copyDraft() {workspace?.applyCopy()}
    @objc func editStructure() {if let a=selected {workspace?.focusedDestinationID=a.node};workspace?.showWorkspace()}
    @objc func previousRecords() {recordOffset=max(0,recordOffset-200);renderSelection()}
    @objc func nextRecords() {recordOffset+=200;renderSelection()}
    @objc func exportManifest() {guard let w=workspace,let p=w.plan else{return};let save=NSSavePanel();save.nameFieldStringValue="konmagic-copy-preview.json";if save.runModal() == .OK,let u=save.url {do {try SafeFS.writeRecord(p,at:u)} catch {w.showError(error)}}}
}

final class WorkflowStatusField:NSTextField {
    var changed:(()->Void)?
    override var stringValue:String {didSet {changed?()}}
}
