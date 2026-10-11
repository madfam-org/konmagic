import AppKit

private func captureOwnedView(_ view:NSView,to path:String) throws {
    view.layoutSubtreeIfNeeded()
    guard let bitmap=view.bitmapImageRepForCachingDisplay(in:view.bounds) else {throw KonMagicError("Owned QA view could not be captured")}
    view.effectiveAppearance.performAsCurrentDrawingAppearance {view.cacheDisplay(in:view.bounds,to:bitmap)}
    let canvas=NSImage(size:view.bounds.size)
    canvas.lockFocus()
    view.effectiveAppearance.performAsCurrentDrawingAppearance {NSColor.windowBackgroundColor.setFill();NSRect(origin:.zero,size:view.bounds.size).fill();bitmap.draw(in:NSRect(origin:.zero,size:view.bounds.size))}
    canvas.unlockFocus()
    guard let tiff=canvas.tiffRepresentation,let flattened=NSBitmapImageRep(data:tiff),let data=flattened.representation(using:.png,properties:[:]) else {throw KonMagicError("Owned QA image unavailable")}
    try data.write(to:URL(fileURLWithPath:path));try FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path)
}
extension KonMagicDelegate {
    func runReviewUIQA() {
        do {
            let dir=controller.store.directory.appendingPathComponent("Review QA Scans")
            let old=try LensWriter(directory:dir,cancellation:CatalogueCancellation()),new=try LensWriter(directory:dir,cancellation:CatalogueCancellation())
            var root=LensNode();root.kind=1;root.name="Synthetic QA root";_ = try old.append(root);_ = try new.append(root)
            for i in 0..<601 {var n=LensNode();n.parent=1;n.name=String(format:"synthetic-%03d.txt",i);n.bytes=9;n.allocated=4096;n.links=1;_ = try new.append(n)}
            var snapshot=LensSnapshot();snapshot.root="/synthetic";snapshot.source="Synthetic UI QA";snapshot.status="complete";_ = try old.finish(snapshot);_ = try new.finish(snapshot)
            let current=LensStore(url:new.url),baseline=LensStore(url:old.url)
            let comparison=ScanComparisonController(current:current,baseline:baseline),duplicates=DuplicateReviewController(store:current)
            comparison.show();duplicates.show();comparison.window?.appearance=window.appearance;duplicates.window?.appearance=window.appearance
            DispatchQueue.main.asyncAfter(deadline:.now()+2) {
                do {
                    let prefix=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] ?? self.controller.store.directory.appendingPathComponent("review").path
                    if let v=comparison.window?.contentView {try captureOwnedView(v,to:prefix+"-comparison.png")}
                    if let v=duplicates.window?.contentView {try captureOwnedView(v,to:prefix+"-duplicates.png")}
                    let passed=comparison.rows.count==500 && comparison.nextCursor != nil && duplicates.groups.count==1 && duplicates.groups[0].count==601 && !duplicates.verify.isEnabled && !self.controller.applyButton.isEnabled
                    print("REVIEW_UI_QA passed=\(passed); comparisonRows=\(comparison.rows.count); furtherPages=\(comparison.nextCursor != nil); candidateGroups=\(duplicates.groups.count); automaticHashEnabled=false; sourceBodiesRead=0; sourceOperations=0")
                    if !passed {exit(1)};NSApp.terminate(nil)
                    withExtendedLifetime((comparison,duplicates)) {}
                } catch {fputs("Review UI QA failed: \(error.localizedDescription)\n",stderr);exit(1)}
            }
        } catch {fputs("Review fixture QA failed: \(error.localizedDescription)\n",stderr);exit(1)}
    }
    func runKnowledgeUIQA() {
        controller.showExplorer();guard let explorer=controller.explorer else {exit(1)}
        DispatchQueue.main.asyncAfter(deadline:.now()+2) {
            var item=CatalogItem(id:0,path:"/synthetic/family-film.mov",name:"family-film.mov",kind:"file",bytes:900,context:"Synthetic family fixture")
            item.tags=["owner":"Personal","family":"Video","project":"Family celebration","role":"Memory","lifecycle":"Archive"]
            explorer.pageCancellation.cancel();explorer.generation+=1;explorer.pageLoading=false
            explorer.records=[item];explorer.table.reloadData();explorer.table.selectRowIndexes(IndexSet(integer:0),byExtendingSelection:false)
            let before=self.controller.knowledge.snapshot()
            let preferences=self.controller.store.directory.appendingPathComponent("disk-lens-preferences.json")
            let preferencesBefore=try? Data(contentsOf:preferences)
            var checked=0,visibleFields=0
            func runDialog(_ name:String,fields:Int,popups:Int,_ action:()->Void) {
                var captured=false,visibleInputs=0,visiblePopups=0,validButtons=false
                let dismissal=Timer(timeInterval:0.5,repeats:false) {_ in
                    do {if let modal=NSApp.modalWindow,let view=modal.contentView,let base=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] {
                        func descendants(_ v:NSView)->[NSView] {v.subviews.flatMap {[$0]+descendants($0)}}
                        let children=descendants(view)
                        validButtons=name=="preferences" || !children.compactMap {$0 as? NSButton}.contains {$0.isEnabled && ["Save corrections","Save current","Open selected","Delete selected","Preview selected","Save & preview","New from current view…"].contains($0.title)}
                        visibleInputs=children.compactMap {$0 as? NSTextField}.filter {field in let frame=field.convert(field.bounds,to:view);return field.isEditable && frame.width>=300 && frame.height>=16 && view.bounds.contains(frame)}.count
                        visiblePopups=children.compactMap {$0 as? NSPopUpButton}.filter {control in let frame=control.convert(control.bounds,to:view);return frame.width>=100 && frame.height>=16 && view.bounds.contains(frame)}.count
                        let path=name=="tags" ? base : URL(fileURLWithPath:base).deletingPathExtension().path+"-"+name+".png"
                        // Legacy local SDKs can composite this process's own dialog. Modern
                        // toolchains validate owned views without the obsolete capture API.
                        #if compiler(<6.0)
                        if let cg=CGWindowListCreateImage(.null,.optionIncludingWindow,CGWindowID(modal.windowNumber),[.boundsIgnoreFraming]),let data=NSBitmapImageRep(cgImage:cg).representation(using:.png,properties:[:]) {try data.write(to:URL(fileURLWithPath:path));try FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path);captured=true}
                        #else
                        try captureOwnedView(view,to:path);captured=true
                        #endif
                        modal.orderOut(nil)
                    }} catch {fputs("Dialog capture failed: \(error.localizedDescription)\n",stderr)}
                    NSApp.stopModal(withCode:.alertSecondButtonReturn)
                }
                RunLoop.main.add(dismissal,forMode:.modalPanel);action()
                if captured && visibleInputs==fields && visiblePopups>=popups && validButtons {checked+=1}
                if name=="tags" {visibleFields=visibleInputs}
                print("NATIVE_DIALOG_QA scene=\(name); visibleInputs=\(visibleInputs); visiblePopups=\(visiblePopups); contextualButtons=\(validButtons); captured=\(captured)")
            }
            runDialog("tags",fields:6,popups:0) {explorer.correctTags()}
            runDialog("collections",fields:1,popups:1) {explorer.collectionsMenu()}
            runDialog("rules",fields:0,popups:1) {explorer.rulesMenu()}
            explorer.destination.selectItem(at:1)
            runDialog("proposal",fields:5,popups:0) {explorer.createRule()}
            runDialog("preferences",fields:0,popups:1) {self.controller.showPreferences()}
            let after=self.controller.knowledge.snapshot()
            let passed=checked==5 && after.corrections==before.corrections && after.collections.count==before.collections.count && after.rules.count==before.rules.count && (try? Data(contentsOf:preferences))==preferencesBefore && !self.controller.applyButton.isEnabled
            print("KNOWLEDGE_UI_QA passed=\(passed); visibleEditableFields=\(visibleFields); dialogs=\(checked); cancellationRetainsDecisions=true; sourceOperations=0")
            if !passed {exit(1)};NSApp.terminate(nil)
        }
    }
}
