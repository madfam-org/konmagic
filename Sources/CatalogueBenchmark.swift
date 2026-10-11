import AppKit
import Darwin
import SQLite3

struct PerformanceSample:Codable {
    let name:String,status:String,milliseconds:Double,value:Int64,residentBytes:UInt64,peakResidentBytes:Int64
    var detail:String? = nil
}
struct PerformanceReport:Codable {
    var schema=1,appVersion="0.5.1",mode:String
    var date=ISO8601DateFormatter().string(from:Date())
    var system=ProcessInfo.processInfo.operatingSystemVersionString
    var logicalCPUs=ProcessInfo.processInfo.activeProcessorCount
    var physicalMemoryBytes=ProcessInfo.processInfo.physicalMemory
    var originalBodyRequests=0,inputDatabaseWrites=0,userDecisionWrites=0,approvedCopies=0
    var coverage:[String:Int64]=[:]
    var samples:[PerformanceSample]=[]
    var notes:[String]=[]
}
func benchmarkMemory()->(UInt64,Int64) {
    var info=mach_task_basic_info(),count=mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size/MemoryLayout<natural_t>.size)
    let status=withUnsafeMutablePointer(to:&info) {pointer in pointer.withMemoryRebound(to:integer_t.self,capacity:Int(count)) {task_info(mach_task_self_,task_flavor_t(MACH_TASK_BASIC_INFO),$0,&count)}}
    var usage=rusage();getrusage(RUSAGE_SELF,&usage)
    return (status==KERN_SUCCESS ? info.resident_size : 0,Int64(usage.ru_maxrss))
}
func benchmarkSample(_ name:String,start:UInt64,value:Int64=0,status:String="ok",detail:String?=nil)->PerformanceSample {
    let elapsed=Double(DispatchTime.now().uptimeNanoseconds-start)/1_000_000,memory=benchmarkMemory()
    return PerformanceSample(name:name,status:status,milliseconds:elapsed,value:value,residentBytes:memory.0,peakResidentBytes:memory.1,detail:detail)
}
func validateBenchmarkState(_ state:URL) throws {
    guard state.path.hasPrefix("/private/tmp/konmagic-journey-wave-") || state.path.hasPrefix("/private/tmp/konmagic-benchmark-") else {throw KonMagicError("Benchmarks require a fresh owned private temporary state; the working app state is never a benchmark output.")}
    let fd=try SafeFS.openDirectory(state.path);defer {close(fd)}
    var info=stat();guard fstat(fd,&info)==0,info.st_uid==getuid(),info.st_mode & 0o077==0 else {throw KonMagicError("Benchmark state must be owned and private.")}
}
func runCatalogueBenchmark() throws {
    let env=ProcessInfo.processInfo.environment
    guard let path=env["KONMAGIC_BENCHMARK_CATALOGUE"],let directory=env["KONMAGIC_BENCHMARK_STATE"] else {throw KonMagicError("Set KONMAGIC_BENCHMARK_CATALOGUE and KONMAGIC_BENCHMARK_STATE to read-only input and private benchmark state.")}
    let state=URL(fileURLWithPath:directory);try validateBenchmarkState(state)
    let knowledge=try KnowledgeStore(directory:state),reader=Catalog(path:path,knowledge:knowledge),disk=DiskCatalogue(path:URL(fileURLWithPath:path).deletingLastPathComponent().appendingPathComponent("disk-coverage.sqlite3").path)
    let stamp=try reader.summaryStamp()
    var report=PerformanceReport(mode:"catalogue-queries"),summary:CatalogueSummary?,first:CataloguePage?
    func measure(_ name:String,repeats:Int=5,_ work:()throws->Int64) {
        print("BENCHMARK_STAGE "+name);fflush(stdout)
        for _ in 0..<repeats {
            let start=DispatchTime.now().uptimeNanoseconds
            do {let count=try autoreleasepool(invoking:work);report.samples.append(benchmarkSample(name,start:start,value:count))}
            catch {report.samples.append(benchmarkSample(name,start:start,status:"held",detail:error.localizedDescription));break}
        }
    }
    measure("database_connect") {let db=try AtlasDatabase(path);return Int64(sqlite3_db_readonly(db.db,"main"))}
    measure("all_content_first_page") {let page=try reader.cataloguePage(CatalogueSlice());first=page;return Int64(page.items.count)}
    if let cursor=first?.next {measure("all_content_next_page") {var s=CatalogueSlice();s.cursor=cursor;return Int64(try reader.cataloguePage(s).items.count)}}
    let downloads=FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads").path
    measure("downloads_direct_page") {var s=CatalogueSlice();s.folder=downloads;s.directChildren=true;return Int64(try reader.cataloguePage(s).items.count)}
    measure("name_path_tag_search",repeats:3) {var s=CatalogueSlice();s.search="pdf";return Int64(try reader.cataloguePage(s).items.count)}
    measure("indexed_content_search",repeats:3) {var s=CatalogueSlice();s.search="design";s.contentSearch=true;return Int64(try reader.cataloguePage(s).items.count)}
    measure("uncached_full_summary",repeats:1) {let value=try reader.summary();summary=value;return value.count}
    if let summary=summary {
        report.coverage["taggedObservations"]=summary.count;report.coverage["retainedReadings"]=summary.readings;report.coverage["aggregatePartitions"]=Int64(summary.partitions.count)
        try SafeFS.writeRecord(SummaryCache(stamp:stamp,summary:summary),at:state.appendingPathComponent("catalogue-summary.json"))
        measure("cached_full_summary") {try reader.cachedSummary(in:state).count}
        if let partition=summary.partitions.max(by:{$0.count<$1.count}) {
            let facets:[CatalogueDimension:String]=[.owner:partition.values["owner"] ?? "Unassigned",.family:partition.values["family"] ?? "Unassigned"]
            measure("owner_family_intersection",repeats:3) {var s=CatalogueSlice();s.facets=facets;return Int64(try reader.cataloguePage(s).items.count)}
            measure("cached_facet_intersection") {summary.sliced(facets).count}
        }
        measure("facet_grouping") {Int64(summary.groups(.family).count)}
    }
    measure("disk_overview",repeats:3) {let o=try disk.overview();report.coverage["metadataLedgerEntries"]=o.count;report.coverage["coverageExceptions"]=o.exceptions;return o.count}
    measure("disk_downloads_page",repeats:3) {Int64(try disk.folder(downloads).items.count)}
    measure("query_cancellation",repeats:3) {
        let token=CatalogueCancellation();var s=CatalogueSlice();s.search="konmagic-benchmark-deliberately-absent-search-token"
        DispatchQueue.global(qos:.utility).asyncAfter(deadline:.now()+0.02) {token.cancel()}
        do {_ = try reader.summary(s,cancellation:token);return 0} catch {guard token.cancelled else {throw error};return 1}
    }
    guard try reader.summaryStamp()==stamp else {throw KonMagicError("The input catalogue changed during the benchmark; repeat with stable input.")}
    report.notes=["Process-cold connections; filesystem caches were not flushed.","Five samples for small queries, three for search/disk/cancellation, one uncached full aggregation.","Peak resident memory is the Darwin process high-water mark; resident samples include SQLite and decoding.","Query timings do not measure physical display latency. Coverage scopes overlap and must not be added.","Only catalogue metadata/index queries; no source bodies, source hashes, cloud downloads or output copies."]
    try SafeFS.writeRecord(report,at:state.appendingPathComponent("catalogue-benchmark.json"))
    print("CATALOGUE_BENCHMARK completed=true; samples=\(report.samples.count); held=\(report.samples.filter {$0.status != "ok"}.count); originalBodyRequests=0; userDecisionWrites=0; inputDatabaseWrites=0")
}

