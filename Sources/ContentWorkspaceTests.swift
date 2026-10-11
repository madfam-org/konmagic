import AppKit
import Darwin

extension KonMagicDelegate {
    func runContentWorkspaceQA() {
        let host=navigation.main!,root=controller.store.directory.deletingLastPathComponent(),original=controller.store.value,prior=controller.knowledge.snapshot()
        host.navigate(.content);let e=controller.explorer!
        window.setContentSize(NSSize(width:1480,height:960));e.folder=nil;e.refresh()
        var checks=0,failures:[String]=[],normalArea:CGFloat=0,pageVersion=0,summaryVersion=0,sourcePath="",expanded:ExplorerNode?,cachedRoot:ExplorerNode?
        func check(_ value:Bool,_ title:String) {checks+=1;print("CONTENT_WORKSPACE_CHECK \(value ? "pass":"FAIL"): "+title);if !value {failures.append(title)}}
        func view(_ n:Int) {e.switchContentView(n);host.view.layoutSubtreeIfNeeded()}
        let steps:[()->Void]=[
            {
                guard let row=e.records.firstIndex(where:{$0.name=="Design brief.txt"}) else {failures.append("fixture source missing");return}
                e.table.selectRowIndexes(IndexSet(integer:row),byExtendingSelection:false);sourcePath=e.records[row].path
                check(e.inlinePreview.previewItem==nil && e.gallery.images.isEmpty,"ordinary discovery requests no content bodies")
                normalArea=e.contentHost.frame.width*e.contentHost.frame.height;e.setContentFocus(true)
            },
            {
                check(host.navigationHeader?.isHidden==true && e.sourcesPanel?.isHidden==true && e.contentInspectorPanel?.isHidden==true,"focus hides page chrome and both optional rails")
                check(abs(e.contentHost.frame.width-e.view.bounds.width)<1,"content fills full window width")
                check(host.slot.frame.height==host.view.bounds.height && e.contentHost.frame.width*e.contentHost.frame.height>normalArea*1.5,"focus reaches window edges and gains useful area")
                e.toggleContentInspector()
            },
            {
                check(abs(e.contentHost.frame.width-(e.view.bounds.width-338))<1,"inspector uses its share without empty space")
                check(e.selectedRecords().first?.path==sourcePath,"focus and inspector retain exact source selection")
                e.toggleContentInspector();e.toggleContentSources()
            },
            {check(abs(e.contentHost.frame.width-(e.view.bounds.width-238))<1,"sources rail toggles independently");e.toggleContentSources();pageVersion=e.generation;summaryVersion=e.summaryGeneration
                if let event=NSEvent.keyEvent(with:.keyDown,location:.zero,modifierFlags:[.command,.option],timestamp:0,windowNumber:self.window.windowNumber,context:nil,characters:"6",charactersIgnoringModifiers:"6",isARepeat:false,keyCode:22) {check(e.view.performKeyEquivalent(with:event) && e.displayedView==5,"view keyboard shortcut selects Gallery")} else {failures.append("keyboard fixture held")}
            },
            {
                check(e.selectedRecords().first?.path==sourcePath && !e.gallery.cards.isEmpty,"gallery retains list source authority")
                check(e.generation==pageVersion && e.summaryGeneration==summaryVersion,"gallery switching performs no page or aggregate query")
                let count=e.gallery.columns;e.density.selectItem(at:0);e.galleryDensityChanged()
                check(e.gallery.columns>count && e.gallery.cards.allSatisfy {$0.frame.height==176},"small gallery cards use more columns and less height")
                e.density.selectItem(at:2);e.galleryDensityChanged();check(e.gallery.imageHeight==160 && e.selectedRecords().first?.path==sourcePath,"large cards expand preview area and retain selection")
                view(3)
            },
            {
                check(e.selectedRecords().isEmpty && !e.assignButton.isEnabled && !e.sourcePreviewToolbar.isEnabled,"semantic map cannot act on hidden source selection")
                view(4);check(e.summaryGeneration==summaryVersion,"map and connections reuse current aggregates")
                e.contentMapViewport.zoom(by:2);check(e.contentMapViewport.magnification==2,"semantic map supports native optical zoom");e.contentFitMap();check(e.contentMapViewport.magnification==1,"map Fit resets magnification")
                e.folder=root.appendingPathComponent("Sources").path;e.refresh();view(1)
            },
            {cachedRoot=e.roots.first;if let n=e.roots.first {expanded=n;e.tree.expandItem(n)}},
            {
                check(expanded?.children?.isEmpty==false,"physical tree lazily loads retained children")
                if let n=expanded {e.tree.selectRowIndexes(IndexSet(integer:e.tree.row(forItem:n)),byExtendingSelection:false)}
            },
            {view(2)},
            {check(e.roots.first?.item==nil && !e.assignButton.isEnabled,"tag hierarchy is a virtual filter model");view(1)},
            {
                check(e.roots.first === cachedRoot && expanded.map {e.tree.isItemExpanded($0)}==true,"tree switching restores cached roots and expansion")
                check(e.selectedRecords().first?.path==expanded?.item?.path,"tree switching restores the real selected folder")
                let generation=e.treeGeneration;view(0);view(1);check(e.treeGeneration==generation,"warm physical-tree return avoids requerying roots")
                host.navigate(.toolkit);check(host.navigationHeader?.isHidden==false,"leaving Content restores page navigation");host.navigate(.content)
                check(host.navigationHeader?.isHidden==true,"returning restores Content focus")
                e.setContentFocus(false);check(host.navigationHeader?.isHidden==false && e.sourcesVisible && e.contentInspectorVisible,"exit focus restores normal workspace")
                e.setContentFocus(true);self.window.setContentSize(NSSize(width:1100,height:740));host.view.layoutSubtreeIfNeeded()
                check(abs(e.contentHost.frame.width-1100)<1,"compact focused window stays edge to edge")
                view(5);e.generation+=1;e.pageLoading=false;e.handoffLoading=false;e.records=(0..<200).map {CatalogItem(id:0,path:"/synthetic/gallery/\($0).txt",name:"\($0).txt",kind:"file",bytes:12,context:"Synthetic recycled gallery")};e.table.reloadData();e.density.selectItem(at:1);e.gallery.rebuild()
                let clip=e.galleryScroll.contentView;clip.scroll(to:NSPoint(x:0,y:max(0,e.gallery.frame.height-clip.bounds.height)));e.galleryScroll.reflectScrolledClipView(clip);e.gallery.arrange()
                check(e.gallery.cards.count<60 && e.gallery.cards.contains {$0.index==199},"gallery recycles cards and reaches all 200 page entries")
                e.table.selectRowIndexes(IndexSet(integer:198),byExtendingSelection:false)
                if let event=NSEvent.keyEvent(with:.keyDown,location:.zero,modifierFlags:[],timestamp:0,windowNumber:self.window.windowNumber,context:nil,characters:"",charactersIgnoringModifiers:"",isARepeat:false,keyCode:124) {e.gallery.keyDown(with:event)}
                check(e.selectedRecords().first?.name=="199.txt","gallery arrows preserve exact recycled-source identity")
                host.navigate(.storage)
                do {let scan=try LensScanner(directory:self.controller.store.directory.appendingPathComponent("Content QA Scans"),cancellation:CatalogueCancellation()).run(root:root.appendingPathComponent("Sources/Projects/Orbit").path);let lens=self.controller.lenses.first!;lens.open(scan);lens.setMapFocus(true)} catch {failures.append("synthetic scan held")}
            },
            {if let lens=self.controller.lenses.first,let file=lens.rows.first(where:{$0.name=="Prototype.png"}) {lens.select(file);sourcePath=lens.store!.path(file,lens.info!);lens.showCatalogue()} else {failures.append("Storage fixture selection missing")}},
            {
                check(host.current?.base == .content && e.contentFocused && e.contentInspectorVisible,"Storage handoff opens focused Content inspector")
                check(e.selectedRecords().first?.path==sourcePath && e.handoffButton.toolTip==sourcePath,"Storage handoff carries exact file beyond list selection")
                check((e.selectedRecords().first?.id ?? 0) > 0 && e.selectedRecords().first?.tags["project"]=="Orbit","handoff enriches scan metadata with retained semantic evidence")
                check(e.inlinePreview.previewItem==nil,"Storage handoff does not request a preview body")
                let old=sourcePath
                do {try self.controller.knowledge.correct(paths:[old],tags:["project":"Reviewed synthetic project"],note:"Synthetic workflow check");e.knowledgeChanged()} catch {failures.append("isolated tag correction held")}
            },
            {
                check(e.selectedRecords().first?.tags["project"]=="Reviewed synthetic project","classification refresh preserves and updates exact handoff")
                if let node=original.nodes.first {e.destination.select(e.destination.itemArray.first {$0.representedObject as? String==node.id});e.destinationChanged()}
                check(e.assignButton.isEnabled && e.proposedPath.toolTip?.hasPrefix(sourcePath+"\n→ ")==true,"chosen destination shows exact handoff placement before assignment")
                e.assignSelected()
            },
            {
                check(host.current?.base == .review && self.controller.review?.selected?.source==sourcePath && self.controller.review?.copy.isEnabled==false,"assignment arrives in unverified Review with copying held")
                host.navigate(.content);view(3);check(e.selectedRecords().isEmpty && !e.assignButton.isEnabled,"maps hold pinned handoff source authority");view(5)
                e.search.stringValue="No synthetic match";e.controlTextDidChange(Notification(name:NSControl.textDidChangeNotification,object:e.search))
                check(e.pageLoading && e.summaryLoading && e.selectedRecords().isEmpty,"new search holds old results and semantic groups immediately")
            },
            {
                check(e.handoff==nil && e.selectedRecords().isEmpty && !e.assignButton.isEnabled,"changed search clears handoff and stale actions")
                if let other=self.navigation.open(.content,from:host) {check(other.workspace.explorer?.contentFocused==true && other.workspace.explorer?.sourcesVisible==false,"secondary Content window inherits workspace layout independently");other.window?.performClose(nil)} else {failures.append("secondary Content window held")}
            }
        ]
        var index=0,deadline=Date().addingTimeInterval(20)
        func finish() {
            if self.controller.knowledge.snapshot().corrections != prior.corrections {try? self.controller.knowledge.undoCorrection()}
            self.controller.plan=nil;try? self.controller.store.change {$0=original}
            check(self.controller.store.value.assignments==original.assignments && self.controller.knowledge.snapshot().corrections==prior.corrections,"isolated draft and classifications restored")
            print("CONTENT_WORKSPACE_QA passed=\(failures.isEmpty); checks=\(checks); sourceOperations=0; implicitBodyRequests=0")
            for f in failures {fputs("Content workspace check failed: "+f+"\n",stderr)}
            if !failures.isEmpty {exit(1)};NSApp.terminate(nil)
        }
        func advance() {
            if e.pageLoading || e.summaryLoading || e.treeLoading || e.handoffLoading {if Date()>deadline {failures.append("bounded workspace readiness timeout");finish();return};DispatchQueue.main.asyncAfter(deadline:.now()+0.1,execute:advance);return}
            if index==steps.count {finish();return}
            steps[index]();index+=1;deadline=Date().addingTimeInterval(20);DispatchQueue.main.asyncAfter(deadline:.now()+0.6,execute:advance)
        }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.6,execute:advance)
    }

    func runContentWorkspaceBenchmark() {
        let host=navigation.main!,original=controller.store.value
        var report=PerformanceReport(mode:"content-workspace")
        window.setContentSize(NSSize(width:1480,height:960));let start=DispatchTime.now().uptimeNanoseconds
        host.navigate(.content);let e=controller.explorer!;e.folder=nil;e.filters=[:];e.search.stringValue="";e.refresh()
        func paint() {host.view.layoutSubtreeIfNeeded();host.view.displayIfNeeded()}
        func measure(_ name:String,_ body:()->Void) {let timer=DispatchTime.now().uptimeNanoseconds;body();paint();report.samples.append(benchmarkSample(name,start:timer,value:Int64(e.records.count)))}
        func finish() {
            report.coverage=["taggedObservations":e.allSummary?.count ?? e.summary?.count ?? 0,"metadataLedgerEntries":e.diskOverview?.count ?? 0]
            report.notes=["Existing real catalogue and metadata ledger read-only, private isolated app state. No thumbnails, original body requests, source hashes, assignment writes or approved copies.","Warm native display-cycle samples; not physical input-to-photon timings. OS caches not flushed; peak RSS is cumulative high-water."]
            do {try SafeFS.writeRecord(report,at:self.controller.store.directory.appendingPathComponent("content-workspace-benchmark.json"));print("CONTENT_WORKSPACE_BENCHMARK completed=true; samples=\(report.samples.count); implicitBodyRequests=0; originalSourceOperations=0; workingDecisionsWritten=0");NSApp.terminate(nil)} catch {exit(1)}
        }
        func wait(_ ready:@escaping ()->Bool,_ next:@escaping ()->Void) {
            if ready() {next();return};if DispatchTime.now().uptimeNanoseconds-start>180_000_000_000 {fputs("Content benchmark readiness timed out.\n",stderr);exit(1)}
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05) {wait(ready,next)}
        }
        wait({!e.pageLoading && !e.summaryLoading}) {
            paint();report.samples.append(benchmarkSample("all_content_ready",start:start,value:Int64(e.records.count)))
            measure("focus_content") {e.setContentFocus(true)}
            if let i=e.records.firstIndex(where:{$0.kind=="file"}) {e.table.selectRowIndexes(IndexSet(integer:i),byExtendingSelection:false)}
            if let node=original.nodes.first {e.destination.select(e.destination.itemArray.first {$0.representedObject as? String==node.id});e.destinationChanged()}
            measure("inspector_and_placement") {e.toggleContentInspector();e.showMetadata()}
            measure("gallery_first_display") {e.switchContentView(5)}
            measure("gallery_small_density") {e.density.selectItem(at:0);e.galleryDensityChanged()}
            measure("gallery_large_density") {e.density.selectItem(at:2);e.galleryDensityChanged()}
            let page=e.generation,summary=e.summaryGeneration
            for _ in 0..<5 {for n in [0,5,3,4,2] {measure("warm_"+["list","folders","tags","map","connections","gallery"][n]) {e.switchContentView(n)}}}
            let treeStart=DispatchTime.now().uptimeNanoseconds;e.switchContentView(1)
            wait({!e.treeLoading}) {
                paint();report.samples.append(benchmarkSample("physical_tree_ready",start:treeStart,value:Int64(e.roots.count)))
                for _ in 0..<5 {for n in [0,1,5,3] {measure("cached_"+["list","folders","tags","map","connections","gallery"][n]) {e.switchContentView(n)}}}
                guard e.generation==page,e.summaryGeneration==summary,self.controller.store.value.assignments==original.assignments else {fputs("Content benchmark changed the slice or draft unexpectedly.\n",stderr);exit(1)}
                finish()
            }
        }
    }
}
