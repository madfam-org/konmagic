import Foundation
import Darwin

func runKnowledgeTests(at directory:URL,catalogueURL:URL) throws -> Int {
    var checks=0
    func check(_ result:Bool,_ message:String) throws {guard result else {throw KonMagicError("Knowledge test: "+message)};checks+=1}
    func refuses(_ message:String,_ body:()throws->Void) throws {do {try body()} catch {checks+=1;return};throw KonMagicError("Expected knowledge refusal: "+message)}
    let privateDir=directory.appendingPathComponent("knowledge-private")
    _ = try WorkspaceStore(directory:privateDir)
    let knowledge=try KnowledgeStore(directory:privateDir),reader=Catalog(path:catalogueURL.path,knowledge:knowledge),original=try Data(contentsOf:catalogueURL)
    let first="/synthetic/file-001.txt",second="/synthetic/file-002.txt",protected="/synthetic/file-003.txt"
    let initialStamp=try reader.summaryStamp()
    try knowledge.correct(paths:[first,second],tags:["owner":"Personal","project":"Family celebration","family":"Family memories"],note:"Human identification")
    var slice=CatalogueSlice();slice.facets=[.owner:"Personal",.family:"Family memories"]
    let page=try reader.cataloguePage(slice),summary=try reader.summary(slice)
    try check(page.items.map(\.path)==[first,second] && page.items.allSatisfy(\.manual) && summary.count==2 && summary.bytes==200 && summary.readings==2,"effective pages and aggregate maps must agree on corrected classifications")
    let all=try reader.summary()
    try check(all.count==207 && all.groups(.confidenceBand).first(where:{$0.value=="Human reviewed"})?.count==2,"corrections conserve all observations and human review provenance")
    try check(try reader.query(scope:"/synthetic",search:"",offset:0).first?.tags["owner"]=="Personal","workspace and Explorer share the same corrected tags")
    try check(try reader.summaryStamp() != initialStamp,"tag corrections invalidate private aggregate caches")
    let reloaded=try KnowledgeStore(directory:privateDir)
    try check(reloaded.snapshot().corrections[first]?.note=="Human identification" && reloaded.snapshot().undo.count==1,"human corrections and undo persist across restart")
    try knowledge.correct(paths:["/synthetic"],tags:["lifecycle":"Archived"],note:"Folder only")
    try check(try reader.observation(at:protected)?.tags["lifecycle"]=="Active","active child observations never inherit archive status from a corrected parent")
    try refuses("protection downgrade") {try knowledge.correct(paths:[protected],tags:["barrier":"user_data"],note:"")}
    try check(try reader.observation(at:protected)?.barrier=="credentials","protection boundaries cannot be overridden by classification")
    try knowledge.reset(paths:[first]);try check(try reader.observation(at:first)?.tags["owner"]=="Organization","reset restores retained original inference")
    try knowledge.undoCorrection();try check(try reader.observation(at:first)?.tags["owner"]=="Personal","reset has a durable reversible correction history")
    try knowledge.correct(paths:[first],tags:["project":""],note:"Unassigned")
    slice.facets=[.project:"Unassigned"]
    try check(try reader.cataloguePage(slice).items.map(\.path)==[first],"an explicitly unassigned category remains searchable")
    var collectionSlice=CatalogueSlice();collectionSlice.facets=[.family:"Family memories"];collectionSlice.search="file"
    let collection=SavedCollection(name:"Family",slice:collectionSlice,mode:3,dimension:.project,metric:1)
    try knowledge.save(collection)
    let gallery=SavedCollection(name:"Gallery",slice:collectionSlice,mode:5,dimension:.family,metric:0)
    try knowledge.save(gallery)
    try check(try KnowledgeStore(directory:privateDir).snapshot().collections.contains(where:{$0.id==gallery.id && $0.mode==5}),"gallery collections persist and reopen as a supported visualization")
    var workspace=Workspace.initial();let node=workspace.nodes.first(where:{$0.name=="Movies"})!.id
    let rule=ProposalRule(name:"Reviewed collection",slice:collectionSlice,destination:node,recipe:NameRecipe(prefix:"Keep-",suffix:"",find:"file-",replacement:"item-"))
    try knowledge.save(rule)
    let restored=try KnowledgeStore(directory:privateDir).snapshot()
    try check(restored.collections.first?.slice==collectionSlice && restored.rules.first?.destination==node,"saved views and explicit rule destinations persist")
    try check(try rule.recipe.output("file-001.PDF")=="Keep-item-001.PDF","output naming preserves the original extension")
    try workspace.assign([first],to:node)
    workspace.assignments[0].outputName="Chosen memory.txt"
    let placement=try PlacementPreview.make([CatalogItem(id:0,path:first,name:"file-001.txt",kind:"file",bytes:1,context:""),CatalogItem(id:0,path:second,name:"file-002.txt",kind:"file",bytes:1,context:"")],node:node,workspace:workspace)
    try check(placement.pairs.count==2 && placement.pairs.first?.destination.hasSuffix("/Chosen memory.txt")==true && placement.newAssignments==1,"full placement preview preserves manual output names and counts new assignments")
    workspace.assignments[0].outputName="file-001.txt"
    let candidates=try reader.cataloguePage(CatalogueSlice()).items
    let proposal=try DraftProposal.make(items:Array(candidates.prefix(3)),rule:rule,workspace:workspace)
    try check(proposal.assignments.map(\.source)==[second] && proposal.held.count==2,"rules hold existing manual choices and protected observations")
    var preview=workspace;try proposal.apply(to:&preview)
    try check(preview.assignments.count==2 && preview.assignments.first?.outputName=="file-001.txt","proposal acceptance edits the draft and preserves previous manual names")
    try refuses("draft changed after preview") {try proposal.apply(to:&preview)}
    var colliding=candidates[0];colliding=CatalogItem(id:0,path:"/synthetic/another/file-002.txt",name:"file-002.txt",kind:"file",bytes:100,context:"")
    let collision=try DraftProposal.make(items:[candidates[1],colliding],rule:rule,workspace:workspace)
    try check(collision.assignments.count==1 && collision.held.count==1,"output-name collisions are held before draft acceptance")
    let bookmarkStamp=try reader.summaryStamp();try knowledge.removeCollection(collection.id)
    try check(try reader.summaryStamp()==bookmarkStamp,"collection edits do not invalidate semantic caches")
    try check(try Data(contentsOf:catalogueURL)==original,"all corrections, queries, collections and proposals leave Atlas bytes identical")
    var st=stat();guard lstat(knowledge.file.path,&st)==0 else {throw SafeFS.fail("Knowledge fixture metadata")}
    try check(st.st_mode & 0o077==0,"human decisions are stored privately")
    print("KNOWLEDGE_TESTS passed=\(checks); synthetic decisions only; source operations=0")
    return checks
}

