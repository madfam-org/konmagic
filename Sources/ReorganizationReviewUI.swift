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
    init(workspace:KonMagicController) {self.workspace=workspace;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use workspace")}
    func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField {let t=NSTextField(labelWithString:value);t.font=NSFont.systemFont(ofSize:size,weight:weight);return t}
    func row(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.spacing=10;s.orientation = .horizontal;s.alignment = .centerY;return s}
    func column(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.spacing=12;s.orientation = .vertical;s.alignment = .leading;return s}
    func button(_ b:NSButton,_ title:String,_ action:Selector) {b.title=title;b.target=self;b.action=action;b.bezelStyle = .rounded}
    func pathCard(_ title:String,_ field:NSTextField,_ symbol:String)->NSBox {
        let box=NSBox();box.boxType = .custom;box.cornerRadius=10;box.borderWidth=1;box.borderColor = .separatorColor;box.fillColor = .controlBackgroundColor;box.contentViewMargins=NSSize(width:16,height:12)
        let icon=NSImageView(image:NSImage(systemSymbolName:symbol,accessibilityDescription:nil) ?? NSImage());icon.contentTintColor = .secondaryLabelColor
        icon.widthAnchor.constraint(equalToConstant:18).isActive=true
        let titleField=label(title,size:10,weight:.semibold);titleField.textColor = .secondaryLabelColor
        field.font=NSFont.monospacedSystemFont(ofSize:12,weight:.regular);field.isSelectable=true;field.maximumNumberOfLines=0;field.setAccessibilityLabel(title)
        let stack=column([row([icon,titleField]),field]);stack.spacing=8;stack.translatesAutoresizingMaskIntoConstraints=false
        if let content=box.contentView {content.addSubview(stack);NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:content.leadingAnchor),stack.trailingAnchor.constraint(equalTo:content.trailingAnchor),stack.topAnchor.constraint(equalTo:content.topAnchor),stack.bottomAnchor.constraint(equalTo:content.bottomAnchor),field.widthAnchor.constraint(equalTo:stack.widthAnchor)])}
        return box
    }
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1280,height:800))
        search.placeholderString="Find an assignment by name or destination";search.delegate=self;search.setAccessibilityLabel("Filter proposed assignments")
        table.delegate=self;table.dataSource=self;table.rowHeight=64;table.headerView=nil;table.usesAlternatingRowBackgroundColors=true;table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier("assignment"));c.width=390;table.addTableColumn(c);table.setAccessibilityLabel("Proposed source to destination assignments")
        let list=NSScrollView();list.documentView=table;list.hasVerticalScroller=true;list.autohidesScrollers=true
        button(rename,"Rename copied item…",#selector(renameSelected));button(remove,"Remove from draft",#selector(removeSelected))
        let left=column([label("YOUR ASSIGNMENTS",size:11,weight:.semibold),search,list,row([rename,remove])]);left.widthAnchor.constraint(equalToConstant:390).isActive=true
        for v in [search,list] {v.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true}
        summary.font=NSFont.systemFont(ofSize:14,weight:.semibold);summary.maximumNumberOfLines=2
        let sourceCard=pathCard("SOURCE · RETAINED",source,"doc"),destinationCard=pathCard("DESTINATION · PROPOSED COPY",destination,"folder")
        inspector.isEditable=false;inspector.isSelectable=true;inspector.isVerticallyResizable=true;inspector.autoresizingMask = [.width];inspector.textContainer?.widthTracksTextView=true;inspector.textContainerInset=NSSize(width:14,height:12)
        inspector.setAccessibilityLabel("Verified file paths and complete SHA-256 hashes")
        let details=NSScrollView();details.documentView=inspector;details.hasVerticalScroller=true;details.autohidesScrollers=true
        button(previous,"Previous 200",#selector(previousRecords));button(next,"Next 200",#selector(nextRecords));button(export,"Export verified manifest…",#selector(exportManifest))
        let right=column([summary,sourceCard,destinationCard,label("CONTENTS & VERIFICATION",size:11,weight:.semibold),details,row([previous,next,NSView(),export])])
        for v in [summary,sourceCard,destinationCard,details] {v.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true}
        details.heightAnchor.constraint(greaterThanOrEqualToConstant:200).isActive=true
        let body=row([left,right]);body.alignment = .top;left.heightAnchor.constraint(equalTo:body.heightAnchor).isActive=true;right.heightAnchor.constraint(equalTo:body.heightAnchor).isActive=true
        right.widthAnchor.constraint(equalTo:body.widthAnchor,constant:-400).isActive=true
        output.font=NSFont.systemFont(ofSize:11);output.textColor = .secondaryLabelColor;output.lineBreakMode = .byTruncatingMiddle
        let choose=NSButton(title:"Choose output…",target:workspace,action:#selector(KonMagicController.chooseOutput));choose.bezelStyle = .rounded
        let edit=NSButton(title:"Edit folder structure",target:self,action:#selector(editStructure));edit.bezelStyle = .rounded
        let receipts=NSButton(title:"Receipts & recovery",target:workspace,action:#selector(KonMagicController.openJournal));receipts.bezelStyle = .rounded
        button(verify,"Verify exact preview",#selector(verifyDraft));button(copy,"Review & copy…",#selector(copyDraft))
        let root=row([label("OUTPUT ROOT",size:10,weight:.semibold),output,choose]);output.setContentCompressionResistancePriority(.defaultLow,for:.horizontal)
        viewSource.title="View source…";viewSource.target=self;viewSource.action=#selector(previewSelectedSource);viewSource.bezelStyle = .rounded
        let actions=row([edit,receipts,viewSource,NSView(),verify,copy]);message.font=NSFont.systemFont(ofSize:12);message.textColor = .secondaryLabelColor;message.maximumNumberOfLines=2
        let line=NSBox();line.boxType = .separator
        let outer=column([body,line,root,actions,message]);outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:22),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-22),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18)])
        for v in [body,line,root,actions,message] {v.widthAnchor.constraint(equalTo:outer.widthAnchor).isActive=true}
        refresh()
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
        refreshStatus();renderSelection()
    }
    func refreshStatus() {guard isViewLoaded,let w=workspace else{return};message.stringValue=w.status.stringValue.isEmpty ? "Choose an assignment to inspect both full paths. Verification is a separate read of current identities and complete hashes." : w.status.stringValue}
    func select(paths:[String]) {selectedIDs=Set(workspace?.store.value.assignments.filter {paths.contains($0.source)}.map(\.id) ?? []);recordOffset=0;refresh()}
    var selected:Assignment? {let r=table.selectedRow;return r>=0 && r<assignments.count ? assignments[r]:nil}
    func renderSelection() {
        guard let w=workspace else{return}
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
        var blocks=["VERIFIED CONTENTS · \(bucket.records.count) entries\nShowing \(recordOffset+1)–\(end). Export the manifest for the complete batch."]
        for record in bucket.records[recordOffset..<end] {
            let from=record.relative.isEmpty ? a.source:URL(fileURLWithPath:a.source).appendingPathComponent(record.relative).path
            let to=record.relative.isEmpty ? bucket.destination:URL(fileURLWithPath:bucket.destination).appendingPathComponent(record.relative).path
            blocks.append((record.directory ? "FOLDER":"FILE")+"\nSOURCE · retained\n"+from+"\nCHOSEN DESTINATION · proposed copy\n"+to+(record.hash.map {"\nSHA-256 "+$0} ?? ""))
        }
        inspector.string=blocks.joined(separator:"\n\n");previous.isEnabled=recordOffset>0;next.isEnabled=end<bucket.records.count
    }
    func numberOfRows(in tableView:NSTableView)->Int {assignments.count}
    func tableView(_ tableView:NSTableView,viewFor tableColumn:NSTableColumn?,row:Int)->NSView? {
        let a=assignments[row],cell=NSTableCellView(),name=label(a.outputName,size:13,weight:.medium),path=label((try? workspace?.store.value.path(a.node)) ?? "Invalid destination",size:11)
        path.textColor = .secondaryLabelColor;path.lineBreakMode = .byTruncatingMiddle
        let stack=column([name,path]);stack.spacing=4;stack.translatesAutoresizingMaskIntoConstraints=false;cell.addSubview(stack);cell.textField=name;cell.toolTip=a.source
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo:cell.leadingAnchor,constant:10),stack.trailingAnchor.constraint(equalTo:cell.trailingAnchor,constant:-10),stack.centerYAnchor.constraint(equalTo:cell.centerYAnchor)])
        return cell
    }
    func tableViewSelectionDidChange(_ notification:Notification) {guard !refreshing else{return};selectedIDs=Set(selected.map {[$0.id]} ?? []);recordOffset=0;refresh();workspace?.pageHost?.updateNavigation()}
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
