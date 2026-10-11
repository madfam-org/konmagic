# Source declaration index

Generated from the current Swift sources. Includes internal and test declarations; names here are navigation aids, not an exported SDK contract. The regex-based index does not infer call graphs, access guarantees or complete overload semantics.

## App.swift

| Declaration | Source |
|---|---|
| `final class WorkspaceCanvas: NSView` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L8) |
| `override func draw(_ dirtyRect: NSRect)` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L10) |
| `final class TreeEntry: NSObject` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L16) |
| `init(_ id: String)` | [L18](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L18) |
| `final class KonMagicController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate,` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L21) |
| `init(store: WorkspaceStore, catalog: Catalog, knowledge:KnowledgeStore?=nil) throws` | [L59](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L59) |
| `func label(_ text: String, size: CGFloat = 12, weight: NSFont.Weight = .regular) -> NSTextField` | [L63](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L63) |
| `func button(_ name:String, _ action:Selector, symbol:String?=nil) -> NSButton` | [L66](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L66) |
| `func vertical(_ children:[NSView], padding:CGFloat=16) -> NSStackView` | [L71](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L71) |
| `func row(_ children:[NSView]) -> NSStackView` | [L75](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L75) |
| `func scroll(_ content:NSView) -> NSScrollView` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L78) |
| `func configure(_ table:NSTableView, columns:[(String,String,CGFloat)])` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L82) |
| `override func loadView()` | [L88](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L88) |
| `func arrangeInitialPanes()` | [L150](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L150) |
| `func node(_ item:Any?) -> FolderNode?` | [L156](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L156) |
| `func outlineView(_ o:NSOutlineView,numberOfChildrenOfItem item:Any?) -> Int` | [L158](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L158) |
| `func outlineView(_ o:NSOutlineView,child index:Int,ofItem item:Any?) -> Any` | [L159](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L159) |
| `func outlineView(_ o:NSOutlineView,isItemExpandable item:Any) -> Bool` | [L163](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L163) |
| `func outlineView(_ o:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any) -> NSView?` | [L164](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L164) |
| `func outlineViewSelectionDidChange(_ n:Notification)` | [L171](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L171) |
| `func updateStructureControls()` | [L177](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L177) |
| `func selectDestination(_ id:String)` | [L184](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L184) |
| `func presentAssignments(_ paths:[String])` | [L189](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L189) |
| `func draggedPaths(_ pasteboard:NSPasteboard) -> [String]` | [L190](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L190) |
| `func outlineView(_ o:NSOutlineView,pasteboardWriterForItem item:Any) -> NSPasteboardWriting?` | [L195](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L195) |
| `func outlineView(_ o:NSOutlineView,validateDrop info:NSDraggingInfo,proposedItem item:Any?,proposedChildIndex index:Int) -> NSDragOperation` | [L198](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L198) |
| `func outlineView(_ o:NSOutlineView,acceptDrop info:NSDraggingInfo,item:Any?,childIndex:Int) -> Bool` | [L206](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L206) |
| `func numberOfRows(in tableView:NSTableView) -> Int` | [L217](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L217) |
| `func tableView(_ table:NSTableView,viewFor column:NSTableColumn?,row r:Int) -> NSView?` | [L218](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L218) |
| `func tableView(_ table:NSTableView,pasteboardWriterForRow row:Int) -> NSPasteboardWriting?` | [L232](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L232) |
| `func tableViewSelectionDidChange(_ n:Notification)` | [L236](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L236) |
| `func showDraftPaths()` | [L237](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L237) |
| `func refreshDraft()` | [L249](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L249) |
| `func refreshDraftLocally()` | [L250](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L250) |
| `@objc func showExplorer()` | [L272](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L272) |
| `@objc func showDiskLens()` | [L273](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L273) |
| `@objc func showPreferences()` | [L274](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L274) |
| `func loadSources()` | [L282](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L282) |
| `func controlTextDidChange(_ n:Notification)` | [L299](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L299) |
| `@objc func changeScope()` | [L302](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L302) |
| `func navigate(_ path:String)` | [L303](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L303) |
| `@objc func toggleHidden(_ sender:NSMenuItem)` | [L304](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L304) |
| `@objc func previousPage()` | [L305](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L305) |
| `@objc func nextPage()` | [L306](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L306) |
| `@objc func parentScope()` | [L307](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L307) |
| `@objc func openBucket()` | [L308](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L308) |
| `func grant(_ u:URL)` | [L309](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L309) |
| `func folderPanel(_ title:String, action:@escaping(URL)->Void)` | [L310](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L310) |
| `@objc func chooseScope()` | [L311](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L311) |
| `@objc func chooseOutput()` | [L312](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L312) |
| `@objc func connectCatalog()` | [L313](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L313) |
| `func ask(_ title:String, initial:String, then:(String)throws->Void)` | [L314](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L314) |
| `@objc func newFolder()` | [L320](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L320) |
| `@objc func renameFolder()` | [L333](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L333) |
| `@objc func removeFolder()` | [L334](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L334) |
| `@objc func undoDraft()` | [L337](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L337) |
| `@objc func assignSelection()` | [L338](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L338) |
| `@objc func removeAssignment()` | [L339](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L339) |
| `@objc func renameOutput()` | [L340](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L340) |
| `func setBusy(_ b:Bool)` | [L341](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L341) |
| `@objc func verifyPreview()` | [L342](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L342) |
| `func showPlan(_ p:CopyPlan)` | [L352](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L352) |
| `@objc func applyCopy()` | [L370](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L370) |
| `@objc func openJournal()` | [L384](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L384) |
| `func showError(_ e:Error)` | [L385](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L385) |
| `@objc func showGuide()` | [L386](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L386) |
| `final class KonMagicDelegate: NSObject, NSApplicationDelegate` | [L415](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L415) |
| `init(qa:Bool=false)` | [L421](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L421) |
| `func applicationDidFinishLaunching(_ n:Notification)` | [L422](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L422) |
| `func applicationShouldHandleReopen(_ sender:NSApplication,hasVisibleWindows:Bool)->Bool` | [L478](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L478) |
| `func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool` | [L479](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L479) |
| `func applicationShouldTerminate(_ sender:NSApplication) -> NSApplication.TerminateReply` | [L483](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L483) |
| `func runUIQA()` | [L487](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L487) |
| `func runExplorerQA()` | [L509](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L509) |
| `func runLensQA()` | [L548](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L548) |

## Catalog.swift

| Declaration | Source |
|---|---|
| `struct CatalogItem` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L5) |
| `private final class QueryBudget` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L24) |
| `final class Catalog` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L26) |
| `init(path: String,knowledge:KnowledgeStore?=nil)` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L29) |
| `func liveFolder(_ path:String,search:String="",offset:Int=0,includeHidden:Bool=false) throws -> [CatalogItem]` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L30) |
| `func query(scope: String?, search: String, offset: Int = 0) throws -> [CatalogItem]` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L46) |