func runReviewTests(at directory:URL) throws -> Int {
    var checks=0
    func check(_ result:Bool,_ message:String) throws {guard result else {throw KonMagicError("Review test: "+message)};checks+=1}
    let sources=directory.appendingPathComponent("duplicate-source"),saved=directory.appendingPathComponent("review-private")
    try FileManager.default.createDirectory(at:sources,withIntermediateDirectories:true)
    try FileManager.default.createDirectory(at:saved,withIntermediateDirectories:true,attributes:[.posixPermissions:0o700])
    for (name,text) in [("one.txt","same data"),("two.txt","same data"),("different.txt","diff data")] {try Data(text.utf8).write(to:sources.appendingPathComponent(name))}
    guard link(sources.appendingPathComponent("one.txt").path,sources.appendingPathComponent("hardlink.txt").path)==0 else {throw SafeFS.fail("Review hardlink fixture")}
    let scanner=try LensScanner(directory:saved,cancellation:CatalogueCancellation()),store=try scanner.run(root:sources.path)
    let original=try Data(contentsOf:store.url),group=try store.duplicateSizes(cancellation:CatalogueCancellation())
    try check(group.groups.count==1 && group.groups[0].count==3,"same-size candidates exclude hard-link aliases")
    let members=try store.duplicateMembers(bytes:9),proof=try store.proveDuplicates(nodes:members,cancellation:CatalogueCancellation(),allowFixture:true)
    try check(proof.checked==3 && proof.matches.count==1 && proof.matches.first?.value.count==2,"complete hashes distinguish equal-size but different data")
    try check(proof.details.contains("No file is marked safe to delete"),"hash proof never authorizes deletion")
    let cancel=CatalogueCancellation();cancel.cancel();do {_ = try store.proveDuplicates(nodes:members,cancellation:cancel,allowFixture:true);throw KonMagicError("Cancelled hash unexpectedly succeeded")} catch {try check(cancel.cancelled,"cancelled proof stops before data reads")}
    try Data("new! data".utf8).write(to:sources.appendingPathComponent("two.txt"))
    let changed=try store.proveDuplicates(nodes:members,cancellation:CatalogueCancellation(),allowFixture:true)
    try check(changed.held.contains(where:{$0.contains("two.txt")}) && changed.matches.isEmpty,"changed identities are held before hashing")
    try check(try Data(contentsOf:store.url)==original,"duplicate review leaves retained scan byte-identical")
    // More than one comparison page; every change must remain reachable.
    let old=try LensWriter(directory:saved,cancellation:CatalogueCancellation()),new=try LensWriter(directory:saved,cancellation:CatalogueCancellation())
    var root=LensNode();root.kind=1;root.name="Synthetic";_ = try old.append(root);_ = try new.append(root)
    for i in 0..<601 {var n=LensNode();n.parent=1;n.name=String(format:"change-%03d.txt",i);n.bytes=1;n.allocated=1;n.links=1;_ = try new.append(n)}
    var snapshot=LensSnapshot();snapshot.root="/synthetic";snapshot.status="complete";_ = try old.finish(snapshot);_ = try new.finish(snapshot)
    let oldStore=LensStore(url:old.url),newStore=LensStore(url:new.url),page1=try newStore.differencePage(oldStore,cancellation:CatalogueCancellation()),page2=try newStore.differencePage(oldStore,cursor:page1.next,cancellation:CatalogueCancellation())
    try check(page1.rows.count==500 && page2.rows.count==101 && page2.next==nil && Set(page1.rows.map(\.path)).isDisjoint(with:page2.rows.map(\.path)),"comparison pages cover all changes without omission or repetition")
    let export=saved.appendingPathComponent("changes.tsv"),count=try newStore.exportDifferences(oldStore,to:export,cancellation:CatalogueCancellation())
    try check(count==601 && String(data:try Data(contentsOf:export),encoding:.utf8)!.split(separator:"\n").count==602,"comparison exports every change, including later pages")
    print("REVIEW_TESTS passed=\(checks); synthetic hashes only; actual source operations=0")
    return checks
}
