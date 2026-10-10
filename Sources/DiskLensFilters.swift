import AppKit

final class LensFilterEditor:NSWindowController,NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate,NSWindowDelegate {
    var filter:LensFilter,result:LensFilter?
    var activeGroup = -1
    let group = NSPopUpButton(),scope = NSPopUpButton(),invert = NSButton(checkboxWithTitle:"Exclude compound group",target:nil,action:nil)
    var rules:[LensRule] {get {activeGroup<0 ? filter.rules:filter.groups[activeGroup].rules} set {if activeGroup<0 {filter.rules=newValue} else {filter.groups[activeGroup].rules=newValue}}}
    let table=NSTableView(),name=NSTextField(),all=NSButton(checkboxWithTitle:"Match ALL tests (uncheck for ANY)",target:nil,action:nil)
    let mixed=NSButton(checkboxWithTitle:"Include ANY positive test, exclude ALL negated matches",target:nil,action:nil)
    init(_ value:LensFilter) {
        filter=value
        let w=NSWindow(contentRect:NSRect(x:0,y:0,width:850,height:570),styleMask:[.titled,.closable],backing:.buffered,defer:false)
        super.init(window:w);w.title="Disk Lens · Filter tests";w.isReleasedWhenClosed=false;w.delegate=self
        let outer=NSStackView();outer.orientation = .vertical;outer.alignment = .leading;outer.spacing=12;outer.translatesAutoresizingMaskIntoConstraints=false;w.contentView!.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:w.contentView!.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:w.contentView!.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:w.contentView!.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:w.contentView!.bottomAnchor,constant:-18)])
        name.stringValue=filter.name;name.placeholderString="Filter name";name.widthAnchor.constraint(equalToConstant:810).isActive=true;all.state=filter.matchAll ? .on:.off
        mixed.state=filter.includeAnyExcludeAll ? .on:.off
        group.target=self;group.action=#selector(groupChanged);scope.addItems(withTitles:["files","folders","both"]);scope.target=self;scope.action=#selector(scopeChanged);invert.target=self;invert.action=#selector(invertChanged);refreshGroups()
        let groups=NSStackView(views:[group,NSButton(title:"New compound group",target:self,action:#selector(newGroup)),NSButton(title:"Remove group",target:self,action:#selector(removeGroup)),scope,invert]);groups.orientation = .horizontal;groups.spacing=8
        let note=NSTextField(wrappingLabelWithString:"Text tests ignore case. Sizes use bytes; times use Unix seconds. Boolean tests use isTrue / isFalse. Negate inverts a test. A mask preserves rectangle areas; a filter creates a separate retained view; scan exclusions skip matching subtrees.")
        note.font=NSFont.systemFont(ofSize:11);note.widthAnchor.constraint(equalToConstant:810).isActive=true
        table.delegate=self;table.dataSource=self;table.rowHeight=34;table.allowsMultipleSelection=true
        for (id,title,width) in [("field","Metadata",155.0),("operator","Test",145.0),("value","Value",415.0),("not","Negate",70.0)] {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=title;c.width=width;table.addTableColumn(c)}
        let scroll=NSScrollView();scroll.documentView=table;scroll.hasVerticalScroller=true;scroll.widthAnchor.constraint(equalToConstant:810).isActive=true;scroll.heightAnchor.constraint(equalToConstant:250).isActive=true
        let buttons=NSStackView();buttons.orientation = .horizontal;buttons.spacing=8
        for (title,action) in [("Add test",#selector(add)),("Remove selected",#selector(remove)),("Cancel",#selector(cancel)),("Use filter",#selector(save))] {let b=NSButton(title:title,target:self,action:action);b.bezelStyle = .rounded;buttons.addArrangedSubview(b)}
        for v in [name,all,mixed,groups,note,scroll,buttons] {outer.addArrangedSubview(v)}
    }
    required init?(coder:NSCoder) {fatalError("Use a filter")}
    func numberOfRows(in tableView:NSTableView)->Int {rules.count}
    func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView? {
        let r=rules[row]
        switch column?.identifier.rawValue {
        case "field":let p=NSPopUpButton();p.addItems(withTitles:LensField.allCases.map(\.title));p.selectItem(at:LensField.allCases.firstIndex(of:r.field)!);p.tag=row;p.target=self;p.action=#selector(fieldChanged);return p
        case "operator":let p=NSPopUpButton();p.addItems(withTitles:LensOperator.allCases.map(\.rawValue));p.selectItem(at:LensOperator.allCases.firstIndex(of:r.operation)!);p.tag=row;p.target=self;p.action=#selector(operatorChanged);return p
        case "not":let b=NSButton(checkboxWithTitle:"",target:self,action:#selector(negateChanged));b.state=r.negated ? .on:.off;b.tag=row;return b
        default:let t=NSTextField();t.stringValue=r.value;t.tag=row;t.delegate=self;return t
        }
    }
    func controlTextDidChange(_ obj:Notification) {if let t=obj.object as? NSTextField,t.tag<rules.count {rules[t.tag].value=t.stringValue}}
    @objc func fieldChanged(_ p:NSPopUpButton) {rules[p.tag].field=LensField.allCases[p.indexOfSelectedItem]}
    @objc func operatorChanged(_ p:NSPopUpButton) {rules[p.tag].operation=LensOperator.allCases[p.indexOfSelectedItem]}
    @objc func negateChanged(_ b:NSButton) {rules[b.tag].negated=b.state == .on}
    @objc func add() {guard rules.count<32 else{return};rules.append(LensRule());table.reloadData()}
    @objc func remove() {for i in table.selectedRowIndexes.reversed() {rules.remove(at:i)};table.reloadData()}
    func refreshGroups() {group.removeAllItems();group.addItem(withTitle:"Flat tests");group.addItems(withTitles:filter.groups.map(\.name));group.selectItem(at:activeGroup+1);scope.isEnabled=activeGroup>=0;invert.isEnabled=activeGroup>=0;if activeGroup>=0 {scope.selectItem(withTitle:filter.groups[activeGroup].scope);invert.state=filter.groups[activeGroup].negated ? .on:.off}}
    @objc func groupChanged() {activeGroup=group.indexOfSelectedItem-1;refreshGroups();table.reloadData()}
    @objc func scopeChanged() {if activeGroup>=0 {filter.groups[activeGroup].scope=scope.titleOfSelectedItem ?? "files"}}
    @objc func invertChanged() {if activeGroup>=0 {filter.groups[activeGroup].negated=invert.state == .on}}
    @objc func newGroup() {guard filter.groups.count<8 else{return};filter.groups.append(LensTestGroup(name:"Group \(filter.groups.count+1)",rules:[LensRule()]));activeGroup=filter.groups.count-1;refreshGroups();table.reloadData()}
    @objc func removeGroup() {guard activeGroup>=0 else{return};filter.groups.remove(at:activeGroup);activeGroup = -1;refreshGroups();table.reloadData()}
    @objc func cancel() {NSApp.stopModal();window?.orderOut(nil)}
    func windowShouldClose(_ sender:NSWindow)->Bool {cancel();return false}
    @objc func save() {window?.makeFirstResponder(nil);filter.name=name.stringValue;filter.matchAll=all.state == .on;filter.includeAnyExcludeAll=mixed.state == .on;do {try filter.validate();result=filter;NSApp.stopModal();window?.orderOut(nil)} catch {let a=NSAlert();a.messageText="Review this filter";a.informativeText=error.localizedDescription;a.runModal()}}
    func edit()->LensFilter? {window?.center();window?.makeKeyAndOrderFront(nil);NSApp.runModal(for:window!);return result}
}