## CatalogueDatabase.swift

| Declaration | Source |
|---|---|
| `final class CatalogueCancellation` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L6) |
| `func cancel()` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L9) |
| `final class AtlasDatabase` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L14) |
| `init(_ path: String, seconds: TimeInterval = 5, cancellation:CatalogueCancellation?=nil) throws` | [L18](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L18) |
| `func rows(_ sql:String, _ values:[String]=[], each:(OpaquePointer)throws->Void) throws` | [L39](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L39) |
| `func blobRows(_ sql:String, key:Data, each:(OpaquePointer)throws->Void) throws` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L55) |
| `static func string(_ s:OpaquePointer,_ i:Int32)->String` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L68) |
| `static func blob(_ s:OpaquePointer,_ i:Int32,limit:Int)->Data?` | [L69](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L69) |
| `static func unpack(_ data:Data,limit:Int) throws -> Data` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L74) |
| `static func pack(_ data:Data) throws -> Data` | [L85](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L85) |
| `enum CatalogueDimension: String, CaseIterable, Codable` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L93) |
| `struct CatalogueSlice:Codable,Equatable` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L119) |
| `func validate() throws` | [L126](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L126) |
| `func predicate(paging:Bool=false)->(String,[String])` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L130) |
| `struct CataloguePage` | [L150](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L150) |
| `struct CataloguePartition:Codable` | [L151](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L151) |
| `func matches(_ facets:[CatalogueDimension:String])->Bool` | [L156](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L156) |
| `struct CatalogueFacet` | [L158](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L158) |
| `struct CatalogueSummary:Codable` | [L162](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L162) |
| `func sliced(_ facets:[CatalogueDimension:String])->CatalogueSummary` | [L167](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L167) |
| `func groups(_ dimension:CatalogueDimension)->[CatalogueFacet]` | [L168](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L168) |
| `func effectiveSource(_ reader:AtlasDatabase) throws -> String` | [L177](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L177) |
| `func observation(at path:String) throws -> CatalogItem?` | [L191](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L191) |
| `func cataloguePage(_ slice:CatalogueSlice,cancellation:CatalogueCancellation?=nil) throws -> CataloguePage` | [L196](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L196) |
| `static func record(_ s:OpaquePointer)->CatalogItem` | [L205](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L205) |
| `func catalogueRoots() throws -> [CatalogItem]` | [L220](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L220) |
| `func summary(_ slice:CatalogueSlice=CatalogueSlice(),cancellation:CatalogueCancellation?=nil) throws -> CatalogueSummary` | [L227](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L227) |
| `func storedReading(_ item:CatalogItem) throws -> String` | [L242](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueDatabase.swift#L242) |

## CatalogueExplorer.swift

| Declaration | Source |
|---|---|
| `struct ExplorerDrillContext` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L4) |
| `final class ExplorerNode:NSObject` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L9) |
| `init(_ item:CatalogItem)` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L19) |
| `init(title:String,choices:[CatalogueDimension:String],level:Int)` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L20) |
| `final class CatalogueExplorerController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,` | [L23](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L23) |
| `init(workspace:KonMagicController)` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L53) |
| `func text(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L55) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L58](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L58) |
| `func row(_ views:[NSView])->NSStackView` | [L59](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L59) |
| `func column(_ views:[NSView])->NSStackView` | [L60](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L60) |
| `func scroll(_ view:NSView)->NSScrollView` | [L61](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L61) |
| `func setupTable(_ table:NSTableView,columns:[(String,String,CGFloat)])` | [L62](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L62) |
| `override func loadView()` | [L66](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L66) |
| `func refreshDestinations()` | [L141](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L141) |
| `func drillInto(_ choices:[CatalogueDimension:String])` | [L150](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L150) |
| `@objc func restoreDrillContext()` | [L156](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L156) |
| `func updateFilterChips()` | [L160](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L160) |
| `@objc func removeFilter(_ sender:NSButton)` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L165) |
| `func showRecordedFolder(_ path:String)` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L166) |
| `func slice()->CatalogueSlice` | [L169](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L169) |
| `func resetPaging()` | [L170](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L170) |
| `@objc func searchChanged()` | [L171](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L171) |
| `func controlTextDidChange(_ note:Notification)` | [L172](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L172) |
| `@objc func clearFilters()` | [L173](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L173) |
| `@objc func refresh()` | [L174](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L174) |
| `@objc func changeDataset()` | [L175](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L175) |
| `@objc func changePlace()` | [L186](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L186) |
| `@objc func changeDimension()` | [L187](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L187) |
| `@objc func changeMetric()` | [L188](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L188) |
| `@objc func changeVisualization()` | [L189](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L189) |
| `func updateMode()` | [L190](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L190) |
| `@objc func selectFacet()` | [L198](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L198) |
| `func loadPage()` | [L199](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L199) |
| `func loadSummary()` | [L228](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L228) |
| `func number(_ n:Int64)->String` | [L249](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L249) |
| `func renderSummary()` | [L250](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L250) |
| `func loadRoots()` | [L269](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L269) |
| `func loadTagTree()` | [L283](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L283) |
| `func outlineView(_ outline:NSOutlineView,numberOfChildrenOfItem item:Any?)->Int` | [L287](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L287) |
| `func outlineView(_ outline:NSOutlineView,child index:Int,ofItem item:Any?)->Any` | [L288](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L288) |
| `func outlineView(_ outline:NSOutlineView,isItemExpandable item:Any)->Bool` | [L289](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L289) |
| `func outlineView(_ outline:NSOutlineView,shouldExpandItem item:Any)->Bool` | [L290](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L290) |
| `func loadChildren(_ node:ExplorerNode)` | [L300](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L300) |
| `func outlineView(_ outline:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any)->NSView?` | [L317](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L317) |
| `func outlineViewSelectionDidChange(_ note:Notification)` | [L320](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L320) |
| `func outlineView(_ outline:NSOutlineView,pasteboardWriterForItem item:Any)->NSPasteboardWriting?` | [L321](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L321) |
| `func selectedRecords()->[CatalogItem]` | [L322](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L322) |
| `@objc func openTreeSelection()` | [L327](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L327) |
| `@objc func openObservation()` | [L333](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L333) |
| `func open(_ item:CatalogItem)` | [L334](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L334) |
| `@objc func parentFolder()` | [L335](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L335) |
| `@objc func nextPage()` | [L336](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L336) |
| `@objc func previousPage()` | [L337](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L337) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L338](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L338) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L339](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L339) |
| `func tableViewSelectionDidChange(_ note:Notification)` | [L351](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L351) |
| `func tableView(_ tableView:NSTableView,pasteboardWriterForRow row:Int)->NSPasteboardWriting?` | [L352](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L352) |
| `@objc func destinationChanged()` | [L353](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L353) |
| `func updateSelectionControls()` | [L354](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L354) |
| `func showMetadata()` | [L367](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L367) |
| `@objc func showReading()` | [L400](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L400) |
| `@objc func revealSource()` | [L406](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L406) |
| `@objc func returnToToolkit()` | [L407](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L407) |
| `@objc func editDestinations()` | [L408](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L408) |
| `@objc func assignSelected()` | [L409](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L409) |
| `func show()` | [L417](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L417) |

## CatalogueTests.swift

| Declaration | Source |
|---|---|
| `func runCatalogueTests(at directory:URL) throws -> Int` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L4) |
| `func check(_ value:Bool,_ message:String)throws` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L6) |
| `func refuses(_ message:String,_ body:()throws->Void)throws` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L7) |
| `func execute(_ sql:String)throws` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L12) |
| `func diskExecute(_ sql:String)throws` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L67) |
| `func insertBlob(_ sql:String,_ blobs:[Data])throws` | [L70](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueTests.swift#L70) |

## CatalogueVisuals.swift

| Declaration | Source |
|---|---|
| `struct CatalogueMapTile` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L3) |
| `final class CatalogueMapView:NSView` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L12) |
| `override func accessibilityRole()->NSAccessibility.Role?` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L21) |
| `override func accessibilityLabel()->String?` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L22) |
| `func configure(_ summary:CatalogueSummary,dimension:CatalogueDimension,connections:Bool,byBytes:Bool)` | [L23](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L23) |
| `func configureDisk(_ values:[String:Int64])` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L50) |
| `private func color(_ name:String)->NSColor` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L55) |
| `private func partition(_ indexes:[Int],in rect:NSRect)` | [L60](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L60) |
| `override func draw(_ dirtyRect:NSRect)` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L77) |
| `override func mouseDown(with event:NSEvent)` | [L104](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L104) |
| `override func keyDown(with event:NSEvent)` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueVisuals.swift#L108) |

## ContextHelp.swift

| Declaration | Source |
|---|---|
| `final class DialogValidation:NSObject` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L3) |
| `init(fields:[NSTextField]=[],popups:[NSPopUpButton]=[],evaluate:@escaping ()->Void)` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L6) |
| `@objc func refresh(_ sender:Any?)` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L12) |
| `func run(_ alert:NSAlert)->NSApplication.ModalResponse` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L13) |
| `func dialogAccessory(_ views:[NSView])->NSView` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L16) |
| `func contextHelp(from sender:NSButton,title:String,body:String)->NSPopover` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L27) |
| `@objc func showTips(_ sender:NSButton)` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L35) |
| `@objc func showTips(_ sender:NSButton)` | [L41](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L41) |
| `@objc func showWorkspaceTips(_ sender:NSButton)` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L46) |

## DiskCatalogue.swift

| Declaration | Source |
|---|---|
| `struct DiskOverview` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L5) |
| `struct DiskPage` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L11) |
| `final class DiskCatalogue` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L12) |
| `init(path:String,knowledge:KnowledgeStore?=nil)` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L15) |
| `func overview() throws -> DiskOverview` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L16) |
| `func roots() throws -> [CatalogItem]` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L28) |
| `func folder(_ requested:String,offset:Int=0,search:String="") throws -> DiskPage` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L36) |
| `func exceptions(offset:Int=0) throws -> [CatalogItem]` | [L69](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L69) |
| `struct SummaryStamp:Codable,Equatable` | [L79](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L79) |
| `struct SummaryCache:Codable` | [L80](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L80) |
| `func summaryStamp() throws -> SummaryStamp` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L82) |
| `func cachedSummary(in directory:URL,cancellation:CatalogueCancellation?=nil) throws -> CatalogueSummary` | [L89](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskCatalogue.swift#L89) |

## DiskLensController.swift

| Declaration | Source |
|---|---|
| `final class DiskLensController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate,QLPreviewPanelDataSource,QLPreviewPanelDelegate,NSWindowDelegate,NSUserInterfaceValidations` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L6) |
| `init(workspace:KonMagicController)` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L27) |
| `func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L29) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L30) |
| `func row(_ views:[NSView])->NSStackView` | [L31](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L31) |
| `func column(_ views:[NSView])->NSStackView` | [L32](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L32) |
| `override func loadView()` | [L33](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L33) |
| `func refreshDestinations()` | [L86](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L86) |
| `func applyViewPreferences(_ value:LensPreferences)` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L87) |
| `func show()` | [L92](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L92) |
| `func amount(_ n:Int64)->String` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L93) |
| `func chooseFolder()->URL?` | [L94](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L94) |
| `@objc func chooseScan()` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L95) |
| `@objc func chooseRecorded()` | [L96](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L96) |
| `@objc func recordedMachine()` | [L97](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L97) |
| `func beginScan(root:String,recorded:Bool=false,incremental:Bool=false)` | [L98](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L98) |
| `func open(_ store:LensStore)` | [L113](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L113) |
| `@objc func openRecent()` | [L121](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L121) |
| `@objc func stop()` | [L122](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L122) |
| `@objc func refresh()` | [L123](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L123) |
| `@objc func rescan()` | [L124](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L124) |
| `@objc func settingsChanged()` | [L125](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L125) |
| `func render()` | [L129](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L129) |
| `func windowDidResize(_ notification:Notification)` | [L144](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L144) |
| `func windowShouldClose(_ sender:NSWindow)->Bool` | [L145](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L145) |
| `func navigate(_ id:Int64,synchronize:Bool=true)` | [L146](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L146) |
| `@objc func goParent()` | [L150](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L150) |
| `@objc func zoomSelection()` | [L151](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L151) |
| `@objc func focusUp()` | [L152](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L152) |
| `@objc func focusDown()` | [L153](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L153) |
| `func loadRows()` | [L154](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L154) |
| `@objc func previousRows()` | [L161](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L161) |
| `@objc func nextRows()` | [L162](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L162) |
| `func controlTextDidChange(_ obj:Notification)` | [L163](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L163) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L164](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L164) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L165) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L166) |
| `@objc func openRow()` | [L167](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L167) |
| `func select(_ node:LensNode)` | [L168](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L168) |
| `func date(_ value:Int64)->String` | [L170](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L170) |
| `@objc func destinationChanged()` | [L179](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L179) |
| `@objc func updateSourceControls()` | [L180](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L180) |
| `func currentURL() throws -> URL` | [L186](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L186) |
| `@objc func openSelected()` | [L194](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L194) |
| `@objc func reveal()` | [L195](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L195) |
| `@objc func showQuickLook()` | [L196](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L196) |
| `func numberOfPreviewItems(in panel:QLPreviewPanel!)->Int` | [L197](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L197) |
| `func previewPanel(_ panel:QLPreviewPanel!,previewItemAt index:Int)->QLPreviewItem!` | [L198](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L198) |
| `@objc func assign()` | [L199](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L199) |
| `@objc func reviewCleanup()` | [L200](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L200) |
| `@objc func returnToToolkit()` | [L201](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L201) |
| `@objc func toggleViewOptions()` | [L202](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L202) |
| `func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool` | [L203](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L203) |
| `@objc func showCatalogue()` | [L208](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L208) |
| `@objc func duplicate()` | [L209](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L209) |
| `@objc func twin()` | [L210](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L210) |
| `@objc func editMask()` | [L211](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L211) |
| `func remember(_ filter:LensFilter)` | [L212](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L212) |
| `@objc func filterView()` | [L213](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L213) |
| `@objc func scanFilters()` | [L214](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L214) |
| `@objc func filterLibrary()` | [L215](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L215) |
| `@objc func typeColors()` | [L216](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L216) |
| `func perform<T>(_ title:String,_ body:@escaping ()throws->T,completed:@escaping (T)->Void)` | [L217](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L217) |
| `@objc func loadScan()` | [L218](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L218) |
| `@objc func saveScan()` | [L219](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L219) |
| `@objc func notes()` | [L220](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L220) |
| `@objc func compareScan()` | [L221](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L221) |
| `@objc func exportImage()` | [L231](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L231) |
| `@objc func exportText()` | [L232](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L232) |

