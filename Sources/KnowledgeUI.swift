import AppKit

extension CatalogueExplorerController {
    func knowledgeAccessory(_ views:[NSView])->NSView {
        dialogAccessory(views)
    }
    func knowledgeForm(_ labels:[String],_ fields:[NSTextField])->NSGridView {
        let grid=NSGridView(views:zip(labels,fields).map {[text($0.0),$0.1]})
        grid.rowSpacing=12;grid.columnSpacing=16;grid.rowAlignment = .firstBaseline
        grid.column(at:0).xPlacement = .trailing;grid.column(at:1).xPlacement = .fill
        return grid
    }
    func field(_ value:String="",placeholder:String="")->NSTextField {
        let f=NSTextField(string:value);f.placeholderString=placeholder;f.widthAnchor.constraint(equalToConstant:410).isActive=true;return f
    }
    func knowledgeChanged() {if let navigation=workspace?.navigation {navigation.knowledgeChanged()} else {reloadKnowledge();workspace?.plan=nil;workspace?.refreshDraft()}}
    func reloadKnowledge() {
        allSummary=nil;summary=nil;resetPaging();loadPage();loadSummary()
        if displayedView==1 {loadRoots()} else if displayedView==2 {roots=[];tree.reloadData()}
    }
    @objc func correctTags() {
        guard let knowledge=workspace?.knowledge else{return}
        let selected=selectedRecords(),paths=selected.map(\.path)
        let a=NSAlert();a.messageText="Your tags override inference"
        a.informativeText="\(selected.count) selected files / folders. Your choices stay private and apply to these exact paths. Folder descendants keep their own tags. Blank fields stay unchanged; “Unassigned” clears a category. Original evidence and protection stay intact."
        let fields=Knowledge.fields.map {key -> NSTextField in
            let values=Set(selected.map {$0.tags[key] ?? ""})
            return field(values.count==1 ? values.first! : "",placeholder:values.count>1 ? "Mixed — leave unchanged" : "Leave unchanged")
        }
        let note=field(placeholder:"Why this classification? (optional)")
        a.accessoryView=knowledgeAccessory([knowledgeForm(Knowledge.fields.map {$0.capitalized}+["Note"],fields+[note])])
        a.addButton(withTitle:"Save corrections");a.addButton(withTitle:"Cancel");a.addButton(withTitle:"Reset selected");a.addButton(withTitle:"Undo last correction")
        a.buttons[0].isEnabled = !paths.isEmpty && paths.count<=200
        a.buttons[2].isEnabled=paths.contains {knowledge.snapshot().corrections[$0] != nil}
        a.buttons[3].isEnabled = !knowledge.snapshot().undo.isEmpty
        let validation=DialogValidation(fields:fields+[note]) {
            let changed=zip(Knowledge.fields,fields).contains {key,f in let value=f.stringValue.trimmingCharacters(in:.whitespacesAndNewlines);let corrected=value=="Unassigned" ? "" : value;return !value.isEmpty && !selected.allSatisfy {($0.tags[key] ?? "")==corrected}}
            a.buttons[0].isEnabled = !paths.isEmpty && paths.count<=200 && changed && fields.allSatisfy {$0.stringValue.utf8.count<=240} && note.stringValue.utf8.count<=2000
            a.buttons[0].toolTip=changed ? "Save your edited classifications privately." : "Edit at least one semantic field to save a correction."
        }
        let response=validation.run(a)
        do {
            if response == .alertFirstButtonReturn {
                var tags:[String:String]=[:]
                for (key,f) in zip(Knowledge.fields,fields) {let value=f.stringValue.trimmingCharacters(in:.whitespacesAndNewlines);if !value.isEmpty {let corrected=value=="Unassigned" ? "" : value;if !selected.allSatisfy({($0.tags[key] ?? "")==corrected}) {tags[key]=corrected}}}
                try knowledge.correct(paths:paths,tags:tags,note:note.stringValue)
            } else if response.rawValue==1002 {try knowledge.reset(paths:paths)}
            else if response.rawValue==1003 {try knowledge.undoCorrection()}
            else {return}
            knowledgeChanged();status.stringValue="Personal tag decisions saved. Lists, filters and maps now share the same effective classification. Original files are unchanged."
        } catch {status.stringValue=error.localizedDescription}
    }
    @objc func collectionsMenu() {
        guard let knowledge=workspace?.knowledge else{return}
        guard tagged else {status.stringValue="Collections save semantic views from Tagged catalogue. Disk Lens separately saves full physical scans.";return}
        let saved=knowledge.snapshot().collections.sorted {$0.name.localizedStandardCompare($1.name) == .orderedAscending}
        let a=NSAlert();a.messageText="Saved collections";a.informativeText="Save this folder, search, facet intersection and visualization as a reusable view. Collections reference the catalogue; they do not duplicate or move files."
        let name=field(placeholder:"Name for the current view"),choice=NSPopUpButton()
        choice.addItem(withTitle:"Choose a saved collection…");for c in saved {choice.addItem(withTitle:c.name);choice.lastItem?.representedObject=c.id}
        choice.widthAnchor.constraint(equalToConstant:410).isActive=true
        a.accessoryView=knowledgeAccessory([text("Save current view"),name,text("Existing collections"),choice])
        a.addButton(withTitle:"Save current");a.addButton(withTitle:"Cancel");a.addButton(withTitle:"Open selected");a.addButton(withTitle:"Delete selected")
        let validation=DialogValidation(fields:[name],popups:[choice]) {
            a.buttons[0].isEnabled = (try? Workspace.checkName(name.stringValue.trimmingCharacters(in:.whitespacesAndNewlines))) != nil
            let chosen=choice.selectedItem?.representedObject as? String
            a.buttons[2].isEnabled=chosen != nil;a.buttons[3].isEnabled=chosen != nil
        }
        let response=validation.run(a)
        do {
            if response == .alertFirstButtonReturn {
                var query=slice();query.cursor=nil
                try knowledge.save(SavedCollection(name:name.stringValue.trimmingCharacters(in:.whitespacesAndNewlines),slice:query,mode:mode.selectedSegment,dimension:activeDimension,metric:metric.indexOfSelectedItem))
                status.stringValue="Collection saved privately."
            } else if response.rawValue==1002,let id=choice.selectedItem?.representedObject as? String,let c=saved.first(where:{$0.id==id}) {
                folder=c.slice.folder;filters=c.slice.facets;search.stringValue=c.slice.search;searchMode.selectItem(at:c.slice.contentSearch ? 1 : 0)
                mode.selectedSegment=c.mode;dimension.selectItem(at:CatalogueDimension.allCases.firstIndex(of:c.dimension) ?? 0);metric.selectItem(at:c.metric)
                updateMode();resetPaging();loadPage();loadSummary();if c.mode==1 {loadRoots()}
            } else if response.rawValue==1003,let id=choice.selectedItem?.representedObject as? String {try knowledge.removeCollection(id);status.stringValue="Collection removed; originals and tag corrections are retained."}
        } catch {status.stringValue=error.localizedDescription}
    }
    @objc func rulesMenu() {
        guard let knowledge=workspace?.knowledge else{return}
        guard tagged else {status.stringValue="Proposal rules use the Tagged catalogue's semantic filters.";return}
        let rules=knowledge.snapshot().rules.sorted {$0.name.localizedStandardCompare($1.name) == .orderedAscending}
        let a=NSAlert();a.messageText="Reusable proposal rules"
        a.informativeText="A rule matches this folder, search and facets, then proposes exact destinations and output names. Choose a draft destination in Content Explorer before creating one. Rules run only when requested and retain manual assignments. Nothing is copied by a rule."
        let choice=NSPopUpButton();choice.addItem(withTitle:"Choose a saved rule…")
        for r in rules {choice.addItem(withTitle:r.name);choice.lastItem?.representedObject=r.id}
        choice.widthAnchor.constraint(equalToConstant:410).isActive=true;a.accessoryView=knowledgeAccessory([choice])
        a.addButton(withTitle:"New from current view…");a.addButton(withTitle:"Cancel");a.addButton(withTitle:"Preview selected");a.addButton(withTitle:"Delete selected")
        let validation=DialogValidation(popups:[choice]) {
            a.buttons[0].isEnabled=self.destination.selectedItem?.representedObject as? String != nil
            let chosen=choice.selectedItem?.representedObject as? String
            a.buttons[2].isEnabled=chosen != nil;a.buttons[3].isEnabled=chosen != nil
        }
        let response=validation.run(a)
        if response == .alertFirstButtonReturn {createRule()}
        else if response.rawValue==1002,let id=choice.selectedItem?.representedObject as? String,let r=rules.first(where:{$0.id==id}) {previewRule(r)}
        else if response.rawValue==1003,let id=choice.selectedItem?.representedObject as? String {do {try knowledge.removeRule(id);status.stringValue="Rule removed; assignments and original files retained."} catch {status.stringValue=error.localizedDescription}}
    }
    func createRule() {
        guard let workspace=workspace,let id=destination.selectedItem?.representedObject as? String else {status.stringValue="Choose an explicit draft destination in the inspector before saving a proposal rule.";return}
        let a=NSAlert();a.messageText="Create a proposal rule"
        a.informativeText="Uses the current semantic query. Destination: "+((try? workspace.store.value.path(id)) ?? "Unavailable")+"\n\nNames affect the output copy only. Prefix, suffix and literal replacement operate on the filename stem and preserve its extension. Leave them blank to retain the name."
        let name=field(placeholder:"Rule name"),prefix=field(),suffix=field(),find=field(),replace=field()
        a.accessoryView=knowledgeAccessory([knowledgeForm(["Rule name","Prefix","Suffix","Find (literal)","Replace with"],[name,prefix,suffix,find,replace])])
        a.addButton(withTitle:"Save & preview");a.addButton(withTitle:"Cancel")
        let validation=DialogValidation(fields:[name,prefix,suffix,find,replace]) {
            let named=(try? Workspace.checkName(name.stringValue.trimmingCharacters(in:.whitespacesAndNewlines))) != nil
            let recipe=NameRecipe(prefix:prefix.stringValue,suffix:suffix.stringValue,find:find.stringValue,replacement:replace.stringValue)
            a.buttons[0].isEnabled=named && [prefix,suffix,find,replace].allSatisfy {$0.stringValue.utf8.count<=100} && (try? recipe.output("example.pdf")) != nil
        }
        guard validation.run(a) == .alertFirstButtonReturn else{return}
        do {
            var query=slice();query.cursor=nil
            let recipe=NameRecipe(prefix:prefix.stringValue,suffix:suffix.stringValue,find:find.stringValue,replacement:replace.stringValue)
            let rule=ProposalRule(name:name.stringValue.trimmingCharacters(in:.whitespacesAndNewlines),slice:query,destination:id,recipe:recipe)
            try workspace.knowledge.save(rule);previewRule(rule)
        } catch {status.stringValue=error.localizedDescription}
    }
    func previewRule(_ rule:ProposalRule) {
        guard let workspace=workspace,!workspace.busy else {status.stringValue="Wait for verification or copying to finish before proposing a new draft.";return}
        let original=workspace.store.value,reader=workspace.catalog
        status.stringValue="Preparing a bounded rule preview…"
        browsing.async {[weak self,weak workspace] in
            let result:Result<DraftProposal,Error>=Result {let page=try reader.cataloguePage(rule.slice);return try DraftProposal.make(items:page.items,rule:rule,workspace:original,more:page.next != nil)}
            DispatchQueue.main.async {
                guard let self=self,let workspace=workspace else{return}
                do {
                    let proposal=try result.get()
                    guard workspace.store.value.version==original.version,!workspace.busy else {throw KonMagicError("The workspace changed while preparing this proposal. Preview the rule again.")}
                    let a=NSAlert();a.messageText="Exact proposal · "+rule.name
                    a.informativeText="\(proposal.assignments.count) assignments proposed · \(proposal.held.count) held. "+(proposal.limited ? "Bounded to the first 200 matches and 100 draft assignments; narrow the query for the rest. " : "")+"Adding these edits only the draft. Fresh source hashes, access, destination existence and capacity are checked separately by Verify exact preview."
                    let text=NSTextView();text.isEditable=false;text.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular)
                    text.string=try proposal.assignments.map {$0.source+"\n→ "+(try original.destination($0))+"\n"}.joined(separator:"\n")+"\nHELD\n"+proposal.held.joined(separator:"\n")
                    let sc=self.scroll(text);sc.frame=NSRect(x:0,y:0,width:720,height:410);text.frame=sc.bounds;text.isVerticallyResizable=true;text.autoresizingMask = [.width];text.textContainer?.widthTracksTextView=true
                    a.accessoryView=sc;a.addButton(withTitle:"Add to draft");a.addButton(withTitle:"Keep reviewing");a.buttons[0].isEnabled = !proposal.assignments.isEmpty
                    guard a.runModal() == .alertFirstButtonReturn else{return}
                    guard workspace.store.value.version==original.version,!workspace.busy else {throw KonMagicError("The draft changed during review. Preview the rule again.")}
                    try workspace.store.change {try proposal.apply(to:&$0)};workspace.plan=nil;workspace.refreshDraft();workspace.showWorkspace()
                    self.status.stringValue="Exact proposal added to the draft. No source or destination files were changed."
                } catch {self.status.stringValue=error.localizedDescription}
            }
        }
    }
}
