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
| `func arrangeInitialPanes()` | [L157](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L157) |
| `func node(_ item:Any?) -> FolderNode?` | [L163](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L163) |
| `func outlineView(_ o:NSOutlineView,numberOfChildrenOfItem item:Any?) -> Int` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L165) |
| `func outlineView(_ o:NSOutlineView,child index:Int,ofItem item:Any?) -> Any` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L166) |
| `func outlineView(_ o:NSOutlineView,isItemExpandable item:Any) -> Bool` | [L170](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L170) |
| `func outlineView(_ o:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any) -> NSView?` | [L171](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L171) |
| `func outlineViewSelectionDidChange(_ n:Notification)` | [L179](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L179) |
| `func updateStructureControls()` | [L185](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L185) |
| `func selectDestination(_ id:String)` | [L192](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L192) |
| `func presentAssignments(_ paths:[String])` | [L197](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L197) |
| `func draggedPaths(_ pasteboard:NSPasteboard) -> [String]` | [L198](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L198) |
| `func outlineView(_ o:NSOutlineView,pasteboardWriterForItem item:Any) -> NSPasteboardWriting?` | [L203](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L203) |
| `func outlineView(_ o:NSOutlineView,validateDrop info:NSDraggingInfo,proposedItem item:Any?,proposedChildIndex index:Int) -> NSDragOperation` | [L206](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L206) |
| `func outlineView(_ o:NSOutlineView,acceptDrop info:NSDraggingInfo,item:Any?,childIndex:Int) -> Bool` | [L214](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L214) |
| `func numberOfRows(in tableView:NSTableView) -> Int` | [L225](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L225) |
| `func tableView(_ table:NSTableView,viewFor column:NSTableColumn?,row r:Int) -> NSView?` | [L226](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L226) |
| `func tableView(_ table:NSTableView,pasteboardWriterForRow row:Int) -> NSPasteboardWriting?` | [L240](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L240) |
| `func tableViewSelectionDidChange(_ n:Notification)` | [L244](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L244) |
| `func showDraftPaths()` | [L245](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L245) |
| `func refreshDraft()` | [L257](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L257) |
| `func refreshDraftLocally()` | [L258](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L258) |
| `@objc func showExplorer()` | [L280](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L280) |
| `@objc func showDiskLens()` | [L281](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L281) |
| `@objc func showPreferences()` | [L282](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L282) |
| `func loadSources()` | [L290](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L290) |
| `func controlTextDidChange(_ n:Notification)` | [L307](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L307) |
| `@objc func changeScope()` | [L310](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L310) |
| `func navigate(_ path:String)` | [L311](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L311) |
| `@objc func toggleHidden(_ sender:NSMenuItem)` | [L312](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L312) |
| `@objc func previousPage()` | [L313](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L313) |
| `@objc func nextPage()` | [L314](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L314) |
| `@objc func parentScope()` | [L315](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L315) |
| `@objc func openBucket()` | [L316](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L316) |
| `func grant(_ u:URL)` | [L317](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L317) |
| `func folderPanel(_ title:String, action:@escaping(URL)->Void)` | [L318](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L318) |
| `@objc func chooseScope()` | [L319](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L319) |
| `@objc func chooseOutput()` | [L320](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L320) |
| `@objc func connectCatalog()` | [L321](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L321) |
| `func ask(_ title:String, initial:String, then:(String)throws->Void)` | [L322](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L322) |
| `@objc func newFolder()` | [L328](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L328) |
| `@objc func renameFolder()` | [L341](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L341) |
| `@objc func removeFolder()` | [L342](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L342) |
| `@objc func undoDraft()` | [L345](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L345) |
| `@objc func assignSelection()` | [L346](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L346) |
| `@objc func removeAssignment()` | [L347](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L347) |
| `@objc func renameOutput()` | [L348](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L348) |
| `func setBusy(_ b:Bool)` | [L349](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L349) |
| `@objc func verifyPreview()` | [L350](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L350) |
| `func showPlan(_ p:CopyPlan)` | [L360](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L360) |
| `@objc func applyCopy()` | [L378](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L378) |
| `@objc func openJournal()` | [L392](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L392) |
| `func showError(_ e:Error)` | [L393](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L393) |
| `@objc func showGuide()` | [L394](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L394) |
| `final class KonMagicDelegate: NSObject, NSApplicationDelegate` | [L423](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L423) |
| `init(qa:Bool=false)` | [L429](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L429) |
| `func applicationDidFinishLaunching(_ n:Notification)` | [L430](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L430) |
| `func applicationShouldHandleReopen(_ sender:NSApplication,hasVisibleWindows:Bool)->Bool` | [L488](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L488) |
| `func applicationShouldTerminateAfterLastWindowClosed(_ sender:NSApplication) -> Bool` | [L489](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L489) |
| `func applicationShouldTerminate(_ sender:NSApplication) -> NSApplication.TerminateReply` | [L493](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L493) |
| `func runUIQA()` | [L497](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L497) |
| `func runExplorerQA()` | [L519](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L519) |
| `func runLensQA()` | [L558](https://github.com/madfam-org/konmagic/blob/main/Sources/App.swift#L558) |

## Catalog.swift

| Declaration | Source |
|---|---|
| `struct CatalogItem` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L5) |
| `private final class QueryBudget` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L24) |
| `final class Catalog` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L26) |
| `init(path: String,knowledge:KnowledgeStore?=nil)` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L29) |
| `func liveFolder(_ path:String,search:String="",offset:Int=0,includeHidden:Bool=false) throws -> [CatalogItem]` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L30) |
| `func query(scope: String?, search: String, offset: Int = 0) throws -> [CatalogItem]` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/Catalog.swift#L46) |