## DiskLensExports.swift

| Declaration | Source |
|---|---|
| `struct LensDifferencePage` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L5) |
| `struct LensDifference` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L6) |
| `private func differenceSource(_ baseline:LensStore,cancellation:CatalogueCancellation,seconds:TimeInterval=60) throws -> (AtlasDatabase,String)` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L8) |
| `func differencePage(_ baseline:LensStore,cursor:String?=nil,cancellation:CatalogueCancellation) throws -> LensDifferencePage` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L20) |
| `func compare(_ baseline:LensStore,cancellation:CatalogueCancellation) throws -> [LensDifference]` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L27) |
| `func exportDifferences(_ baseline:LensStore,to destination:URL,cancellation:CatalogueCancellation) throws -> Int` | [L31](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L31) |
| `func write(_ fields:[String]) throws` | [L37](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L37) |
| `func export(to destination:URL,fields:[String],cancellation:CatalogueCancellation) throws` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L50) |
| `func row(_ values:[String]) throws` | [L57](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensExports.swift#L57) |

## DiskLensFilters.swift

| Declaration | Source |
|---|---|
| `final class LensFilterEditor:NSWindowController,NSTableViewDelegate,NSTableViewDataSource,NSTextFieldDelegate,NSWindowDelegate` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L3) |
| `init(_ value:LensFilter)` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L10) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L30) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L31](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L31) |
| `func controlTextDidChange(_ obj:Notification)` | [L40](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L40) |
| `@objc func fieldChanged(_ p:NSPopUpButton)` | [L41](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L41) |
| `@objc func operatorChanged(_ p:NSPopUpButton)` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L42) |
| `@objc func negateChanged(_ b:NSButton)` | [L43](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L43) |
| `@objc func add()` | [L44](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L44) |
| `@objc func remove()` | [L45](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L45) |
| `func refreshGroups()` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L46) |
| `@objc func groupChanged()` | [L47](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L47) |
| `@objc func scopeChanged()` | [L48](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L48) |
| `@objc func invertChanged()` | [L49](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L49) |
| `@objc func newGroup()` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L50) |
| `@objc func removeGroup()` | [L51](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L51) |
| `@objc func cancel()` | [L52](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L52) |
| `func windowShouldClose(_ sender:NSWindow)->Bool` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L53) |
| `@objc func save()` | [L54](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L54) |
| `func edit()->LensFilter?` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensFilters.swift#L55) |

