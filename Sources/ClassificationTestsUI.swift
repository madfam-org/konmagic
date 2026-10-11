import AppKit
import CryptoKit

extension KonMagicDelegate {
    func runClassificationJourneyQA() {
        let host=navigation.main!,original=controller.store.value,knowledge=controller.knowledge,prior=knowledge.snapshot()
        let input=URL(fileURLWithPath:controller.catalog.path),bytes=try? Data(contentsOf:input)
        var checks=0,failures:[String]=[]
        func check(_ value:Bool,_ label:String) {checks+=1;if !value {failures.append(label)}}
        func finish() {
            if knowledge.snapshot().corrections != prior.corrections {try? knowledge.undoCorrection()}
            self.controller.plan=nil;try? self.controller.store.change {$0=original}
            check(knowledge.snapshot().corrections==prior.corrections,"isolated classifications restored")
            check((try? Data(contentsOf:input))==bytes,"read-only catalogue bytes unchanged")
            print("CLASSIFICATION_JOURNEY_QA passed=\(failures.isEmpty); checks=\(checks); userSourceOperations=0")
            for f in failures {fputs("Classification journey check failed: "+f+"\n",stderr)}
            if !failures.isEmpty {exit(1)};NSApp.terminate(nil)
        }
        func wait(_ ready:@escaping ()->Bool,deadline:Date=Date().addingTimeInterval(15),_ next:@escaping ()->Void) {
            if ready() {next();return}
            if Date()>deadline {failures.append("bounded query did not finish");finish();return}
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05) {wait(ready,deadline:deadline,next)}
        }
        host.navigate(.content);guard let e=controller.explorer else {exit(1)}
        e.folder=nil;e.filters=[:];e.search.stringValue="";e.refresh()
        wait({!e.pageLoading && !e.summaryLoading}) {
            guard let row=e.records.firstIndex(where:{$0.name=="Design brief.txt"}),let node=original.nodes.first else {failures.append("synthetic source/destination missing");finish();return}
            let path=e.records[row].path
            e.table.selectRowIndexes(IndexSet(integer:row),byExtendingSelection:false)
            e.destination.select(e.destination.itemArray.first {$0.representedObject as? String==node.id});e.destinationChanged()
            self.window.setContentSize(NSSize(width:1180,height:740));host.view.layoutSubtreeIfNeeded()
            check([e.destination,e.previewPlacementButton,e.assignButton].allSatisfy {e.view.bounds.contains($0.convert($0.bounds,to:e.view))},"exact preview and assignment controls reachable inside compact page viewport")
            self.window.setContentSize(NSSize(width:1480,height:960));host.view.layoutSubtreeIfNeeded()
            let timer=Timer(timeInterval:0.3,repeats:false) {_ in
                guard let modal=NSApp.modalWindow,let root=modal.contentView else {failures.append("classification editor absent");NSApp.abortModal();return}
                func descendants(_ v:NSView)->[NSView] {v.subviews.flatMap {[$0]+descendants($0)}}
                let children=descendants(root),combos=children.compactMap {$0 as? NSComboBox}
                check(combos.count==5,"five editable semantic suggestion fields")
                guard let owner=combos.first else {NSApp.abortModal();return}
                owner.stringValue="Example family"
                NotificationCenter.default.post(name:NSControl.textDidChangeNotification,object:owner)
                let save=children.compactMap {$0 as? NSButton}.first {$0.title=="Save corrections"}
                check(save?.isEnabled==true,"live edited-field validation")
                modal.orderOut(nil);NSApp.stopModal(withCode:.alertFirstButtonReturn)
            }
            RunLoop.main.add(timer,forMode:.modalPanel);e.correctTags();timer.invalidate()
            check(e.pageLoading && !e.assignButton.isEnabled && e.selectedRecords().isEmpty,"refresh holds stale assignment authority")
            wait({!e.pageLoading && !e.summaryLoading}) {
                check(e.selectedRecords().first?.path==path && e.selectedRecords().first?.tags["owner"]=="Example family","selected source survives classification refresh with current tags")
                check(e.destination.selectedItem?.representedObject as? String==node.id && e.assignButton.isEnabled,"chosen destination survives classification")
                check(e.classificationSummary.stringValue.contains("Your reviewed tags"),"reviewed classification visible in inspector")
                do {let proposal=try PlacementPreview.make(e.selectedRecords(),node:node.id,workspace:self.controller.store.value);check(proposal.pairs.first?.source==path && proposal.pairs.first?.destination.hasSuffix("/Design brief.txt")==true,"exact destination exists before assignment")}
                catch {failures.append(error.localizedDescription)}
                e.assignSelected()
                check(host.current?.base == .review && self.controller.review?.selected?.source==path && self.controller.review?.copy.isEnabled==false,"handoff selects same source and holds unverified copying")
                host.goBack();check(host.current?.base == .content && e.selectedRecords().first?.path==path,"review return retains discovery selection")
                self.controller.setBusy(true);let revision=knowledge.snapshot().tagStamp;e.correctTags()
                check(knowledge.snapshot().tagStamp==revision && !e.correctButton.isEnabled,"active transfer holds classification")
                self.controller.setBusy(false)
                e.search.stringValue="no-match-konmagic-synthetic-query";e.controlTextDidChange(Notification(name:NSControl.textDidChangeNotification,object:e.search))
                check(e.selectedRecords().isEmpty && !e.previewPlacementButton.isEnabled && !e.resultState.isHidden,"new query immediately holds old selection")
                wait({!e.pageLoading}) {
                    check(e.records.isEmpty && !e.resultState.isHidden && e.resultState.title.stringValue=="No matches in this view","empty results explain next action")
                    finish()
                }
            }
        }
    }
}
