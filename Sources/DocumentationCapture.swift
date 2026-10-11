import AppKit
import Darwin

// An explicit QA mode, restricted to a generated private temporary fixture.
// Public screenshots never come from an ordinary workspace or the live Atlas.
func validateDocumentationFixture(_ state:URL) throws {
    let root=state.deletingLastPathComponent()
    guard root.path.hasPrefix("/private/tmp/konmagic-documentation-"),state.lastPathComponent=="State" else {throw KonMagicError("Documentation capture requires a generated synthetic temporary fixture.")}
    let fd=try SafeFS.openDirectory(state.path);defer {close(fd)}
    let marker=openat(fd,"documentation-fixture",O_RDONLY|O_NOFOLLOW);guard marker>=0 else {throw KonMagicError("Missing synthetic documentation marker.")};defer {close(marker)}
    var s=stat();guard fstat(marker,&s)==0,s.st_uid==getuid(),SafeFS.isFile(s),s.st_size==44 else {throw KonMagicError("Invalid synthetic documentation marker.")}
    var bytes=[UInt8](repeating:0,count:44);guard read(marker,&bytes,44)==44,String(bytes:bytes,encoding:.utf8)=="KonMagic synthetic documentation fixture v1\n" else {throw KonMagicError("Documentation fixture marker differs.")}
    let w=try JSONDecoder().decode(Workspace.self,from:Data(contentsOf:state.appendingPathComponent("workspace.json")))
    guard w.cataloguePath==state.appendingPathComponent("catalog.sqlite3").path,w.output==root.appendingPathComponent("Organized").path,w.assignments.allSatisfy({$0.source.hasPrefix(root.appendingPathComponent("Sources").path+"/")}) else {throw KonMagicError("Documentation workspace is not isolated.")}
}