## CatalogueBenchmark.swift

| Declaration | Source |
|---|---|
| `struct PerformanceSample:Codable` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L5) |
| `struct PerformanceReport:Codable` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L9) |
| `func benchmarkMemory()->(UInt64,Int64)` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L20) |
| `func benchmarkSample(_ name:String,start:UInt64,value:Int64=0,status:String="ok",detail:String?=nil)->PerformanceSample` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L26) |
| `func validateBenchmarkState(_ state:URL) throws` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L30) |
| `func runCatalogueBenchmark() throws` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L35) |
| `func measure(_ name:String,repeats:Int=5,_ work:()throws->Int64)` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L42) |
| `func runJourneyBenchmark()` | [L83](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L83) |
| `func paint()` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L87) |
| `func measure(_ name:String,_ body:()->Void)` | [L88](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L88) |
| `func finish(_ error:String?=nil)` | [L89](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L89) |
| `func wait(_ name:String,start:UInt64,ready:@escaping ()->Bool,then:@escaping ()->Void)` | [L97](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueBenchmark.swift#L97) |

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
| `init(_ item:CatalogItem)` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L20) |
| `init(title:String,choices:[CatalogueDimension:String],level:Int)` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L21) |
| `final class CatalogueExplorerController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L24) |
| `init(workspace:KonMagicController)` | [L65](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L65) |
| `func text(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L67) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L70](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L70) |
| `func row(_ views:[NSView])->NSStackView` | [L71](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L71) |
| `func column(_ views:[NSView])->NSStackView` | [L72](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L72) |
| `func scroll(_ view:NSView)->NSScrollView` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L73) |
| `func setupTable(_ table:NSTableView,columns:[(String,String,CGFloat)])` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L74) |
| `override func loadView()` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L78) |
| `func refreshDestinations()` | [L172](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L172) |
| `func drillInto(_ choices:[CatalogueDimension:String])` | [L181](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L181) |
| `@objc func restoreDrillContext()` | [L187](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L187) |
| `func updateFilterChips()` | [L191](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L191) |
| `@objc func removeFilter(_ sender:NSButton)` | [L196](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L196) |
| `func showRecordedFolder(_ path:String)` | [L197](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L197) |
| `func slice()->CatalogueSlice` | [L200](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L200) |
| `func resetPaging()` | [L201](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L201) |
| `@objc func searchChanged()` | [L202](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L202) |
| `func controlTextDidChange(_ note:Notification)` | [L203](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L203) |
| `@objc func clearFilters()` | [L208](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L208) |
| `@objc func refresh()` | [L209](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L209) |
| `@objc func changeDataset()` | [L210](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L210) |
| `@objc func changePlace()` | [L221](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L221) |
| `@objc func changeDimension()` | [L222](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L222) |
| `@objc func changeMetric()` | [L223](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L223) |
| `@objc func changeVisualization()` | [L224](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L224) |
| `func updateMode()` | [L225](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L225) |
| `@objc func selectFacet()` | [L235](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L235) |
| `func loadPage(preserving paths:Set<String>=[])` | [L236](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L236) |
| `func loadSummary()` | [L273](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L273) |
| `func number(_ n:Int64)->String` | [L296](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L296) |
| `func renderSummary()` | [L297](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L297) |
| `func loadRoots()` | [L318](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L318) |
| `func loadTagTree()` | [L333](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L333) |
| `func outlineView(_ outline:NSOutlineView,numberOfChildrenOfItem item:Any?)->Int` | [L337](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L337) |
| `func outlineView(_ outline:NSOutlineView,child index:Int,ofItem item:Any?)->Any` | [L338](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L338) |
| `func outlineView(_ outline:NSOutlineView,isItemExpandable item:Any)->Bool` | [L339](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L339) |
| `func outlineView(_ outline:NSOutlineView,shouldExpandItem item:Any)->Bool` | [L340](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L340) |
| `func loadChildren(_ node:ExplorerNode)` | [L350](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L350) |
| `func outlineView(_ outline:NSOutlineView,viewFor tableColumn:NSTableColumn?,item:Any)->NSView?` | [L367](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L367) |
| `func outlineViewSelectionDidChange(_ note:Notification)` | [L370](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L370) |
| `func reloadSelectedTreeKnowledge()` | [L375](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L375) |
| `func outlineView(_ outline:NSOutlineView,pasteboardWriterForItem item:Any)->NSPasteboardWriting?` | [L398](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L398) |
| `func selectedRecords()->[CatalogItem]` | [L399](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L399) |
| `@objc func openTreeSelection()` | [L405](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L405) |
| `@objc func openObservation()` | [L412](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L412) |
| `func open(_ item:CatalogItem)` | [L413](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L413) |
| `@objc func parentFolder()` | [L414](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L414) |
| `@objc func nextPage()` | [L415](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L415) |
| `@objc func previousPage()` | [L416](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L416) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L417](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L417) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L418](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L418) |
| `func tableViewSelectionDidChange(_ note:Notification)` | [L430](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L430) |
| `func tableView(_ tableView:NSTableView,pasteboardWriterForRow row:Int)->NSPasteboardWriting?` | [L431](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L431) |
| `@objc func destinationChanged()` | [L432](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L432) |
| `func updateSelectionControls()` | [L433](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L433) |
| `func showMetadata()` | [L450](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L450) |
| `@objc func showReading()` | [L489](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L489) |
| `@objc func toggleContentDetails()` | [L496](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L496) |
| `@objc func selectContentFamily(_ sender:NSButton)` | [L497](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L497) |
| `@objc func loadGalleryThumbnails()` | [L498](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L498) |
| `@objc func clearGalleryImages()` | [L499](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L499) |
| `func updateResultState()` | [L500](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L500) |
| `@objc func previewPlacement()` | [L512](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L512) |
| `override func viewDidLayout()` | [L527](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L527) |
| `@objc func revealSource()` | [L528](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L528) |
| `@objc func returnToToolkit()` | [L529](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L529) |
| `@objc func editDestinations()` | [L530](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L530) |
| `@objc func assignSelected()` | [L531](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L531) |
| `func show()` | [L539](https://github.com/madfam-org/konmagic/blob/main/Sources/CatalogueExplorer.swift#L539) |

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

## ClassificationTestsUI.swift

| Declaration | Source |
|---|---|
| `func runClassificationJourneyQA()` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/ClassificationTestsUI.swift#L5) |
| `func check(_ value:Bool,_ label:String)` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/ClassificationTestsUI.swift#L9) |
| `func finish()` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/ClassificationTestsUI.swift#L10) |
| `func wait(_ ready:@escaping ()->Bool,deadline:Date=Date().addingTimeInterval(15),_ next:@escaping ()->Void)` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/ClassificationTestsUI.swift#L19) |
| `func descendants(_ v:NSView)->[NSView]` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/ClassificationTestsUI.swift#L36) |

## ContentGallery.swift

| Declaration | Source |
|---|---|
| `final class ContentGalleryCard:FriendlyPanel` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L5) |
| `init(_ item:CatalogItem,index:Int,owner:ContentGallery)` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L8) |
| `override func draw(_ rect:NSRect)` | [L23](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L23) |
| `final class ContentGallery:NSView` | [L27](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L27) |
| `init(owner:CatalogueExplorerController)` | [L34](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L34) |
| `override func viewDidMoveToSuperview()` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L36) |
| `func icon(_ item:CatalogItem)->NSImage` | [L44](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L44) |
| `func invalidatePage()` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L50) |
| `func rebuild()` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L53) |
| `override func setFrameSize(_ size:NSSize)` | [L58](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L58) |
| `func arrange()` | [L59](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L59) |
| `func syncSelection()` | [L74](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L74) |
| `func updateImages()` | [L75](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L75) |
| `@objc func toggle(_ sender:NSButton)` | [L76](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L76) |
| `@objc func choose(_ sender:NSButton)` | [L77](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L77) |
| `func clear()` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L78) |
| `func loadThumbnails()` | [L79](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L79) |
| `func pump(_ token:Int)` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/ContentGallery.swift#L82) |

