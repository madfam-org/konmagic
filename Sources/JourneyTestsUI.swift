import AppKit
import Darwin

extension KonMagicDelegate {
    func runJourneyQA() {
        let host=navigation.main!,original=controller.store.value,window=self.window!
        window.setContentSize(NSSize(width:1480,height:960))
        host.navigate(.content)
        DispatchQueue.main.asyncAfter(deadline:.now()+2) {
            var failures:[String]=[],checks=0,transitions:[Double]=[]
            func check(_ value:Bool,_ name:String) {checks+=1;if !value {failures.append(name)}}
            func go(_ page:KonMagicPage) {let start=Date();host.navigate(page);transitions.append(Date().timeIntervalSince(start)*1000)}
            guard let explorer=self.controller.explorer else {exit(1)}
            do {
                go(.review)
                guard let review=self.controller.review else {exit(1)}
                check(host.current?.controller === review && review !== self.controller,"dedicated review page")
                self.controller.status.stringValue="6 entries · current folder metadata";review.refreshStatus()
                check(!review.message.stringValue.contains("current folder metadata"),"review status excludes unrelated browsing feedback")
                check(!review.copy.isEnabled && !review.verify.isEnabled && review.inspector.string.contains("START WITH"),"empty review explains next step")
                let node=FolderNode(parent:nil,name:"Synthetic thoughtful collection")
                try self.controller.store.change {$0.nodes.append(node)};self.controller.refreshDraft()
                go(.content)
                explorer.pageCancellation.cancel();explorer.generation+=1
                let item=CatalogItem(id:0,path:"/synthetic/family/celebration.mov",name:"celebration.mov",kind:"file",bytes:42,context:"Synthetic family collection")
                explorer.mode.selectedSegment=0;explorer.updateMode();explorer.records=[item];explorer.table.reloadData();explorer.table.selectRowIndexes(IndexSet(integer:0),byExtendingSelection:false)
                explorer.mode.selectedSegment=5;explorer.updateMode()
                check(explorer.selectedRecords().first?.path==item.path && explorer.gallery.cards.count==1,"gallery shares exact list selection authority")
                check(explorer.gallery.images.isEmpty && explorer.gallery.requests.isEmpty,"gallery presentation does not request source bodies")
                explorer.mode.selectedSegment=3;explorer.updateMode();check(explorer.selectedRecords().isEmpty && !explorer.assignButton.isEnabled,"gallery authority held on semantic maps")
                explorer.mode.selectedSegment=0;explorer.updateMode()
                explorer.destination.select(explorer.destination.itemArray.first {$0.representedObject as? String==node.id});explorer.destinationChanged()
                let proposed=try self.controller.store.value.destination(Assignment(source:item.path,node:node.id,outputName:item.name))
                check(explorer.proposedPath.toolTip==item.path+"\n→ "+proposed && explorer.assignButton.isEnabled,"placement visible before assignment")
                explorer.editDestinations()
                check(host.current?.base == .structure && self.controller.selectedNode?.id==node.id,"destination follows folder editing")
                host.goBack();check(host.current?.base == .content && explorer.selectedRecords().first?.path==item.path,"source selection survives page return")
                explorer.assignSelected()
                check(host.current?.base == .review && review.selected?.source==item.path,"assignment opens its exact review")
                check(review.source.stringValue==item.path && review.destination.stringValue==proposed && !review.copy.isEnabled,"unverified exact pair never enables copying")
                check(review.verify.isEnabled && review.inspector.string.contains("UNVERIFIED"),"unverified folder contents explicit")
                review.search.stringValue="No synthetic match";review.refresh()
                check(review.assignments.isEmpty && !review.rename.isEnabled && review.destination.stringValue.contains("matches"),"filtered empty state")
                review.search.stringValue="";review.refresh()
                guard let assignment=review.selected else {throw KonMagicError("Missing synthetic assignment")}
                try self.controller.store.change {w in if let i=w.assignments.firstIndex(where:{$0.id==assignment.id}) {w.assignments[i].outputName="chosen-name.mov"}}
                self.controller.refreshDraft();go(.content);explorer.updateSelectionControls()
                check(explorer.proposedPath.toolTip?.contains("chosen-name.mov")==true,"placement retains chosen output name")
                explorer.filters=[.owner:"Synthetic owner"];explorer.folder="/synthetic";explorer.search.stringValue="Synthetic query";explorer.mode.selectedSegment=3;explorer.updateMode()
                check(!explorer.assignButton.isEnabled && !explorer.revealButton.isEnabled,"hidden selections cannot act from maps")
                explorer.drillInto([.family:"Synthetic family"])
                check(explorer.mode.selectedSegment==0 && explorer.filters[.family]=="Synthetic family" && !explorer.backToMap.isHidden,"map drill has return route")
                explorer.restoreDrillContext()
                check(explorer.mode.selectedSegment==3 && explorer.filters==[.owner:"Synthetic owner"] && explorer.search.stringValue=="Synthetic query" && explorer.folder=="/synthetic","map return restores exact scope and query")
                explorer.filters=[.owner:"Synthetic owner",.family:"Synthetic family"];explorer.updateFilterChips()
                check(explorer.filterChips.arrangedSubviews.count==2 && !explorer.chipScroll.isHidden,"individual active filters visible")
                if let chip=explorer.filterChips.arrangedSubviews.first as? NSButton {explorer.removeFilter(chip)}
                check(explorer.filters.count==1,"removing one filter retains another")
                go(.structure);self.controller.selectDestination(node.id)
                check(self.controller.renameFolderButton.isEnabled && !self.controller.removeFolderButton.isEnabled,"assigned destination removal held")
                go(.review)
                let fixture=self.controller.store.directory.appendingPathComponent("synthetic-ui-identity.txt");try Data("Synthetic UI fixture".utf8).write(to:fixture)
                var identity=stat();guard lstat(fixture.path,&identity)==0 else {throw KonMagicError("Cannot inspect UI fixture")}
                let a=self.controller.store.value.assignments.first {$0.id==assignment.id}!
                let bucket=BucketPlan(assignment:a,destination:try self.controller.store.value.destination(a),records:(0..<401).map {FileRecord(relative:"synthetic-\($0).txt",directory:false,identity:Identity(identity),hash:String(repeating:"a",count:64))},bytes:401)
                self.controller.plan=CopyPlan(id:UUID().uuidString,prepared:Date(),workspaceHash:try SafeFS.workspaceHash(self.controller.store.value),output:self.controller.store.value.output,outputAnchor:OutputAnchor(path:self.controller.store.value.output,device:0,inode:0),buckets:[bucket],bytes:401)
                self.controller.refreshDraft()
                check(review.inspector.string.contains("1–200") && review.next.isEnabled && !review.previous.isEnabled,"verified inventory bounded at 200")
                check(review.manifestTable.numberOfRows==200 && review.manifestRecords.first?.hash==String(repeating:"a",count:64),"visible manifest preserves full verification proof")
                let selectedAssignment=review.selected?.id
                review.manifestTable.selectRowIndexes(IndexSet(integer:1),byExtendingSelection:false)
                check(review.selected?.id==selectedAssignment,"manifest row selection cannot change assignment authority")
                review.nextRecords();review.nextRecords()
                check(review.inspector.string.contains("401–401") && !review.next.isEnabled && review.previous.isEnabled,"last inventory page exact")
                check(review.inspector.string.contains(bucket.destination+"/synthetic-400.txt") && review.inspector.string.contains("SHA-256"),"verified child targets and hashes shown")
                review.previousRecords();review.previousRecords()
                self.controller.setBusy(true);check(!review.copy.isEnabled && !review.verify.isEnabled && !review.remove.isEnabled,"running transfer holds review actions");self.controller.setBusy(false)
                window.setContentSize(NSSize(width:1100,height:740));host.view.layoutSubtreeIfNeeded()
                check(review.table.frame.width>350 && review.source.isSelectable && review.destination.isSelectable && review.inspector.isSelectable,"compact review readable and paths selectable")
                window.setContentSize(NSSize(width:1480,height:960));host.view.layoutSubtreeIfNeeded()
                check(review.view.window===self.window && self.navigation.additional.isEmpty,"journey stays in one window")
                let page=ProcessInfo.processInfo.environment["KONMAGIC_QA_PAGE"] ?? "review"
                if page=="structure" {go(.structure)} else if page=="content" {go(.content);explorer.mode.selectedSegment=0;explorer.updateMode();explorer.search.stringValue="";explorer.filters=[:];explorer.folder=nil;explorer.refresh()} else if page=="toolkit" {go(.toolkit)}
            } catch {failures.append(error.localizedDescription)}
            DispatchQueue.main.asyncAfter(deadline:.now()+3) {
                guard let v=self.window.contentView else {exit(1)};v.layoutSubtreeIfNeeded()
                if let bitmap=v.bitmapImageRepForCachingDisplay(in:v.bounds),let path=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] {v.effectiveAppearance.performAsCurrentDrawingAppearance {v.cacheDisplay(in:v.bounds,to:bitmap)};if let data=bitmap.representation(using:.png,properties:[:]) {try? data.write(to:URL(fileURLWithPath:path));try? FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path)}}
                self.controller.plan=nil;try? self.controller.store.change {$0=original};self.controller.refreshDraft()
                check(self.controller.store.value.nodes==original.nodes && self.controller.store.value.assignments==original.assignments && self.controller.store.value.output==original.output,"isolated draft restored")
                print("JOURNEY_UI_QA passed=\(failures.isEmpty); checks=\(checks); maxTransitionMS=\(Int(transitions.max() ?? 0)); inventoryPageLimit=200; sourceOperations=0")
                for failure in failures {fputs("Journey check failed: \(failure)\n",stderr)}
                if !failures.isEmpty {exit(1)};NSApp.terminate(nil)
            }
        }
    }
}
