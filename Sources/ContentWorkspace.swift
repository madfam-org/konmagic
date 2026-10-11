import AppKit
import Quartz

struct ContentTreeState {
    let key:String,roots:[ExplorerNode],expanded:[ExplorerNode],selected:[ExplorerNode]
    let scroll:NSPoint
}
struct ContentHandoff {
    let base:CatalogItem,scope:String
    var item:CatalogItem
}

final class ContentStageHost:NSView {
    weak var owner:CatalogueExplorerController?
    override func draw(_ rect:NSRect) {FriendlyUI.background.setFill();rect.fill()}
    override func performKeyEquivalent(with event:NSEvent)->Bool {
        guard let owner=owner else{return super.performKeyEquivalent(with:event)}
        let flags=event.modifierFlags.intersection(.deviceIndependentFlagsMask),key=event.charactersIgnoringModifiers?.lowercased() ?? ""
        if flags.contains(.command),flags.contains(.option),let n=Int(key),(1...6).contains(n) {owner.switchContentView(n-1);return true}
        if flags.contains(.command),key=="f" {owner.view.window?.makeFirstResponder(owner.search);return true}
        return super.performKeyEquivalent(with:event)
    }
}

extension CatalogueExplorerController {
    @objc func toggleContentFocus() {setContentFocus(!contentFocused)}
    func setContentFocus(_ value:Bool) {
        _ = view;contentFocused=value;sourcesVisible = !value;contentInspectorVisible = !value
        focusContentButton.title=value ? "Exit focus":"Focus content"
        for v in contentChrome {v.isHidden=value}
        contentOuter?.spacing=value ? 0:14;contentColumns?.spacing=value ? 0:16;contentCenter?.spacing=value ? 4:10
        for c in contentEdges {c.constant=value ? 0:(c.firstAttribute == .top ? 16:c.firstAttribute == .bottom ? -16:c.firstAttribute == .leading ? 18:-18)}
        for c in contentCenterPanel?.constraints ?? [] where c.firstItem as? NSView === contentCenter {c.constant=value ? 0:(c.firstAttribute == .trailing || c.firstAttribute == .bottom ? -14:14)}
        updateContentPanels()
    }
    func updateContentPanels() {
        sourcesPanel?.isHidden = !sourcesVisible;contentInspectorPanel?.isHidden = !contentInspectorVisible
        sourcesToggle.state=sourcesVisible ? .on:.off;contentInspectorToggle.state=contentInspectorVisible ? .on:.off
        contentWidth?.constant = -(sourcesVisible ? 238:0)-(contentInspectorVisible ? 338:0)-(contentFocused ? 0:CGFloat((sourcesVisible ? 1:0)+(contentInspectorVisible ? 1:0))*16)
        workspace?.pageHost?.updateMapFocus();view.layoutSubtreeIfNeeded();gallery.arrange()
        if !contentInspectorVisible {clearInlinePreview()}
    }
    @objc func toggleContentSources() {sourcesVisible.toggle();updateContentPanels()}
    @objc func toggleContentInspector() {contentInspectorVisible.toggle();updateContentPanels()}
    @objc func contentFullScreen() {view.window?.toggleFullScreen(nil)}
    @objc func contentFitMap() {contentMapViewport.fitMap()}
    @objc func galleryDensityChanged() {gallery.arrange()}
    @objc func returnToStorage() {workspace?.showDiskLens()}
    @objc func contentGuide() {KonMagicDocumentation.open("guide/content/")}
    func switchContentView(_ index:Int) {
        guard index>=0,index<6,mode.isEnabled(forSegment:index) else{return}
        mode.selectedSegment=index;changeVisualization()
    }
    var treeContextKey:String {"\(dataset.indexOfSelectedItem)\n\(folder ?? "")"}
    func saveContentTree(_ mode:Int) {
        guard mode==1 || mode==2,!treeLoading else{return}
        let expanded=(0..<tree.numberOfRows).lazy.compactMap {self.tree.item(atRow:$0) as? ExplorerNode}.filter {self.tree.isItemExpanded($0)}.prefix(256)
        let selected=tree.selectedRowIndexes.prefix(200).compactMap {tree.item(atRow:$0) as? ExplorerNode}
        let key=mode==1 ? physicalTreeKey:tagTreeKey
        let state=ContentTreeState(key:key ?? "",roots:roots,expanded:Array(expanded),selected:selected,scroll:treeScroll.contentView.bounds.origin)
        if mode==1 {physicalTreeState=state} else {tagTreeState=state}
    }
    func restoreContentTree(_ state:ContentTreeState) {
        roots=state.roots;tree.reloadData()
        for node in state.expanded where node.children != nil {tree.expandItem(node)}
        tree.selectRowIndexes(IndexSet(state.selected.map {tree.row(forItem:$0)}.filter {$0>=0}),byExtendingSelection:false)
        treeScroll.contentView.scroll(to:state.scroll);treeScroll.reflectScrolledClipView(treeScroll.contentView)
    }
    func syncContentWorkspace() {
        density.isHidden=displayedView != 5
        mapFitButton.isHidden=displayedView != 3 && displayedView != 4
        thumbnailButton.isHidden=displayedView != 5;releaseImagesButton.isHidden=displayedView != 5
        sourcePreviewToolbar.isEnabled = previewSourceButton.isEnabled && workspace?.busy != true
        compactSelection.stringValue=selectionPending ? "Updating retained observations…" : selectedRecords().first.map {"\(selectedRecords().count) selected · "+$0.path} ?? "Select real sources to inspect, classify and assign · Originals stay in place"
        compactSelection.toolTip=compactSelection.stringValue
        handoffBar?.isHidden=handoff==nil
        handoffButton.title=handoff.map {"From Storage: "+$0.item.name+(handoffSelected ? " · Selected":" · Inspect")} ?? "From Storage"
        handoffButton.toolTip=handoff?.item.path
        workspace?.pageHost?.updateNavigation()
    }
    func acceptStorageSource(_ base:CatalogItem?,scope:String,focused:Bool) {
        showRecordedFolder(scope)
        if focused && !contentFocused {setContentFocus(true)}
        contentInspectorVisible=true;updateContentPanels()
        guard let base=base else {clearStorageHandoff();return}
        handoff=ContentHandoff(base:base,scope:scope,item:base);handoffSelected=true;refreshStorageHandoff()
    }
    func refreshStorageHandoff() {
        guard let h=handoff,let w=workspace else{return}
        handoffRevision+=1;let revision=handoffRevision;handoffLoading=true;showMetadata()
        let reader=w.catalog,snapshot=w.knowledge.snapshot()
        browsing.async {[weak self] in
            let item=(try? reader.observation(at:h.base.path)) ?? snapshot.applying(to:h.base)
            DispatchQueue.main.async {guard let self=self,self.handoffRevision==revision,self.handoff?.base.path==h.base.path else{return}
                guard self.workspace?.knowledge.snapshot().tagStamp==snapshot.tagStamp else {self.refreshStorageHandoff();return}
                self.handoff?.item=item;self.handoffLoading=false;self.showMetadata()
            }
        }
    }
    @objc func selectStorageHandoff() {
        guard handoff != nil,!handoffLoading else{return}
        if ![0,1,5].contains(displayedView) {switchContentView(0)}
        table.deselectAll(nil);tree.deselectAll(nil);handoffSelected=true;contentInspectorVisible=true;updateContentPanels();showMetadata()
    }
    @objc func clearStorageHandoff() {handoffRevision+=1;handoffLoading=false;handoff=nil;handoffSelected=false;showMetadata()}
    func clearInlinePreview() {
        inlinePreviewGeneration+=1;inlinePreview.previewItem=nil;inlinePreview.isHidden=true;selectionImage.isHidden=false;inlinePreviewPath=nil
    }
    @objc func clearContentPreview() {clearInlinePreview();gallery.clear();status.stringValue="Previews and thumbnail requests released. Original files and decisions retained."}
    @objc func previewInInspector() {
        guard let item=selectedRecords().first,selectedRecords().count==1,item.kind=="file" || item.kind=="directory",workspace?.busy != true else{return}
        contentInspectorVisible=true;updateContentPanels()
        if item.kind=="directory" {previewSelectedSource();return}
        clearInlinePreview();inlinePreviewGeneration+=1;let token=inlinePreviewGeneration
        status.stringValue="Checking this source before an explicit Quick Look request…"
        let fixture=CommandLine.arguments.contains("--documentation-capture") && item.path.hasPrefix(workspace!.store.directory.deletingLastPathComponent().appendingPathComponent("Sources").path+"/")
        previewWork.async {[weak self] in
            let result=Result {try SourcePreviewSafety.inspect(item.path,allowFixture:fixture)}
            DispatchQueue.main.async {guard let self=self,self.inlinePreviewGeneration==token,self.selectedRecords().count==1,self.selectedRecords().first?.path==item.path,self.contentInspectorVisible,self.workspace?.busy != true else{return}
                do {
                    let source=try result.get();guard !source.directory else {throw KonMagicError("Choose a file for inline Quick Look; use the full viewer for folders.")}
                    self.inlinePreviewPath=source.path;self.inlinePreview.isHidden=false;self.selectionImage.isHidden=true;self.inlinePreview.previewItem=URL(fileURLWithPath:source.path) as NSURL
                    self.status.stringValue="Explicit native Quick Look preview · supported types depend on installed preview extensions · original retained"
                } catch {self.status.stringValue=error.localizedDescription}
            }
        }
    }
}