## DiskLensMap.swift

| Declaration | Source |
|---|---|
| `struct LensTile` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L4) |
| `struct LensMapResult` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L5) |
| `final class LensMapBuilder` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L6) |
| `init(store:LensStore,info:LensSnapshot,preferences:LensPreferences,mask:LensFilter,cancellation:CatalogueCancellation) throws` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L9) |
| `static func rectangles(_ weights:[Int64],rect:NSRect)->[NSRect]` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L13) |
| `func split(_ a:Int,_ b:Int,_ r:NSRect)` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L15) |
| `func build(focus:LensNode,bounds:NSRect)->LensMapResult` | [L25](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L25) |
| `private func visit(_ parent:LensNode,rect:NSRect,level:Int) throws` | [L43](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L43) |
| `private func add(_ node:LensNode,rect:NSRect,label:String?=nil)` | [L71](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L71) |
| `final class LensCanvas:NSView` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L77) |
| `override func accessibilityRole()->NSAccessibility.Role?` | [L83](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L83) |
| `override func accessibilityLabel()->String?` | [L84](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L84) |
| `override func updateTrackingAreas()` | [L85](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L85) |
| `func value(_ tile:LensTile)->String` | [L86](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L86) |
| `func color(_ value:String)->NSColor` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L101) |
| `override func draw(_ rect:NSRect)` | [L110](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L110) |
| `func at(_ event:NSEvent)->LensTile?` | [L129](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L129) |
| `override func mouseMoved(with event:NSEvent)` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L130) |
| `override func mouseDown(with event:NSEvent)` | [L131](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L131) |
| `override func scrollWheel(with event:NSEvent)` | [L132](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L132) |
| `override func keyDown(with event:NSEvent)` | [L133](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L133) |
| `func distance(_ tile:LensTile)->CGFloat` | [L144](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L144) |

## DiskLensModel.swift