## ContextHelp.swift

| Declaration | Source |
|---|---|
| `final class DialogValidation:NSObject` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L3) |
| `init(fields:[NSTextField]=[],popups:[NSPopUpButton]=[],evaluate:@escaping ()->Void)` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L6) |
| `@objc func refresh(_ sender:Any?)` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L13) |
| `func run(_ alert:NSAlert)->NSApplication.ModalResponse` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L14) |
| `func dialogAccessory(_ views:[NSView])->NSView` | [L17](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L17) |
| `func contextHelp(from sender:NSButton,title:String,body:String)->NSPopover` | [L28](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L28) |
| `@objc func showTips(_ sender:NSButton)` | [L36](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L36) |
| `@objc func showTips(_ sender:NSButton)` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L42) |
| `@objc func showWorkspaceTips(_ sender:NSButton)` | [L47](https://github.com/madfam-org/konmagic/blob/main/Sources/ContextHelp.swift#L47) |

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
| `init(workspace:KonMagicController)` | [L44](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L44) |
| `func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L46](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L46) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L47](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L47) |
| `func row(_ views:[NSView])->NSStackView` | [L48](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L48) |
| `func column(_ views:[NSView])->NSStackView` | [L49](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L49) |
| `override func loadView()` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L50) |
| `func refreshDestinations()` | [L147](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L147) |
| `func applyViewPreferences(_ value:LensPreferences)` | [L148](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L148) |
| `func show()` | [L153](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L153) |
| `func amount(_ n:Int64)->String` | [L154](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L154) |
| `func chooseFolder()->URL?` | [L155](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L155) |
| `@objc func chooseScan()` | [L156](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L156) |
| `@objc func chooseRecorded()` | [L157](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L157) |
| `@objc func recordedMachine()` | [L158](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L158) |
| `func beginScan(root:String,recorded:Bool=false,incremental:Bool=false)` | [L159](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L159) |
| `func open(_ store:LensStore)` | [L174](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L174) |
| `@objc func openRecent()` | [L185](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L185) |
| `@objc func stop()` | [L186](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L186) |
| `@objc func refresh()` | [L187](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L187) |
| `@objc func rescan()` | [L188](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L188) |
| `@objc func settingsChanged()` | [L189](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L189) |
| `func updateSnapshotPresentation()` | [L194](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L194) |
| `func updateSelectionPresentation(_ node:LensNode)` | [L203](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L203) |
| `func render()` | [L213](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L213) |
| `func windowDidResize(_ notification:Notification)` | [L230](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L230) |
| `func windowShouldClose(_ sender:NSWindow)->Bool` | [L231](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L231) |
| `func navigate(_ id:Int64,synchronize:Bool=true,remember:Bool=true)` | [L232](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L232) |
| `@objc func goParent()` | [L238](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L238) |
| `@objc func zoomSelection()` | [L239](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L239) |
| `@objc func focusUp()` | [L240](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L240) |
| `@objc func focusDown()` | [L241](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L241) |
| `func loadRows()` | [L242](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L242) |
| `@objc func previousRows()` | [L249](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L249) |
| `@objc func nextRows()` | [L250](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L250) |
| `func controlTextDidChange(_ obj:Notification)` | [L251](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L251) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L252](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L252) |
| `func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView?` | [L253](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L253) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L254](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L254) |
| `@objc func openRow()` | [L255](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L255) |
| `func select(_ node:LensNode)` | [L256](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L256) |
| `func date(_ value:Int64)->String` | [L260](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L260) |
| `@objc func destinationChanged()` | [L271](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L271) |
| `@objc func updateSourceControls()` | [L272](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L272) |
| `func currentURL() throws -> URL` | [L287](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L287) |
| `@objc func openSelected()` | [L295](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L295) |
| `@objc func reveal()` | [L296](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L296) |
| `@objc func showQuickLook()` | [L297](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L297) |
| `func numberOfPreviewItems(in panel:QLPreviewPanel!)->Int` | [L298](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L298) |
| `func previewPanel(_ panel:QLPreviewPanel!,previewItemAt index:Int)->QLPreviewItem!` | [L299](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L299) |
| `@objc func assign()` | [L300](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L300) |
| `@objc func reviewCleanup()` | [L301](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L301) |
| `@objc func returnToToolkit()` | [L302](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L302) |
| `@objc func storageGuide()` | [L303](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L303) |
| `@objc func toggleMetadata()` | [L304](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L304) |
| `@objc func toggleViewOptions()` | [L305](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L305) |
| `func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool` | [L306](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L306) |
| `@objc func showCatalogue()` | [L311](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L311) |
| `@objc func duplicate()` | [L312](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L312) |
| `@objc func twin()` | [L313](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L313) |
| `@objc func editMask()` | [L314](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L314) |
| `func remember(_ filter:LensFilter)` | [L315](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L315) |
| `@objc func filterView()` | [L316](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L316) |
| `@objc func scanFilters()` | [L317](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L317) |
| `@objc func filterLibrary()` | [L318](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L318) |
| `@objc func typeColors()` | [L319](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L319) |
| `func perform<T>(_ title:String,_ body:@escaping ()throws->T,completed:@escaping (T)->Void)` | [L320](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L320) |
| `@objc func loadScan()` | [L321](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L321) |
| `@objc func saveScan()` | [L322](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L322) |
| `@objc func notes()` | [L323](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L323) |
| `@objc func compareScan()` | [L324](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L324) |
| `@objc func exportImage()` | [L334](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L334) |
| `@objc func exportText()` | [L335](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensController.swift#L335) |

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

## DiskLensImage.swift

| Declaration | Source |
|---|---|
| `enum LensExportSize` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensImage.swift#L5) |
| `static func make(bounds:NSRect,width:CGFloat)->NSSize` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensImage.swift#L7) |
| `enum LensMapImage` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensImage.swift#L13) |
| `static func bitmap(_ result:LensMapResult,preferences:LensPreferences,size:NSSize,appearance:NSAppearance) throws -> NSBitmapImageRep` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensImage.swift#L14) |
| `func exportResolutionImage()` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensImage.swift#L26) |

## DiskLensMap.swift

| Declaration | Source |
|---|---|
| `struct LensTile` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L4) |
| `struct LensMapResult` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L5) |
| `enum LensDetail:Int,CaseIterable` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L6) |
| `final class LensMapBuilder` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L12) |
| `init(store:LensStore,info:LensSnapshot,preferences:LensPreferences,mask:LensFilter,cancellation:CatalogueCancellation,detail:LensDetail = .balanced,scale:CGFloat=1) throws` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L16) |
| `static func rectangles(_ weights:[Int64],rect:NSRect)->[NSRect]` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L20) |
| `func split(_ a:Int,_ b:Int,_ r:NSRect)` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L22) |
| `func build(focus:LensNode,bounds:NSRect)->LensMapResult` | [L32](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L32) |
| `private func visit(_ parent:LensNode,rect:NSRect,level:Int,reserved:Int) throws` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L50) |
| `private func add(_ node:LensNode,rect:NSRect,label:String?=nil)` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L87) |
| `final class LensCanvas:NSView` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L93) |
| `override func setFrameSize(_ newSize:NSSize)` | [L102](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L102) |
| `override func accessibilityRole()->NSAccessibility.Role?` | [L105](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L105) |
| `override func accessibilityLabel()->String?` | [L106](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L106) |
| `override func viewDidChangeEffectiveAppearance()` | [L107](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L107) |
| `func cachedColor(_ tile:LensTile)->NSColor` | [L108](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L108) |
| `override func updateTrackingAreas()` | [L112](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L112) |
| `func value(_ tile:LensTile)->String` | [L113](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L113) |
| `func color(_ value:String)->NSColor` | [L128](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L128) |
| `override func draw(_ rect:NSRect)` | [L140](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L140) |
| `func branchHeader(_ tile:LensTile)->NSRect` | [L172](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L172) |
| `func at(_ event:NSEvent)->LensTile?` | [L173](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L173) |
| `override func mouseMoved(with event:NSEvent)` | [L177](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L177) |
| `override func mouseDown(with event:NSEvent)` | [L178](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L178) |
| `override func scrollWheel(with event:NSEvent)` | [L179](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L179) |
| `override func keyDown(with event:NSEvent)` | [L180](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L180) |
| `func distance(_ tile:LensTile)->CGFloat` | [L196](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensMap.swift#L196) |

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
| `func sql(_ text:String) throws` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L116) |
| `func hex(_ data:Data)->String` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L117) |
| `func key(_ path:String) throws -> String` | [L118](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L118) |
| `func block(_ rows:[[Any]]) throws -> String` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensTests.swift#L119) |

## DiskLensWatcher.swift

| Declaration | Source |
|---|---|
| `final class LensWatcher` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L5) |
| `init?(root:String)` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L9) |
| `func consume()->Set<String>?` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWatcher.swift#L29) |

## DiskLensWorkspace.swift

| Declaration | Source |
|---|---|
| `final class LensViewport:NSScrollView` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L6) |
| `init(canvas:LensCanvas)` | [L9](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L9) |
| `override func tile()` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L16) |
| `func zoom(by factor:CGFloat)` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L21) |
| `func fitMap()` | [L25](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L25) |
| `@objc func toggleMapFocus()` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L29) |
| `func setMapFocus(_ focused:Bool)` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L30) |
| `@objc func toggleMapInspector()` | [L45](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L45) |
| `@objc func enterFullScreen()` | [L51](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L51) |
| `@objc func zoomInMap()` | [L52](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L52) |
| `@objc func zoomOutMap()` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L53) |
| `@objc func fitMap()` | [L54](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L54) |
| `@objc func goRoot()` | [L55](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L55) |
| `@objc func mapBack()` | [L56](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L56) |
| `@objc func mapForward()` | [L60](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L60) |
| `@objc func chooseAncestor()` | [L64](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L64) |
| `@objc func detailChanged()` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L67) |
| `func opticalZoomChanged()` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L68) |
| `func scheduleMapRender()` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L73) |
| `func updateMapNavigation()` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspace.swift#L78) |

## DiskLensWorkspaceTests.swift

| Declaration | Source |
|---|---|
| `func runStorageWorkspaceQA()` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L5) |
| `func check(_ condition:Bool,_ name:String)` | [L10](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L10) |
| `func advance()` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L35) |
| `func runStorageMapBenchmark()` | [L41](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L41) |
| `func advance()` | [L49](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L49) |
| `func poll()` | [L54](https://github.com/madfam-org/konmagic/blob/main/Sources/DiskLensWorkspaceTests.swift#L54) |

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
| `func advance()` | [L83](https://github.com/madfam-org/konmagic/blob/main/Sources/DocumentationCapture.swift#L83) |

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

## FriendlyUI.swift

| Declaration | Source |
|---|---|
| `enum FriendlyUI` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L4) |
| `static func ink(_ light:UInt32,_ dark:UInt32)->NSColor` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L5) |
| `func rgb(_ v:UInt32)->NSColor` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L6) |
| `static func wash(_ tint:NSColor)->NSColor` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L11) |
| `static func label(_ text:String,size:CGFloat=12,weight:NSFont.Weight = .regular,wrapping:Bool=false)->NSTextField` | [L12](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L12) |
| `static func image(_ symbol:String,tint:NSColor,size:CGFloat=20)->NSImageView` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L15) |
| `static func row(_ views:[NSView],spacing:CGFloat=10)->NSStackView` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L19) |
| `static func column(_ views:[NSView],spacing:CGFloat=10)->NSStackView` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L20) |
| `static func panel(_ content:NSView,tint:NSColor?=nil,padding:CGFloat=16)->FriendlyPanel` | [L21](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L21) |
| `static func scrollingContent(_ content:NSView)->NSScrollView` | [L26](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L26) |
| `static func scrollingPanel(_ content:NSView,width:CGFloat,tint:NSColor?=nil,padding:CGFloat=14)->FriendlyPanel` | [L32](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L32) |
| `static func button(_ title:String,symbol:String?=nil,tint:NSColor?=nil,target:AnyObject?,action:Selector)->NSButton` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L35) |
| `static func artwork(_ name:String)->NSImage?` | [L42](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L42) |
| `final class FriendlyCanvas:NSView` | [L50](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L50) |
| `override func draw(_ rect:NSRect)` | [L51](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L51) |
| `final class FriendlyDocument:NSView` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L53) |
| `final class FriendlyMascot:NSView` | [L54](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L54) |
| `init(kind:Int)` | [L56](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L56) |
| `override func draw(_ rect:NSRect)` | [L58](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L58) |
| `class FriendlyPanel:NSView` | [L63](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L63) |
| `init(tint:NSColor?=nil)` | [L66](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L66) |
| `override func draw(_ rect:NSRect)` | [L68](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L68) |
| `override func viewDidChangeEffectiveAppearance()` | [L73](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L73) |
| `final class FriendlyActionButton:NSButton` | [L78](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L78) |
| `init(title:String,tint:NSColor,target:AnyObject?,action:Selector)` | [L81](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L81) |
| `override func draw(_ dirtyRect:NSRect)` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L87) |
| `override func viewDidChangeEffectiveAppearance()` | [L100](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L100) |
| `final class FriendlyMetric:NSView` | [L103](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L103) |
| `init(title:String,symbol:String,tint:NSColor,compact:Bool=false)` | [L105](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L105) |
| `final class ToolkitHero:FriendlyPanel` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L116) |
| `init()` | [L118](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L118) |
| `override func draw(_ rect:NSRect)` | [L120](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L120) |
| `final class FriendlyTaskIcon:NSView` | [L136](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L136) |
| `init(kind:Int,tint:NSColor)` | [L138](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L138) |
| `override func draw(_ rect:NSRect)` | [L140](https://github.com/madfam-org/konmagic/blob/main/Sources/FriendlyUI.swift#L140) |

## InspectorTypography.swift

| Declaration | Source |
|---|---|
| `final class KonMagicInspector:NSTextView` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/InspectorTypography.swift#L5) |
| `func friendlyObservationDate(_ value:String)->String` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/InspectorTypography.swift#L24) |

## JourneySupport.swift

| Declaration | Source |
|---|---|
| `struct PlacementPair` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneySupport.swift#L4) |
| `struct PlacementPreview` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneySupport.swift#L7) |
| `static func make(_ items:[CatalogItem],node:String,workspace:Workspace) throws -> PlacementPreview` | [L11](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneySupport.swift#L11) |
| `final class ContentResultState:FriendlyPanel` | [L25](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneySupport.swift#L25) |
| `init(owner:CatalogueExplorerController)` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/JourneySupport.swift#L29) |

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
| `func runReviewTests(at directory:URL) throws -> Int` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L67) |
| `func check(_ result:Bool,_ message:String) throws` | [L69](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeTests.swift#L69) |

## KnowledgeUI.swift

| Declaration | Source |
|---|---|
| `func knowledgeAccessory(_ views:[NSView])->NSView` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L4) |
| `func knowledgeForm(_ labels:[String],_ fields:[NSTextField])->NSGridView` | [L7](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L7) |
| `func field(_ value:String="",placeholder:String="")->NSTextField` | [L13](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L13) |
| `func knowledgeChanged()` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L16) |
| `func reloadKnowledge()` | [L17](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L17) |
| `@objc func correctTags()` | [L24](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L24) |
| `@objc func collectionsMenu()` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L67) |
| `@objc func rulesMenu()` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L95) |
| `func createRule()` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L115) |
| `func previewRule(_ rule:ProposalRule)` | [L135](https://github.com/madfam-org/konmagic/blob/main/Sources/KnowledgeUI.swift#L135) |

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
| `func closed(_ host:PageHostController)` | [L79](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L79) |
| `@objc func showToolkit()` | [L80](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L80) |
| `@objc func showStorage()` | [L81](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L81) |
| `@objc func showContent()` | [L82](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L82) |
| `@objc func showStructure()` | [L83](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L83) |
| `@objc func showReview()` | [L84](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L84) |
| `@objc func back()` | [L85](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L85) |
| `@objc func forward()` | [L86](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L86) |
| `@objc func openCurrent()` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L87) |
| `@objc func chooseScope()` | [L88](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L88) |
| `@objc func connectCatalog()` | [L89](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L89) |
| `@objc func chooseOutput()` | [L90](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L90) |
| `@objc func verifyPreview()` | [L91](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L91) |
| `@objc func undoDraft()` | [L92](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L92) |
| `@objc func showGuide()` | [L93](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L93) |
| `@objc func showPreferences()` | [L94](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L94) |
| `@objc func toggleHidden(_ sender:NSMenuItem)` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L95) |
| `func validateUserInterfaceItem(_ item:NSValidatedUserInterfaceItem)->Bool` | [L96](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L96) |
| `@objc func openPage(_ sender:NSMenuItem)` | [L103](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L103) |
| `@objc func showRunning()` | [L104](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L104) |
| `final class PageEntry` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L115) |
| `init(id:String,title:String,controller:NSViewController,minimum:NSSize,base:KonMagicPage?=nil,duplicate:((KonMagicController)->NSViewController)?=nil)` | [L119](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L119) |
| `private final class PageDocument:NSView` | [L130](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L130) |
| `private final class PageViewport:NSScrollView` | [L131](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L131) |
| `init(controller:NSViewController,minimum:NSSize)` | [L134](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L134) |
| `override func tile()` | [L142](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L142) |
| `final class PageHostController:NSViewController,NSWindowDelegate` | [L152](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L152) |
| `init(workspace:KonMagicController,navigation:KonMagicNavigation,primary:Bool)` | [L162](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L162) |
| `func makeWindow(_ existing:NSWindow?=nil,saveFrame:Bool=true)` | [L164](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L164) |
| `override func loadView()` | [L176](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L176) |
| `func setup(_ b:NSButton,_ title:String,_ symbol:String?,_ action:Selector)` | [L178](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L178) |
| `func entry(_ page:KonMagicPage)->PageEntry` | [L205](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L205) |
| `func navigate(_ page:KonMagicPage)` | [L221](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L221) |
| `func show(_ entry:PageEntry,remember:Bool=true)` | [L222](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L222) |
| `func showDetail(_ controller:NSViewController,title:String,duplicate:@escaping(KonMagicController)->NSViewController)` | [L251](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L251) |
| `func updateNavigation()` | [L258](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L258) |
| `func updateMapFocus()` | [L282](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L282) |
| `@objc func continueJourney()` | [L293](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L293) |
| `@objc func changePage()` | [L303](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L303) |
| `@objc func goBack()` | [L304](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L304) |
| `@objc func goForward()` | [L305](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L305) |
| `@objc func showMain()` | [L306](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L306) |
| `@objc func showRunning()` | [L307](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L307) |
| `@objc func openCurrent()` | [L308](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L308) |
| `func windowShouldClose(_ sender:NSWindow)->Bool` | [L315](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L315) |
| `func windowWillClose(_ notification:Notification)` | [L318](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L318) |
| `func windowDidResize(_ notification:Notification)` | [L321](https://github.com/madfam-org/konmagic/blob/main/Sources/Navigation.swift#L321) |

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
| `init(workspace:KonMagicController)` | [L14](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L14) |
| `func label(_ value:String,size:CGFloat=12,weight:NSFont.Weight = .regular)->NSTextField` | [L16](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L16) |
| `func row(_ views:[NSView])->NSStackView` | [L17](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L17) |
| `func column(_ views:[NSView])->NSStackView` | [L18](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L18) |
| `func button(_ b:NSButton,_ title:String,_ action:Selector)` | [L19](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L19) |
| `func pathCard(_ title:String,_ field:NSTextField,_ symbol:String)->FriendlyPanel` | [L23](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L23) |
| `override func loadView()` | [L29](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L29) |
| `@objc func reviewGuide()` | [L85](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L85) |
| `func updateVerificationPresentation()` | [L86](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L86) |
| `func refresh()` | [L101](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L101) |
| `func refreshStatus()` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L115) |
| `func select(paths:[String])` | [L123](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L123) |
| `func renderSelection()` | [L125](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L125) |
| `func numberOfRows(in tableView:NSTableView)->Int` | [L147](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L147) |
| `func tableView(_ tableView:NSTableView,viewFor tableColumn:NSTableColumn?,row:Int)->NSView?` | [L148](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L148) |
| `func tableViewSelectionDidChange(_ notification:Notification)` | [L165](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L165) |
| `func updateInventoryPresentation()` | [L166](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L166) |
| `@objc func toggleExactEvidence()` | [L167](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L167) |
| `func controlTextDidChange(_ notification:Notification)` | [L168](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L168) |
| `func selectWorkspaceAssignment()` | [L169](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L169) |
| `@objc func renameSelected()` | [L170](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L170) |
| `@objc func removeSelected()` | [L171](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L171) |
| `@objc func verifyDraft()` | [L172](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L172) |
| `@objc func copyDraft()` | [L173](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L173) |
| `@objc func editStructure()` | [L174](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L174) |
| `@objc func previousRecords()` | [L175](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L175) |
| `@objc func nextRecords()` | [L176](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L176) |
| `@objc func exportManifest()` | [L177](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L177) |
| `final class WorkflowStatusField:NSTextField` | [L180](https://github.com/madfam-org/konmagic/blob/main/Sources/ReorganizationReviewUI.swift#L180) |

## ReviewTestsUI.swift

| Declaration | Source |
|---|---|
| `private func captureOwnedView(_ view:NSView,to path:String) throws` | [L3](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L3) |
| `func runReviewUIQA()` | [L15](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L15) |
| `func runKnowledgeUIQA()` | [L38](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L38) |
| `func runDialog(_ name:String,fields:Int,popups:Int,_ action:()->Void)` | [L49](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L49) |
| `func descendants(_ v:NSView)->[NSView]` | [L53](https://github.com/madfam-org/konmagic/blob/main/Sources/ReviewTestsUI.swift#L53) |

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
| `final class ToolkitCard:FriendlyPanel` | [L4](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L4) |
| `init(step:String,title:String,body:String,kind:Int,tint:NSColor,actionTitle:String,target:AnyObject,action:Selector)` | [L6](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L6) |
| `private final class ToolkitDocument:NSView` | [L20](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L20) |
| `final class ToolkitController:NSViewController` | [L22](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L22) |
| `init(workspace:KonMagicController)` | [L30](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L30) |
| `func label(_ text:String,size:CGFloat=13,weight:NSFont.Weight = .regular)->NSTextField` | [L32](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L32) |
| `func button(_ title:String,_ action:Selector)->NSButton` | [L33](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L33) |
| `override func loadView()` | [L34](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L34) |
| `func updateDraft()` | [L87](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L87) |
| `@objc func refresh()` | [L95](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L95) |
| `@objc func observe()` | [L112](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L112) |
| `@objc func discover()` | [L113](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L113) |
| `@objc func shape()` | [L114](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L114) |
| `@objc func review()` | [L115](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L115) |
| `@objc func guide()` | [L116](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L116) |
| `@objc func documentation()` | [L117](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L117) |
| `@objc func showToolkit()` | [L120](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L120) |
| `@objc func showWorkspace()` | [L121](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L121) |
| `@objc func showReview()` | [L122](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L122) |
| `func focusReview()` | [L123](https://github.com/madfam-org/konmagic/blob/main/Sources/ToolkitUI.swift#L123) |

## VolumeContext.swift

| Declaration | Source |
|---|---|
| `struct VolumeContext` | [L5](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L5) |
| `static func command(_ arguments:[String],cancellation:CatalogueCancellation?=nil) throws -> [String:Any]` | [L8](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L8) |
| `static func observe(_ root:String,cancellation:CatalogueCancellation?=nil) throws -> VolumeContext` | [L35](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L35) |
| `@objc func showVolumeContext()` | [L67](https://github.com/madfam-org/konmagic/blob/main/Sources/VolumeContext.swift#L67) |