extension KonMagicDelegate {
    func runDocumentationCapture() {
        let host=navigation.main!,root=controller.store.directory.deletingLastPathComponent()
        let images=root.appendingPathComponent(ProcessInfo.processInfo.environment["KONMAGIC_QA_APPEARANCE"]=="dark" ? "Dark screenshots":"Light screenshots")
        do {try FileManager.default.createDirectory(at:images,withIntermediateDirectories:false,attributes:[.posixPermissions:0o700])} catch {fputs("Documentation output must be a new private directory.\n",stderr);exit(1)}
        window.setContentSize(NSSize(width:1480,height:960))
        var count=0,viewerChecks=0
        func checkViewer(_ condition:Bool,_ message:String) {guard condition else {fputs("Source viewer check failed: \(message)\n",stderr);exit(1)};viewerChecks+=1}
        func capture(_ name:String,_ v:NSView?=nil) {
            guard let view=v ?? self.window.contentView,let ownedWindow=view.window else {exit(1)};view.layoutSubtreeIfNeeded();view.displayIfNeeded();ownedWindow.display();ownedWindow.flush()
            // Composite exactly this process's synthetic window. View caching omits
            // Quick Look's remote layer and some native alert text/materials.
            let data:Data
            #if compiler(<6.0)
            guard let cg=CGWindowListCreateImage(.null,.optionIncludingWindow,CGWindowID(ownedWindow.windowNumber),[.boundsIgnoreFraming]),let png=NSBitmapImageRep(cgImage:cg).representation(using:.png,properties:[:]) else {fputs("Owned synthetic window capture unavailable.\n",stderr);exit(1)}
            data=png
            #else
            let file=images.appendingPathComponent(name+".png"),process=Process()
            process.executableURL=URL(fileURLWithPath:"/usr/sbin/screencapture");process.arguments=["-x","-o","-l",String(ownedWindow.windowNumber),file.path]
            do {try process.run();process.waitUntilExit();guard process.terminationStatus==0 else {exit(1)};data=try Data(contentsOf:file)} catch {exit(1)}
            #endif
            do {try data.write(to:images.appendingPathComponent(name+".png"));count+=1;print("DOCUMENTATION_SCREENSHOT "+name)} catch {exit(1)}
        }
        func dialog(_ name:String,_ body:()->Void) {
            let timer=Timer(timeInterval:0.6,repeats:false) {_ in
                guard let modal=NSApp.modalWindow,let view=modal.contentView else {fputs("Expected owned modal: \(name)\n",stderr);exit(1)}
                capture(name,view);modal.orderOut(nil);NSApp.abortModal()
            };RunLoop.main.add(timer,forMode:.modalPanel);body();timer.invalidate()
        }
        var tasks:[(String,()->Void)]=[]
        tasks.append(("toolkit",{host.navigate(.toolkit)}))
        tasks.append(("content-list",{host.navigate(.content);let e=self.controller.explorer!;e.folder=nil;e.filters=[:];e.refresh()}))
        tasks.append(("content-inspector",{let e=self.controller.explorer!;if let i=e.records.firstIndex(where:{$0.name=="Design brief.txt"}) {e.table.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false);e.showMetadata()}}))
        tasks.append(("content-reading",{self.controller.explorer!.showReading()}))
        tasks.append(("content-folder-tree",{let e=self.controller.explorer!;e.folder=root.appendingPathComponent("Sources").path;e.mode.selectedSegment=1;e.changeVisualization();e.tree.expandItem(nil,expandChildren:true)}))
        tasks.append(("content-tag-tree",{let e=self.controller.explorer!;e.folder=nil;e.refresh();e.mode.selectedSegment=2;e.changeVisualization();e.tree.expandItem(nil,expandChildren:true)}))
        tasks.append(("content-treemap",{let e=self.controller.explorer!;e.mode.selectedSegment=3;e.changeVisualization()}))
        tasks.append(("content-connections",{let e=self.controller.explorer!;e.mode.selectedSegment=4;e.changeVisualization()}))
        tasks.append(("content-filters",{let e=self.controller.explorer!;e.mode.selectedSegment=0;e.filters=[.owner:"Personal",.family:"Video"];e.changeVisualization();e.refresh()}))
        tasks.append(("content-gallery",{let e=self.controller.explorer!;e.folder=root.appendingPathComponent("Sources/Projects/Orbit").path;e.filters=[:];e.refresh();e.mode.selectedSegment=5;e.changeVisualization()}))
        tasks.append(("content-gallery-thumbnails",{let e=self.controller.explorer!;e.loadGalleryThumbnails();if let i=e.records.firstIndex(where:{$0.name=="Prototype.png"}) {e.table.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false);e.showMetadata()}}))
        tasks.append(("recorded-disk",{let e=self.controller.explorer!;e.dataset.selectItem(at:1);e.folder=root.appendingPathComponent("Sources").path;e.changeDataset()}))
        tasks.append(("structure",{host.navigate(.structure);self.controller.outline.expandItem(nil,expandChildren:true);if let node=self.controller.store.value.nodes.first(where:{$0.name=="Orbit"}) {self.controller.selectDestination(node.id)};self.controller.navigate(root.appendingPathComponent("Sources/Projects/Orbit").path)}))
        tasks.append(("review-unverified",{
            do {guard let n=self.controller.store.value.nodes.first(where:{$0.name=="Research"}) else {exit(1)};try self.controller.store.change {try $0.assign([root.appendingPathComponent("Sources/Research/Reading copy A.txt").path],to:n.id)};self.controller.refreshDraft();host.navigate(.review)} catch {exit(1)}
        }))
        tasks.append(("review-verified",{
            do {self.controller.plan=try SafeFS.preview(self.controller.store.value,allowFixture:true);self.controller.refreshDraft()} catch {fputs("Synthetic preview held: \(error.localizedDescription)\n",stderr);exit(1)}
        }))
        tasks.append(("storage",{
            host.navigate(.storage)
            do {let scanner=try LensScanner(directory:self.controller.store.directory.appendingPathComponent("Documentation Scans"),cancellation:CatalogueCancellation());let scan=try scanner.run(root:root.appendingPathComponent("Sources").path);let lens=self.controller.lenses.first!;lens.preferences.measure = .logical;lens.measure.selectItem(at:0);lens.open(scan)} catch {exit(1)}
        }))
        tasks.append(("storage-options",{let lens=self.controller.lenses.first!;lens.toggleViewOptions();if let node=lens.rows.first {lens.select(node)}}))
        tasks.append(("storage-focused",{let lens=self.controller.lenses.first!;if let node=lens.rows.first(where:{$0.name=="Personal"}) {lens.navigate(node.id);checkViewer(lens.selected==nil && lens.canvas.selected==0 && lens.selectionTitle.stringValue=="Choose a source" && lens.selectionPath.stringValue.isEmpty,"folder navigation clears stale source presentation")}}))
        tasks.append(("content-restored",{host.navigate(.content);let e=self.controller.explorer!;e.dataset.selectItem(at:0);e.folder=nil;e.filters=[:];e.mode.selectedSegment=0;e.changeDataset();e.updateMode()}))
        tasks.append(("folder-viewer",{self.controller.showSourcePreview(root.appendingPathComponent("Sources/Projects/Orbit").path,allowFixture:true)}))
        tasks.append(("folder-gallery",{if let c=host.current?.controller as? SourcePreviewController {c.mode.selectedSegment=1;c.changePresentation()}}))
        tasks.append(("folder-thumbnails",{if let c=host.current?.controller as? SourcePreviewController {c.loadThumbnails()}}))
        tasks.append(("file-viewer",{self.controller.showSourcePreview(root.appendingPathComponent("Sources/Projects/Orbit/Design brief.txt").path,allowFixture:true)}))
        tasks.append(("image-viewer",{self.controller.showSourcePreview(root.appendingPathComponent("Sources/Projects/Orbit/Prototype.png").path,allowFixture:true)}))
        var index=0
        func advance() {
            if index>=tasks.count {
                do {checkViewer(try Data(contentsOf:images.appendingPathComponent("structure.png")) != Data(contentsOf:images.appendingPathComponent("recorded-disk.png")),"distinct pages must not publish the same stale compositor frame")} catch {exit(1)}
                host.navigate(.review)
                do {self.controller.plan=try SafeFS.preview(self.controller.store.value,allowFixture:true);self.controller.refreshDraft()} catch {exit(1)}
                dialog("copy-confirmation",{self.controller.applyCopy()})
                host.navigate(.storage);if let lens=self.controller.lenses.first {dialog("scan-filters",{lens.scanFilters()});dialog("mask-editor",{lens.editMask()});dialog("scan-notes",{lens.notes()})}
                host.navigate(.structure);dialog("new-folder",{self.controller.newFolder()})
                host.navigate(.content);let e=self.controller.explorer!
                if let i=e.records.firstIndex(where:{$0.name=="Design brief.txt"}) {e.table.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false)}
                dialog("tag-corrections",{e.correctTags()});dialog("collections",{e.collectionsMenu()})
                if let id=self.controller.store.value.nodes.first(where:{$0.name=="Research"})?.id {e.destination.select(e.destination.itemArray.first(where:{$0.representedObject as? String==id}));e.destinationChanged()}
                dialog("rules",{e.rulesMenu()});dialog("create-rule",{e.createRule()});dialog("preferences",{self.controller.showPreferences()})
                for page in 0..<8 {try? self.controller.store.change {$0.guidePage=page};dialog("welcome-\(page+1)",{self.controller.showGuide()})}
                for p in KonMagicPage.allCases {let url=KonMagicDocumentation.base.appendingPathComponent(KonMagicDocumentation.route(p));guard url.host=="madfam-org.github.io",url.query==nil else {exit(1)}}
                print("SOURCE_PREVIEW_UI_QA passed=true; checks=\(viewerChecks); syntheticContentOnly=true; userSourceOperations=0")
                print("DOCUMENTATION_CAPTURE passed=true; screenshots=\(count); personalCatalogueReads=0; userSourceOperations=0; copiedFiles=0; publicHelpRoutes=5")
                NSApp.terminate(nil);return
            }
            let task=tasks[index];index+=1;task.1();self.window.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)
            DispatchQueue.main.asyncAfter(deadline:.now()+1.2) {
                let isTree=task.0=="content-folder-tree" || task.0=="content-tag-tree"
                if isTree,let e=self.controller.explorer {for node in e.roots {e.tree.expandItem(node,expandChildren:true)}}
                if let c=host.current?.controller as? SourcePreviewController {
                    if task.0=="folder-viewer" {checkViewer(c.items.count==6 && c.preview.previewItem==nil,"folder metadata without body request")}
                    if task.0=="folder-gallery" {checkViewer(c.mode.selectedSegment==1 && c.gallery.views.count==2,"bounded gallery rows")}
                    if task.0=="folder-thumbnails" {checkViewer(c.thumbnailCandidates.count<=24 && c.thumbnailInFlight<=3 && c.thumbnailImages.count<=24,"bounded native thumbnail requests")}
                    if task.0=="image-viewer",let observed=c.observed {checkViewer(c.preview.previewItem != nil,"explicit image preview");c.clearContents();checkViewer(c.preview.previewItem==nil && c.thumbnailRequests.isEmpty,"content clear releases representations");c.requestContent(observed)}
                }
                if task.0=="content-gallery",let e=self.controller.explorer {checkViewer(e.gallery.images.isEmpty && e.gallery.requests.isEmpty && e.gallery.cards.count==6,"gallery browsing requests no original bodies")}
                DispatchQueue.main.asyncAfter(deadline:.now()+(isTree ? 0.8:task.0=="image-viewer" || task.0=="folder-thumbnails" || task.0=="content-gallery-thumbnails" ? 2.0:0.0)) {
                    if task.0=="image-viewer",let c=host.current?.controller as? SourcePreviewController {checkViewer(c.preview.previewItem != nil && c.preview.frame.height>=330,"preview reopens after clear")}
                    if task.0=="content-gallery-thumbnails",let e=self.controller.explorer {checkViewer(e.gallery.candidates.count<=24 && e.gallery.inFlight<=3 && e.gallery.images.count<=24 && e.selectedRecords().first?.name=="Prototype.png","bounded content thumbnails and exact gallery selection")}
                    capture(task.0);advance()
                }
            }
        }
        advance()
    }
}