| Declaration | Source |
|---|---|
| `enum LensMeasure:String,CaseIterable,Codable` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L6) |
| `enum LensDisplay:String,CaseIterable,Codable` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L9) |
| `enum LensColor:String,CaseIterable,Codable` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L12) |
| `enum LensPalette:String,CaseIterable,Codable` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L15) |
| `enum LensField:String,CaseIterable,Codable` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L16) |
| `enum LensOperator:String,CaseIterable,Codable` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L19) |
| `struct LensRule:Codable,Equatable` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L20) |
| `func matches(_ node:LensNode,path:String)->Bool` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L22) |
| `struct LensTestGroup:Codable,Equatable` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L50) |
| `func matches(_ node:LensNode,path:String)->Bool` | [L52](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L52) |
| `struct LensFilter:Codable,Equatable` | [L65](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L65) |
| `init(name:String="Untitled filter",rules:[LensRule]=[],matchAll:Bool=true,includeAnyExcludeAll:Bool=false,groups:[LensTestGroup]=[])` | [L69](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L69) |
| `enum CodingKeys:String,CodingKey` | [L70](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L70) |
| `init(from decoder:Decoder) throws` | [L71](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L71) |
| `func matches(_ node:LensNode,path:String)->Bool` | [L72](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L72) |
| `func validate() throws` | [L80](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L80) |
| `struct LensTotals:Codable,Equatable` | [L97](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L97) |
| `static func +(a:LensTotals,b:LensTotals)->LensTotals` | [L99](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L99) |
| `func weight(_ measure:LensMeasure)->Int64` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L100) |
| `struct LensNode` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L102) |
| `static func metadata(_ s:stat,name:String,parent:Int64,relative:String,depth:Int)->LensNode` | [L110](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L110) |
| `static func packageName(_ name:String)->Bool` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L117) |
| `struct LensSnapshot:Codable` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L119) |
| `struct LensPreferences:Codable` | [L125](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L125) |
| `static func load(_ directory:URL)->LensPreferences` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L130) |
| `func save(_ directory:URL) throws` | [L136](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensModel.swift#L136) |

## DiskLensScan.swift

| Declaration | Source |
|---|---|
| `final class LensScanner` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L5) |
| `init(directory:URL,cancellation:CatalogueCancellation) throws` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L11) |
| `func pulse() throws` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L12) |
| `func run(root:String,filter:LensFilter=LensFilter(),exclude:LensFilter=LensFilter(),previous:LensStore?=nil,changes:Set<String>?=nil) throws -> LensStore` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L13) |
| `private func liveChildren(fd:Int32,path:String,parent:LensNode,previous:LensStore?,changes:Set<String>?) throws` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L27) |
| `private func cachedChildren(_ store:LensStore,parent:LensNode,old:LensNode) throws` | [L63](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L63) |
| `func visit(_ parent:LensNode,_ old:LensNode) throws` | [L65](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L65) |
| `func recorded(root:String,ledger:String) throws -> LensStore` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L73) |
| `func visit(path:String,parent:LensNode) throws` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L78) |
| `static func filter(_ original:LensStore,using filter:LensFilter,directory:URL,cancellation:CatalogueCancellation) throws -> LensStore` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensScan.swift#L119) |

## DiskLensStore.swift

| Declaration | Source |
|---|---|
| `final class LensWriter` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L6) |
| `init(directory:URL,cancellation:CatalogueCancellation) throws` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L12) |
| `func prepare(_ sql:String) throws -> OpaquePointer` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L28) |
| `func exec(_ sql:String) throws` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L29) |
| `func check() throws` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L30) |
| `func append(_ input:LensNode,deduplicate:Bool=true) throws -> LensNode` | [L37](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L37) |
| `func issue(_ id:Int64,_ message:String) throws` | [L54](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L54) |
| `func directory(relative:String) throws -> LensNode?` | [L58](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L58) |
| `func finish(_ snapshot:LensSnapshot) throws -> LensSnapshot` | [L66](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L66) |
| `struct LensStore` | [L90](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L90) |
| `static func node(_ s:OpaquePointer)->LensNode` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L93) |
| `func snapshot() throws -> LensSnapshot` | [L97](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L97) |
| `func nodes(where predicate:String="n.parent=?",values:[String],order:String="n.ta DESC,n.name COLLATE NOCASE,n.id",limit:Int=5000,offset:Int=0) throws -> [LensNode]` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L102) |
| `func node(_ id:Int64) throws -> LensNode?` | [L106](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L106) |
| `func path(_ node:LensNode,_ info:LensSnapshot)->String` | [L107](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L107) |
| `func comments(_ value:String,directory:URL) throws -> URL` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L108) |
| `func copy(to destination:URL) throws` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensStore.swift#L117) |

## DiskLensTests.swift

| Declaration | Source |
|---|---|
| `func runLensTests(at temp:URL) throws -> Int` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L5) |
| `func check(_ result:Bool,_ text:String) throws` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L7) |
| `func refuses(_ text:String,_ body:()throws->Void) throws` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L8) |
| `func write(_ path:URL,_ text:String) throws` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L11) |
| `func sql(_ text:String) throws` | [L99](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L99) |
| `func hex(_ data:Data)->String` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L100) |
| `func key(_ path:String) throws -> String` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L101) |
| `func block(_ rows:[[Any]]) throws -> String` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L102) |

## DiskLensWatcher.swift

| Declaration | Source |
|---|---|
| `final class LensWatcher` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L5) |
| `init?(root:String)` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L9) |
| `func consume()->Set<String>?` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L29) |

## Documentation.swift

| Declaration | Source |
|---|---|
| `enum KonMagicDocumentation` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L5) |
| `static func route(_ page:KonMagicPage)->String` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L7) |
| `static func open(_ route:String="")` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L16) |
| `@objc func showDocumentation()` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L20) |
| `@objc func showPageDocumentation()` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L21) |
| `@objc func showDeveloperDocumentation()` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/Documentation.swift#L26) |

## DocumentationCapture.swift

| Declaration | Source |
|---|---|
| `func validateDocumentationFixture(_ state:URL) throws` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L6) |
| `func runDocumentationCapture()` | [L18](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L18) |
| `func checkViewer(_ condition:Bool,_ message:String)` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L24) |
| `func capture(_ name:String,_ v:NSView?=nil)` | [L25](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L25) |
| `func dialog(_ name:String,_ body:()->Void)` | [L40](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L40) |
| `func advance()` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L77) |

## DuplicateReview.swift