extension KonMagicDelegate {
    func runJourneyBenchmark() {
        let host=navigation.main!,original=controller.store.value
        var report=PerformanceReport(mode:"native-journey")
        window.title="KonMagic · Private read-only performance check";window.setContentSize(NSSize(width:1480,height:960))
        func paint() {self.window.contentView?.layoutSubtreeIfNeeded();self.window.contentView?.displayIfNeeded();self.window.display()}
        func measure(_ name:String,_ body:()->Void) {let start=DispatchTime.now().uptimeNanoseconds;body();paint();report.samples.append(benchmarkSample(name,start:start));print("BENCHMARK_STAGE "+name);fflush(stdout)}
        func finish(_ error:String?=nil) {
            if let error=error {report.notes.append(error)}
            self.controller.plan=nil
            do {try self.controller.store.change {$0=original};report.notes += ["Isolated app state restored; working app decisions were never edited.","Native display-cycle timings, not physical input-to-photon measurements.","No thumbnails, Quick Look bodies, full hashes, source transfers or approved copies requested."];try SafeFS.writeRecord(report,at:self.controller.store.directory.appendingPathComponent("journey-benchmark.json"))}
            catch {fputs("Private benchmark report could not be saved.\n",stderr);exit(1)}
            print("JOURNEY_BENCHMARK completed=\(error==nil); samples=\(report.samples.count); originalBodyRequests=0; userDecisionWrites=0; approvedCopies=0")
            if error != nil {exit(1)};NSApp.terminate(nil)
        }
        func wait(_ name:String,start:UInt64,ready:@escaping ()->Bool,then:@escaping ()->Void) {
            if ready() {paint();report.samples.append(benchmarkSample(name,start:start,value:Int64(self.controller.explorer?.records.count ?? 0)));then();return}
            if Double(DispatchTime.now().uptimeNanoseconds-start)>100_000_000_000 {finish("Timed out waiting for "+name);return}
            DispatchQueue.main.asyncAfter(deadline:.now()+0.05) {wait(name,start:start,ready:ready,then:then)}
        }
        measure("toolkit_display") {host.navigate(.toolkit)}
        let start=DispatchTime.now().uptimeNanoseconds;host.navigate(.content)
        wait("content_initial_page",start:start,ready:{self.controller.explorer?.pageLoading==false}) {
            guard let e=self.controller.explorer else {finish("Content unavailable");return}
            wait("content_initial_aggregates",start:start,ready:{!e.summaryLoading}) {
                e.folder=nil;e.filters=[:];e.search.stringValue="";let pageStart=DispatchTime.now().uptimeNanoseconds;e.refresh()
                wait("all_content_page",start:pageStart,ready:{!e.pageLoading && !e.summaryLoading}) {
                    let indexes=Array(e.records.indices.filter {e.records[$0].kind=="file"}.prefix(3))
                    guard !indexes.isEmpty,let node=original.nodes.first else {finish("No bounded regular-file page or destination available");return}
                    e.table.selectRowIndexes(IndexSet(indexes),byExtendingSelection:false)
                    measure("inspect_metadata_presentation") {e.showMetadata()}
                    e.destination.select(e.destination.itemArray.first {$0.representedObject as? String==node.id});e.destinationChanged()
                    measure("exact_placement_calculation") {_ = try? PlacementPreview.make(e.selectedRecords(),node:node.id,workspace:self.controller.store.value)}
                    let timer=Timer(timeInterval:0.4,repeats:false) {_ in NSApp.modalWindow?.orderOut(nil);NSApp.abortModal()};RunLoop.main.add(timer,forMode:.modalPanel)
                    measure("classification_editor_open_and_cancel") {e.correctTags()};timer.invalidate()
                    do {let records=e.selectedRecords();try self.controller.store.change {$0.assignments=records.map {Assignment(source:$0.path,node:node.id,outputName:$0.name)}};self.controller.refreshDraft();measure("assigned_review_display") {self.controller.presentAssignments(records.map(\.path))}}
                    catch {finish("Isolated draft preparation failed");return}
                    measure("gallery_first_display") {host.navigate(.content);e.mode.selectedSegment=5;e.updateMode()}
                    for _ in 0..<3 {measure("gallery_rebuild") {e.mode.selectedSegment=0;e.updateMode();e.mode.selectedSegment=5;e.updateMode()}}
                    measure("semantic_map_display") {e.mode.selectedSegment=3;e.updateMode()}
                    for _ in 0..<3 {for page in KonMagicPage.allCases {measure("warm_page_"+page.title.lowercased()) {host.navigate(page)}}}
                    report.coverage["taggedObservations"]=e.allSummary?.count ?? 0
                    report.coverage["metadataLedgerEntries"]=e.diskOverview?.count ?? 0
                    finish()
                }
            }
        }
    }
}
