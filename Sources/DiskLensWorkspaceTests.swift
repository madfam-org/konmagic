import AppKit
import Darwin

extension KonMagicDelegate {
    func runStorageWorkspaceQA() {
        let host=navigation.main!,root=controller.store.directory.deletingLastPathComponent()
        host.navigate(.storage);let lens=controller.lenses.first!
        do {let scan=try LensScanner(directory:controller.store.directory.appendingPathComponent("Workspace QA Scans"),cancellation:CatalogueCancellation()).run(root:root.appendingPathComponent("Sources").path);lens.preferences.measure = .logical;lens.measure.selectItem(at:0);lens.open(scan)} catch {fputs("Storage fixture failed\n",stderr);exit(1)}
        var checks=0,failures:[String]=[],normalArea:CGFloat=0,selectionID:Int64=0
        func check(_ condition:Bool,_ name:String) {checks+=1;if !condition {failures.append(name)};print("STORAGE_WORKSPACE_CHECK \(condition ? "pass":"FAIL"): \(name)")}
        let steps:[()->Void]=[
            {normalArea=lens.mapViewport.frame.width*lens.mapViewport.frame.height;check(!lens.canvas.interactionHeld && !lens.canvas.result.tiles.isEmpty,"initial map ready");check(abs(lens.mapViewport.frame.width-(lens.view.bounds.width-48-18-350-32))<1,"normal map uses all width beside inspector");lens.setMapFocus(true)},
            {print("STORAGE_FOCUS_GEOMETRY view=\(lens.view.bounds) map=\(lens.mapViewport.frame) panel=\(lens.mapPanel!.frame) center=\(lens.mapCenter!.frame) content=\(lens.contentStack!.frame)");if let bitmap=host.view.bitmapImageRepForCachingDisplay(in:host.view.bounds) {host.view.cacheDisplay(in:host.view.bounds,to:bitmap);if let data=bitmap.representation(using:.png,properties:[:]) {try? data.write(to:root.appendingPathComponent("focus-qa.png"))}};check(host.navigationHeader?.isHidden==true && lens.rightPanel?.isHidden==true,"focus hides navigation and inspector");check(abs(lens.mapViewport.frame.width-lens.view.bounds.width)<1,"map fills full content width");check(lens.mapViewport.frame.width*lens.mapViewport.frame.height>normalArea*1.5,"focus gains meaningful map area");check(host.slot.frame.height==host.view.bounds.height,"map workspace reaches top and bottom edges");lens.zoomInMap()},
            {check(abs(lens.mapViewport.magnification-1.5)<0.01 && lens.zoomLevel.stringValue=="150%","optical zoom retains hierarchy");check(lens.focusNode?.id==1,"optical zoom does not change physical scope");lens.fitMap()},
            {check(lens.mapViewport.magnification==1,"fit restores full hierarchy");if let n=lens.rows.first(where:{$0.directory}) {lens.select(n);selectionID=n.id};lens.toggleMapInspector()},
            {check(lens.inspectorVisible && lens.rightPanel?.isHidden==false,"inspector returns beside focused map");check(abs(lens.mapViewport.frame.width-(lens.view.bounds.width-350))<1,"focused map uses all width beside inspector");check(lens.selected?.id==selectionID && !lens.selectionPath.stringValue.isEmpty,"inspector retains exact physical selection");lens.zoomSelection()},
            {check(lens.focusNode?.id==selectionID && lens.selected==nil && !lens.assignSourceButton.isEnabled,"folder exploration clears stale source authority");check(lens.mapBackButton.isEnabled && lens.ancestor.numberOfItems>1,"history and ancestry track physical focus");lens.mapBack()},
            {check(lens.focusNode?.id==1 && lens.mapForwardButton.isEnabled,"back restores whole scan");lens.mapForward()},
            {check(lens.focusNode?.id==selectionID,"forward restores folder");lens.goRoot();lens.resolution.selectItem(at:2);lens.depth.selectItem(withTitle:"All (adaptive)");lens.settingsChanged()},
            {check(lens.focusNode?.id==1 && lens.canvas.result.tiles.count<=LensDetail.ultra.tileLimit,"ultra layout bounded at whole scan");let weight=lens.canvas.result.tiles.reduce(Int64(0)) {$0+$1.node.total.bytes};check(weight==lens.info?.totals.bytes,"map weight conserved after navigation");lens.toggleMapInspector();host.navigate(.toolkit)},
            {check(host.navigationHeader?.isHidden==false,"leaving Storage restores page navigation");host.navigate(.storage)},
            {check(host.navigationHeader?.isHidden==true,"returning Storage restores focus mode");lens.setMapFocus(false)},
            {check(host.navigationHeader?.isHidden==false && lens.inspectorVisible,"exit focus restores full workspace");host.window?.setContentSize(NSSize(width:1100,height:740));lens.setMapFocus(true)},
            {print("STORAGE_COMPACT_GEOMETRY view=\(lens.view.bounds) map=\(lens.mapViewport.frame)");check(lens.mapViewport.frame.width>=1099 && lens.mapViewport.frame.width<=1101,"focused map fits compact laptop window without horizontal overflow");lens.fitMap();check(lens.mapViewport.magnification==1,"fit remains available after resize")},
            {do {
                let size=NSSize(width:512,height:288),result=try LensMapBuilder(store:lens.store!,info:lens.info!,preferences:lens.preferences,mask:LensFilter(),cancellation:CatalogueCancellation(),detail:.high).build(focus:lens.focusNode!,bounds:NSRect(origin:.zero,size:size))
                let bitmap=try LensMapImage.bitmap(result,preferences:lens.preferences,size:size,appearance:lens.view.effectiveAppearance)
                let png=bitmap.representation(using:.png,properties:[:])!,tiff=bitmap.representation(using:.tiff,properties:[:])!
                check(NSBitmapImageRep(data:png)?.pixelsWide==512 && NSBitmapImageRep(data:tiff)?.pixelsHigh==288,"map raster export encodes requested dimensions in both formats")
                check(bitmap.colorAt(x:256,y:144) != bitmap.colorAt(x:0,y:0),"raster export contains drawn map regions")
            } catch {check(false,"map raster export")}
            if let other=self.navigation.open(.storage,from:host) {check(other.workspace.lenses.first?.mapFocused==true && other.workspace.lenses.first?.resolution.indexOfSelectedItem==2,"secondary Storage window inherits detail and focus independently");other.window?.performClose(nil)} else {check(false,"secondary map window")}}
        ]
        var index=0
        func advance() {
            if index==steps.count {check(!self.controller.applyButton.isEnabled,"no copy enabled by map navigation");print("STORAGE_WORKSPACE_QA passed=\(failures.isEmpty); checks=\(checks); sourceOperations=0; failures=\(failures.joined(separator:","))");if !failures.isEmpty {exit(1)};NSApp.terminate(nil);return}
            steps[index]();index+=1;DispatchQueue.main.asyncAfter(deadline:.now()+0.65,execute:advance)
        }
        DispatchQueue.main.asyncAfter(deadline:.now()+1,execute:advance)
    }
    func runStorageMapBenchmark() {
        let env=ProcessInfo.processInfo.environment
        guard let path=env["KONMAGIC_BENCHMARK_SCAN"] else {exit(1)}
        let host=navigation.main!;host.navigate(.storage);let lens=controller.lenses.first!
        lens.preferences.depth=999;lens.depth.selectItem(withTitle:"All (adaptive)");lens.open(LensStore(url:URL(fileURLWithPath:path)));lens.setMapFocus(true)
        var report=PerformanceReport(mode:"storage-map"),index=0,polls=0,start:UInt64=0
        report.notes=["Saved whole-machine scan opened read-only. No fresh scan or original file-body request.","Native map layout and AppKit display cycle; filesystem caches not flushed. Peak RSS is cumulative process high-water.","Balanced/detailed/ultra comparison uses the same window and full retained scan root. Optical zoom 4× preserves that root; records outside the viewport remain retained."]
        let cases:[(String,Int,CGFloat)]=[("balanced-fit",0,1),("detailed-fit",1,1),("ultra-fit",2,1),("ultra-4x",2,4)]
        func advance() {
            if index>=cases.count {
                do {try SafeFS.writeRecord(report,at:self.controller.store.directory.appendingPathComponent("storage-map-benchmark.json"));print("STORAGE_MAP_BENCHMARK complete=true; samples=\(report.samples.count); sourceBodiesRead=0; sourceOperations=0");NSApp.terminate(nil)} catch {exit(1)};return
            }
            let (name,detail,zoom)=cases[index];lens.resolution.selectItem(at:detail);lens.mapViewport.magnification=zoom;lens.zoomLevel.stringValue="\(Int(zoom*100))%";start=DispatchTime.now().uptimeNanoseconds;polls=0;lens.render()
            func poll() {
                polls+=1
                if lens.canvas.interactionHeld && polls<1200 {DispatchQueue.main.asyncAfter(deadline:.now()+0.05,execute:poll);return}
                host.view.layoutSubtreeIfNeeded();lens.canvas.displayIfNeeded()
                let held=lens.canvas.interactionHeld || lens.canvas.result.tiles.contains {$0.label.hasPrefix("Map held")}
                let sample=benchmarkSample(name,start:start,value:Int64(lens.canvas.result.tiles.count),status:held ? "held":"ok",detail:"Viewport \(Int(lens.mapViewport.frame.width))×\(Int(lens.mapViewport.frame.height)) points; zoom \(Int(zoom*100))%; \(lens.canvas.result.collapsed) compact groups")
                report.samples.append(sample);report.coverage=["scanEntries":lens.info?.entries ?? 0,"countedFiles":lens.info?.totals.count ?? 0,"exceptions":lens.info?.issues ?? 0]
                print("STORAGE_MAP_SAMPLE name=\(name); milliseconds=\(Int(sample.milliseconds)); tiles=\(sample.value); residentMiB=\(Int(sample.residentBytes/1048576)); status=\(sample.status)")
                index+=1;DispatchQueue.main.asyncAfter(deadline:.now()+0.25,execute:advance)
            }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05,execute:poll)
        }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.8,execute:advance)
    }
}