| Declaration | Source |
|---|---|
| `struct DuplicateSizeGroup` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L6) |
| `struct DuplicateProof` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L7) |
| `func duplicateSizes(cursor:Int64?=nil,cancellation:CatalogueCancellation) throws -> (groups:[DuplicateSizeGroup],next:Int64?)` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L19) |
| `func duplicateMembers(bytes:Int64) throws -> [LensNode]` | [L25](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L25) |
| `func proveDuplicates(nodes:[LensNode],cancellation:CatalogueCancellation,allowFixture:Bool=false) throws -> DuplicateProof` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L28) |
| `private func cancellableHash(_ fd:Int32,cancellation:CatalogueCancellation) throws -> String` | [L58](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L58) |
| `final class DuplicateReviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L73) |
| `init(store:LensStore)` | [L80](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L80) |
| `override func loadView()` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L82) |
| `func show()` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L101) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L102) |
| `func tableView(_ tableView:NSTableView,objectValueFor tableColumn:NSTableColumn?,row:Int)->Any?` | [L103](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L103) |
| `func load()` | [L104](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L104) |
| `func controls()` | [L110](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L110) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L111](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L111) |
| `@objc func goNext()` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L117) |
| `@objc func goPrevious()` | [L118](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L118) |
| `@objc func cancel()` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L119) |
| `@objc func prove()` | [L120](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L120) |
| `@objc func duplicateReview()` | [L131](https://github.com/madfam-org/konmagic/blob/main/Sources/DuplicateReview.swift#L131) |

## Filesystem.swift

| Declaration | Source |
|---|---|
| `struct Identity: Codable, Equatable` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L5) |
| `init(_ s: stat)` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L8) |
| `struct FileRecord: Codable, Equatable` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L14) |
| `struct BucketPlan: Codable` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L20) |
| `struct CopyPlan: Codable` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L26) |
| `struct OutputAnchor: Codable, Equatable` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L36) |
| `enum SafeFS` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L42) |
| `static func fail(_ text: String) -> KonMagicError` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L46) |
| `static func components(_ path: String) throws -> [String]` | [L47](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L47) |
| `static func openDirectory(_ path: String, create: Bool = false) throws -> Int32` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L53) |
| `static func names(_ fd: Int32) throws -> [String]` | [L70](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L70) |
| `static func info(_ fd: Int32, _ name: String) throws -> stat` | [L88](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L88) |
| `static func isDirectory(_ s: stat) -> Bool` | [L94](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L94) |
| `static func isFile(_ s: stat) -> Bool` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L95) |
| `static func hash(_ fd: Int32) throws -> String` | [L96](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L96) |
| `static func guardedName(_ name: String) -> Bool` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L108) |
| `static func sourceGuard(_ path: String) throws` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L115) |
| `static func inspect(_ path: String, allowFixture: Bool = false, hashing: Bool = true) throws -> [FileRecord]` | [L132](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L132) |
| `func visit(_ pfd: Int32, _ name: String, _ relative: String, _ depth: Int) throws` | [L138](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L138) |
| `static func destinationClear(_ path: String) throws` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L166) |
| `static func available(_ path: String) throws -> Int64` | [L177](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L177) |
| `static func anchor(_ path:String) throws -> OutputAnchor` | [L185](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L185) |
| `static func validateAnchor(_ a:OutputAnchor) throws` | [L192](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L192) |
| `static func workspaceHash(_ w: Workspace) throws -> String` | [L196](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L196) |
| `static func preview(_ w: Workspace, allowFixture: Bool = false) throws -> CopyPlan` | [L200](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L200) |
| `static func writeRecord<T: Encodable>(_ value: T, at url: URL) throws` | [L240](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L240) |
| `static func copy(_ plan: CopyPlan, workspace: Workspace, journalDirectory: URL, allowFixture: Bool = false) throws -> URL` | [L249](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L249) |
| `struct Receipt: Codable` | [L261](https://github.com/madfam-org/konmagic/blob/main/Sources/Filesystem.swift#L261) |

## InspectorTypography.swift

| Declaration | Source |
|---|---|
| `final class KonMagicInspector:NSTextView` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/InspectorTypography.swift#L5) |
| `func friendlyObservationDate(_ value:String)->String` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/InspectorTypography.swift#L24) |

## JourneyTestsUI.swift

| Declaration | Source |
|---|---|
| `func runJourneyQA()` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneyTestsUI.swift#L5) |
| `func check(_ value:Bool,_ name:String)` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneyTestsUI.swift#L11) |
| `func go(_ page:KonMagicPage)` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneyTestsUI.swift#L12) |

## Knowledge.swift

| Declaration | Source |
|---|---|
| `struct TagCorrection:Codable,Equatable` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L5) |
| `struct TagUndo:Codable` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L10) |
| `struct SavedCollection:Codable` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L14) |
| `struct NameRecipe:Codable` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L22) |
| `func output(_ name:String) throws -> String` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L24) |
| `struct ProposalRule:Codable` | [L32](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L32) |
| `struct Knowledge:Codable` | [L39](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L39) |
| `func validate() throws` | [L47](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L47) |
| `func correction(_ path:String,_ value:TagCorrection) throws` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L50) |
| `func applying(to item:CatalogItem)->CatalogItem` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L68) |
| `final class KnowledgeStore` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L78) |
| `init(directory:URL) throws` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L82) |
| `func snapshot()->Knowledge` | [L99](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L99) |
| `private func change(_ body:(inout Knowledge)throws->Void) throws` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L100) |
| `func correct(paths:[String],tags:[String:String],note:String) throws` | [L107](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L107) |
| `func reset(paths:[String]) throws` | [L120](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L120) |
| `func undoCorrection() throws` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L130) |
| `func save(_ collection:SavedCollection) throws` | [L136](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L136) |
| `func save(_ rule:ProposalRule) throws` | [L137](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L137) |
| `func removeCollection(_ id:String) throws` | [L138](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L138) |
| `func removeRule(_ id:String) throws` | [L139](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L139) |
| `struct DraftProposal` | [L142](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L142) |
| `static func make(items:[CatalogItem],rule:ProposalRule,workspace:Workspace,more:Bool=false) throws -> DraftProposal` | [L146](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L146) |
| `func apply(to workspace:inout Workspace) throws` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/Knowledge.swift#L165) |

## KnowledgeTests.swift

| Declaration | Source |
|---|---|
| `func runKnowledgeTests(at directory:URL,catalogueURL:URL) throws -> Int` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L4) |
| `func check(_ result:Bool,_ message:String) throws` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L6) |
| `func refuses(_ message:String,_ body:()throws->Void) throws` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L7) |
| `func runReviewTests(at directory:URL) throws -> Int` | [L60](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L60) |
| `func check(_ result:Bool,_ message:String) throws` | [L62](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L62) |

## KnowledgeUI.swift

| Declaration | Source |
|---|---|
| `func knowledgeAccessory(_ views:[NSView])->NSView` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L4) |
| `func knowledgeForm(_ labels:[String],_ fields:[NSTextField])->NSGridView` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L7) |
| `func field(_ value:String="",placeholder:String="")->NSTextField` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L13) |
| `func knowledgeChanged()` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L16) |
| `func reloadKnowledge()` | [L17](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L17) |
| `@objc func correctTags()` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L21) |
| `@objc func collectionsMenu()` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L53) |
| `@objc func rulesMenu()` | [L81](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L81) |
| `func createRule()` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L101) |
| `func previewRule(_ rule:ProposalRule)` | [L121](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L121) |

## MetadataLabels.swift

| Declaration | Source |
|---|---|
| `enum MetadataLabels` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/MetadataLabels.swift#L5) |
| `static func tags(path:String,kind:String,inherited:String)->[String:String]` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/MetadataLabels.swift#L22) |

## Model.swift

| Declaration | Source |
|---|---|
| `struct KonMagicError: Error, LocalizedError` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L4) |
| `init(_ message: String)` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L6) |
| `struct FolderNode: Codable, Equatable` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L10) |
| `struct Assignment: Codable, Equatable` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L16) |
| `struct Workspace: Codable` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L24) |
| `static func initial() -> Workspace` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L35) |
| `func children(_ parent: String?) -> [FolderNode]` | [L56](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L56) |
| `func path(_ id: String) throws -> String` | [L57](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L57) |
| `static func key(_ name: String) -> String` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L67) |
| `static func checkName(_ name: String) throws` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L68) |
| `func validate() throws` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L74) |
| `func destination(_ a: Assignment) throws -> String` | [L90](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L90) |
| `mutating func assign(_ paths: [String], to node: String) throws` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L93) |
| `final class WorkspaceStore` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L108) |
| `init(directory: URL) throws` | [L113](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L113) |
| `func persist() throws` | [L128](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L128) |
| `func change(_ body: (inout Workspace) throws -> Void) throws` | [L134](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L134) |
| `func undoDraft() throws` | [L140](https://github.com/madfam-org/konmagic/blob/main/Sources/Model.swift#L140) |

## Navigation.swift

| Declaration | Source |
|---|---|
| `enum KonMagicPage:Int,CaseIterable` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L3) |
| `final class KonMagicNavigation:NSObject,NSUserInterfaceValidations` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L19) |
| `init(workspace:KonMagicController)` | [L23](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L23) |
| `func refreshDraft()` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L29) |
| `func refreshActivity()` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L36) |
| `func knowledgeChanged()` | [L37](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L37) |
| `func connectCatalogue(_ path:String)` | [L44](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L44) |
| `func closed(_ host:PageHostController)` | [L76](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L76) |
| `@objc func showToolkit()` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L77) |
| `@objc func showStorage()` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L78) |
| `@objc func showContent()` | [L79](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L79) |
| `@objc func showStructure()` | [L80](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L80) |
| `@objc func showReview()` | [L81](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L81) |
| `@objc func back()` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L82) |
| `@objc func forward()` | [L83](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L83) |
| `@objc func openCurrent()` | [L84](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L84) |
| `@objc func chooseScope()` | [L85](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L85) |
| `@objc func connectCatalog()` | [L86](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L86) |
| `@objc func chooseOutput()` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L87) |
| `@objc func verifyPreview()` | [L88](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L88) |
| `@objc func undoDraft()` | [L89](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L89) |
| `@objc func showGuide()` | [L90](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L90) |
| `@objc func showPreferences()` | [L91](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L91) |
| `@objc func toggleHidden(_ sender:NSMenuItem)` | [L92](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L92) |
| `func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L93) |
| `@objc func openPage(_ sender:NSMenuItem)` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L100) |
| `@objc func showRunning()` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L101) |
| `final class PageEntry` | [L112](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L112) |
| `init(id:String,title:String,controller:NSViewController,minimum:NSSize,base:KonMagicPage?=nil,duplicate:((KonMagicController)->NSViewController)?=nil)` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L116) |
| `private final class PageDocument:NSView` | [L127](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L127) |
| `private final class PageViewport:NSScrollView` | [L128](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L128) |
| `init(controller:NSViewController,minimum:NSSize)` | [L131](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L131) |
| `override func tile()` | [L139](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L139) |
| `final class PageHostController:NSViewController,NSWindowDelegate` | [L149](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L149) |
| `init(workspace:KonMagicController,navigation:KonMagicNavigation,primary:Bool)` | [L158](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L158) |
| `func makeWindow(_ existing:NSWindow?=nil,saveFrame:Bool=true)` | [L160](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L160) |
| `override func loadView()` | [L172](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L172) |
| `func setup(_ b:NSButton,_ title:String,_ symbol:String?,_ action:Selector)` | [L174](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L174) |
| `func entry(_ page:KonMagicPage)->PageEntry` | [L197](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L197) |
| `func navigate(_ page:KonMagicPage)` | [L213](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L213) |
| `func show(_ entry:PageEntry,remember:Bool=true)` | [L214](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L214) |
| `func showDetail(_ controller:NSViewController,title:String,duplicate:@escaping(KonMagicController)->NSViewController)` | [L242](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L242) |
| `func updateNavigation()` | [L249](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L249) |
| `@objc func continueJourney()` | [L273](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L273) |
| `@objc func changePage()` | [L283](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L283) |
| `@objc func goBack()` | [L284](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L284) |
| `@objc func goForward()` | [L285](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L285) |
| `@objc func showMain()` | [L286](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L286) |
| `@objc func showRunning()` | [L287](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L287) |
| `@objc func openCurrent()` | [L288](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L288) |
| `func windowShouldClose(_ sender:NSWindow)->Bool` | [L295](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L295) |
| `func windowWillClose(_ notification:Notification)` | [L298](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L298) |
| `func windowDidResize(_ notification:Notification)` | [L301](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L301) |

