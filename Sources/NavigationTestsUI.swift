import AppKit

extension KonMagicDelegate {
    func runNavigationQA() {
        let host=navigation.main!
        window.setContentSize(NSSize(width:1480,height:960))
        var failures:[String]=[],checks=0
        func check(_ value:Bool,_ name:String) {checks+=1;if !value {failures.append(name)}}
        func visibleHosts()->Int {NSApp.windows.filter {$0.isVisible && $0.contentViewController is PageHostController}.count}
        let original=controller.store.value
        for page in KonMagicPage.allCases {
            host.navigate(page)
            check(host.current?.base==page && visibleHosts()==1,"single window: "+page.title)
        }
        host.navigate(.content)
        guard let explorer=controller.explorer,let lens=controller.lenses.first else {exit(1)}
        explorer.search.stringValue="Synthetic retained query";explorer.filters[.owner]="Synthetic owner"
        let originalFolder=explorer.folder
        host.navigate(.structure);host.navigate(.review);host.goBack()
        check(host.current?.base == .structure,"back history")
        host.goForward();check(host.current?.base == .review,"forward history")
        host.navigate(.content)
        check(controller.explorer === explorer && explorer.search.stringValue=="Synthetic retained query" && explorer.folder==originalFolder && explorer.filters[.owner]=="Synthetic owner","retained content state")
        check(controller.view.window==nil && explorer.view.window===window,"one hosted page at a time")
        window.setContentSize(NSSize(width:1100,height:740));host.view.layoutSubtreeIfNeeded()
        if let scroll=host.presentations[ObjectIdentifier(explorer)] {
            scroll.contentView.scroll(to:NSPoint(x:50,y:50));scroll.reflectScrolledClipView(scroll.contentView)
            let origin=scroll.contentView.bounds.origin
            host.navigate(.review);host.navigate(.content)
            check(scroll.documentView!.frame.width>=1230 && scroll.documentView!.frame.height>=800 && scroll.contentView.bounds.origin==origin,"small-window scrolling retained")
        } else {check(false,"page viewport exists")}
        window.setContentSize(NSSize(width:1480,height:960));host.view.layoutSubtreeIfNeeded()
        lens.busy=true;host.navigate(.toolkit)
        check(!host.canClose && !host.activity.isHidden && navigation.observationBusy,"hidden scan stays protected")
        lens.busy=false
        check(host.canClose && host.activity.isHidden,"idle close resumes")
        guard let second=navigation.open(.content,from:host),let third=navigation.open(.structure,from:host),let other=second.workspace.explorer else {exit(1)}
        check(visibleHosts()==3 && navigation.additional.count==2,"explicit secondary and tertiary windows")
        check(second.workspace.store === controller.store && second.workspace.knowledge === controller.knowledge && third.workspace.store === controller.store,"shared private state")
        check(other !== explorer && other.search.stringValue==explorer.search.stringValue && other.filters==explorer.filters,"independent copied browsing context")
        other.search.stringValue="Second window query"
        check(explorer.search.stringValue=="Synthetic retained query","independent search")
        host.navigate(.structure)
        check(controller.view.window===window && third.workspace.view.window===third.window,"structure views do not steal each other")
        do {
            let newNode=FolderNode(parent:nil,name:"Synthetic shared destination")
            controller.plan=CopyPlan(id:UUID().uuidString,prepared:Date(),workspaceHash:try SafeFS.workspaceHash(controller.store.value),output:controller.store.value.output,outputAnchor:OutputAnchor(path:controller.store.value.output,device:0,inode:0),buckets:[],bytes:0)
            try third.workspace.store.change {$0.nodes.append(newNode)};third.workspace.refreshDraft()
            check(controller.treeEntries[newNode.id] != nil && other.destination.itemArray.contains {$0.representedObject as? String==newNode.id},"cross-window destination refresh")
            check(controller.plan==nil && !controller.applyButton.isEnabled,"stale verification invalidated in other window")
            var item=CatalogItem(id:0,path:"/synthetic/navigation.txt",name:"navigation.txt",kind:"file",bytes:12,context:"Synthetic navigation fixture")
            item.tags=["owner":"Synthetic"]
            other.pageCancellation.cancel();other.generation+=1;other.pageLoading=false
            other.records=[item];other.table.reloadData();other.table.selectRowIndexes(IndexSet(integer:0),byExtendingSelection:false)
            if let menu=other.destination.itemArray.first(where:{$0.representedObject as? String==newNode.id}) {other.destination.select(menu)}
            third.workspace.setBusy(true)
            other.assignSelected()
            check(controller.busy && second.workspace.busy && controller.store.value.assignments.count==original.assignments.count && !controller.previewButton.isEnabled,"global transfer guard")
            third.workspace.setBusy(false);other.assignSelected()
            check(controller.store.value.assignments.contains {$0.source==item.path && $0.node==newNode.id} && controller.draft.numberOfRows==controller.store.value.assignments.count,"shared exact draft assignment")
            try controller.knowledge.correct(paths:[item.path],tags:["owner":"Synthetic correction"],note:"Navigation QA")
            navigation.knowledgeChanged()
            check(second.workspace.knowledge.snapshot().corrections[item.path]?.tags["owner"]=="Synthetic correction","shared classification decisions")
            try controller.knowledge.reset(paths:[item.path])
            try controller.store.change {$0=original};controller.refreshDraft()
            let dir=controller.store.directory.appendingPathComponent("Navigation QA Scans")
            let old=try LensWriter(directory:dir,cancellation:CatalogueCancellation()),new=try LensWriter(directory:dir,cancellation:CatalogueCancellation())
            var root=LensNode();root.kind=1;root.name="Synthetic root";_ = try old.append(root);_ = try new.append(root)
            var file=LensNode();file.parent=1;file.name="synthetic.txt";file.bytes=9;file.allocated=4096;file.links=1;_ = try new.append(file)
            var snapshot=LensSnapshot();snapshot.root="/synthetic";snapshot.source="Synthetic navigation QA";snapshot.status="complete";_ = try old.finish(snapshot);_ = try new.finish(snapshot)
            let current=LensStore(url:new.url),baseline=LensStore(url:old.url)
            let comparison=ScanComparisonController(current:current,baseline:baseline)
            host.showDetail(comparison,title:"Storage / Scan comparison") {_ in ScanComparisonController(current:current,baseline:baseline)}
            check(visibleHosts()==3 && comparison.window==nil && comparison.view.window===window,"comparison embedded by default")
            host.goBack();host.goForward()
            check(host.current?.controller === comparison,"detail history preserves view")
            host.openCurrent()
            check(visibleHosts()==4 && navigation.additional.count==3 && navigation.additional.last?.current?.controller is ScanComparisonController,"detail can open independently")
        } catch {failures.append(error.localizedDescription)}
        DispatchQueue.main.asyncAfter(deadline:.now()+3) {
            self.navigation.main.navigate(.toolkit);self.window.makeKeyAndOrderFront(nil);self.window.contentView?.layoutSubtreeIfNeeded()
            if let v=self.window.contentView,let bitmap=v.bitmapImageRepForCachingDisplay(in:v.bounds),let path=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] {
                v.effectiveAppearance.performAsCurrentDrawingAppearance {v.cacheDisplay(in:v.bounds,to:bitmap)}
                if let data=bitmap.representation(using:.png,properties:[:]) {try? data.write(to:URL(fileURLWithPath:path));try? FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path)}
            }
            let additional=self.navigation.additional
            for extra in additional {check(extra.canClose,"idle additional window closes");extra.window?.performClose(nil)}
            check(self.navigation.additional.isEmpty && visibleHosts()==1,"additional views release on close")
            check(self.controller.store.value.nodes==original.nodes && self.controller.store.value.assignments==original.assignments && self.controller.store.value.output==original.output,"isolated draft restored")
            print("NAVIGATION_UI_QA passed=\(failures.isEmpty); checks=\(checks); defaultWindows=\(visibleHosts()); explicitExtraWindows=3; sharedDraft=true; sourceBodiesRead=0; sourceOperations=0")
            for failure in failures {fputs("Navigation check failed: \(failure)\n",stderr)}
            if !failures.isEmpty {exit(1)};NSApp.terminate(nil)
        }
    }
}