## NavigationTestsUI.swift

| Declaration | Source |
|---|---|
| `func runNavigationQA()` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/NavigationTestsUI.swift#L4) |
| `func check(_ value:Bool,_ name:String)` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/NavigationTestsUI.swift#L8) |
| `func visibleHosts()->Int` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/NavigationTestsUI.swift#L9) |

## ReorganizationReviewUI.swift

| Declaration | Source |
|---|---|
| `final class ReorganizationReviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L5) |
| `init(workspace:KonMagicController)` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L12) |
| `func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L14) |
| `func row(_ views:[NSView])->NSStackView` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L15) |
| `func column(_ views:[NSView])->NSStackView` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L16) |
| `func button(_ b:NSButton,_ title:String,_ action:Selector)` | [L17](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L17) |
| `func pathCard(_ title:String,_ field:NSTextField,_ symbol:String)->NSBox` | [L18](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L18) |
| `override func loadView()` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L28) |
| `func refresh()` | [L62](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L62) |
| `func refreshStatus()` | [L76](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L76) |
| `func select(paths:[String])` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L77) |
| `func renderSelection()` | [L79](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L79) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L99](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L99) |
| `func tableView(_ tableView:NSTableView,viewFor tableColumn:NSTableColumn?,row:Int)->NSView?` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L100) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L107](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L107) |
| `func controlTextDidChange(_ notification:Notification)` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L108) |
| `func selectWorkspaceAssignment()` | [L109](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L109) |
| `@objc func renameSelected()` | [L110](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L110) |
| `@objc func removeSelected()` | [L111](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L111) |
| `@objc func verifyDraft()` | [L112](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L112) |
| `@objc func copyDraft()` | [L113](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L113) |
| `@objc func editStructure()` | [L114](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L114) |
| `@objc func previousRecords()` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L115) |
| `@objc func nextRecords()` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L116) |
| `@objc func exportManifest()` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L117) |
| `final class WorkflowStatusField:NSTextField` | [L120](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L120) |

## ReviewTestsUI.swift

| Declaration | Source |
|---|---|
| `private func captureOwnedView(_ view:NSView,to path:String) throws` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L3) |
| `func runReviewUIQA()` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L15) |
| `func runKnowledgeUIQA()` | [L38](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L38) |
| `func runDialog(_ name:String,fields:Int,popups:Int,_ action:()->Void)` | [L48](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L48) |
| `func descendants(_ v:NSView)->[NSView]` | [L52](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L52) |

## ScanComparisonUI.swift

| Declaration | Source |
|---|---|
| `final class ScanComparisonController:NSViewController,NSTableViewDataSource` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L3) |
| `init(current:LensStore,baseline:LensStore)` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L11) |
| `override func loadView()` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L13) |
| `func show()` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L27) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L28) |
| `func tableView(_ tableView:NSTableView,objectValueFor tableColumn:NSTableColumn?,row:Int)->Any?` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L29) |
| `func load()` | [L33](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L33) |
| `@objc func goNext()` | [L40](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L40) |
| `@objc func goPrevious()` | [L41](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L41) |
| `@objc func exportAll()` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/ScanComparisonUI.swift#L42) |

## SourcePreview.swift

| Declaration | Source |
|---|---|
| `struct PreviewSource` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L6) |
| `private final class PreviewGallery:NSStackView` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L9) |
| `enum SourcePreviewSafety` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L10) |
| `static func inspect(_ path:String,expected:Identity?=nil,allowFixture:Bool=false) throws -> PreviewSource` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L11) |
| `final class SourcePreviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L27) |
| `func cancelThumbnails()` | [L39](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L39) |
| `@objc func clearContents()` | [L40](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L40) |
| `@objc func loadThumbnails()` | [L41](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L41) |
| `func pumpThumbnails(_ token:Int)` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L46) |
| `func finish(_ image:NSImage?)` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L55) |
| `init(workspace:KonMagicController,path:String,allowFixture:Bool=false)` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L68) |
| `func label(_ value:String)->NSTextField` | [L71](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L71) |
| `func button(_ text:String,_ action:Selector)->NSButton` | [L72](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L72) |
| `func column(_ views:[NSView])->NSStackView` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L73) |
| `func row(_ views:[NSView])->NSStackView` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L74) |
| `override func loadView()` | [L75](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L75) |
| `func observe(_ path:String,viewContent:Bool=false)` | [L105](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L105) |
| `func renderMetadata(_ source:PreviewSource)` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L116) |
| `func loadFolder()` | [L121](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L121) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L130) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L131](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L131) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L136](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L136) |
| `func inspectSelection(_ path:String)` | [L137](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L137) |
| `func observeSelection(_ path:String,viewContent:Bool)` | [L138](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L138) |
| `func requestContent(_ source:PreviewSource)` | [L144](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L144) |
| `func rebuildGallery()` | [L151](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L151) |
| `@objc func openGallery(_ sender:NSButton)` | [L160](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L160) |
| `@objc func changePresentation()` | [L161](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L161) |
| `@objc func openRow()` | [L162](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L162) |
| `@objc func openSelection()` | [L163](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L163) |
| `@objc func refresh()` | [L164](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L164) |
| `@objc func parentFolder()` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L165) |
| `@objc func nextPage()` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L166) |
| `@objc func previousPage()` | [L167](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L167) |
| `func controlTextDidChange(_ obj:Notification)` | [L168](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L168) |
| `@objc func mapFolder()` | [L169](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L169) |
| `@objc func showTree()` | [L170](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L170) |
| `@objc func reveal()` | [L171](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L171) |
| `func showSourcePreview(_ path:String,allowFixture:Bool=false)` | [L175](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L175) |
| `@objc func previewSelectedSource()` | [L181](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L181) |
| `@objc func previewSelectedSource()` | [L184](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L184) |
| `@objc func richPreview()` | [L187](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreview.swift#L187) |

## SourcePreviewTests.swift

| Declaration | Source |
|---|---|
| `func runSourcePreviewTests(at directory:URL) throws -> Int` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreviewTests.swift#L4) |
| `func check(_ condition:Bool,_ message:String)throws` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreviewTests.swift#L6) |
| `func refuses(_ body:()throws->Void)throws` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/SourcePreviewTests.swift#L7) |

## Tests.swift

| Declaration | Source |
|---|---|
| `func runNativeTests() throws` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/Tests.swift#L4) |
| `func check(_ value:Bool,_ message:String)throws` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/Tests.swift#L9) |
| `func refuses(_ message:String,_ operation:()throws->Void)throws` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/Tests.swift#L10) |
| `func write(_ path:String,_ text:String)throws` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/Tests.swift#L13) |

## ToolkitTestsUI.swift

| Declaration | Source |
|---|---|
| `func runToolkitQA()` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitTestsUI.swift#L4) |

## ToolkitUI.swift

| Declaration | Source |
|---|---|
| `final class ToolkitCard:NSBox` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L4) |
| `init(step:String,title:String,body:String,symbol:String,tint:NSColor,actionTitle:String,target:AnyObject,action:Selector)` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L6) |
| `private final class ToolkitDocument:NSView` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L27) |
| `final class ToolkitController:NSViewController` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L29) |
| `init(workspace:KonMagicController)` | [L34](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L34) |
| `func label(_ text:String,size:CGFloat=13,weight:NSFont.Weight = .regular)->NSTextField` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L36) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L37](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L37) |
| `override func loadView()` | [L38](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L38) |
| `func updateDraft()` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L67) |
| `@objc func refresh()` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L74) |
| `@objc func observe()` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L93) |
| `@objc func discover()` | [L94](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L94) |
| `@objc func shape()` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L95) |
| `@objc func review()` | [L96](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L96) |
| `@objc func guide()` | [L97](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L97) |
| `@objc func documentation()` | [L98](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L98) |
| `@objc func showToolkit()` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L102) |
| `@objc func showWorkspace()` | [L103](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L103) |
| `@objc func showReview()` | [L104](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L104) |
| `func focusReview()` | [L105](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L105) |

## VolumeContext.swift

| Declaration | Source |
|---|---|
| `struct VolumeContext` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L5) |
| `static func command(_ arguments:[String],cancellation:CatalogueCancellation?=nil) throws -> [String:Any]` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L8) |
| `static func observe(_ root:String,cancellation:CatalogueCancellation?=nil) throws -> VolumeContext` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L35) |
| `@objc func showVolumeContext()` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L67) |
