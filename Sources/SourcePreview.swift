import AppKit
import Quartz
import QuickLookThumbnailing
import Darwin

struct PreviewSource {
    let path:String,identity:Identity,directory:Bool
}
private final class PreviewGallery:NSStackView {override var isFlipped:Bool {true}}
enum SourcePreviewSafety {
    static func inspect(_ path:String,expected:Identity?=nil,allowFixture:Bool=false) throws -> PreviewSource {
        if !allowFixture {try SafeFS.sourceGuard(path)}
        let components=try SafeFS.components(path)
        let names=allowFixture ? Array(components.suffix(1)):components
        guard !names.contains(where:SafeFS.guardedName) else {throw KonMagicError("Protected collections are held from content preview.")}
        let parent=try SafeFS.openDirectory(URL(fileURLWithPath:path).deletingLastPathComponent().path);defer {close(parent)}
        let st=try SafeFS.info(parent,URL(fileURLWithPath:path).lastPathComponent)
        guard SafeFS.isFile(st) || SafeFS.isDirectory(st),st.st_flags & 0x40000000==0 else {throw KonMagicError("Linked, non-ordinary or cloud-only sources stay held; no content was requested.")}
        let identity=Identity(st)
        if let expected=expected,identity != expected {throw KonMagicError("Source changed since this preview. Refresh current metadata before viewing its contents.")}
        return PreviewSource(path:path,identity:identity,directory:SafeFS.isDirectory(st))
    }
}

// A source viewer never edits the draft or executes a transfer. Selection reads
// metadata; original file content is requested only by an explicit view action.
final class SourcePreviewController:NSViewController,NSTableViewDataSource,NSTableViewDelegate,NSSearchFieldDelegate {
    weak var workspace:KonMagicController?
    let initialPath:String,allowFixture:Bool
    let table=NSTableView(),search=NSSearchField(),heading=NSTextField(labelWithString:"Source preview"),location=NSTextField(wrappingLabelWithString:""),status=NSTextField(wrappingLabelWithString:"Inspecting current metadata…")
    let metadata=KonMagicInspector(),preview=QLPreviewView(frame:.zero,style:.normal)!
    let viewButton=NSButton(),previous=NSButton(),next=NSButton(),gallery:NSStackView=PreviewGallery(),mode=NSSegmentedControl(labels:["List","Icon gallery"],trackingMode:.selectOne,target:nil,action:nil)
    var listScroll:NSScrollView!,galleryScroll:NSScrollView!
    var observed:PreviewSource?,folder:String?,items:[CatalogItem]=[],offset=0,generation=0,busy=false
    let work=DispatchQueue(label:"org.madfam.konmagic.source-preview",qos:.userInitiated)
    var activityChanged:(()->Void)?
    var thumbnailGeneration=0,thumbnailInFlight=0,thumbnailIndex=0
    var thumbnailCandidates:[CatalogItem]=[],thumbnailImages:[String:NSImage]=[:],thumbnailRequests:[String:QLThumbnailGenerator.Request]=[:]
    func cancelThumbnails() {thumbnailGeneration+=1;for request in thumbnailRequests.values {QLThumbnailGenerator.shared.cancel(request)};thumbnailRequests=[:];thumbnailInFlight=0;thumbnailCandidates=[];thumbnailIndex=0;thumbnailImages=[:]}
    @objc func clearContents() {generation+=1;cancelThumbnails();preview.previewItem=nil;busy=false;activityChanged?();viewButton.isEnabled=observed?.directory==false;rebuildGallery();status.stringValue="Preview content and thumbnail requests cleared. Originals retained."}
    @objc func loadThumbnails() {
        guard workspace?.busy != true else {status.stringValue="Wait for verification or copying before loading thumbnails.";return}
        cancelThumbnails();mode.selectedSegment=1;changePresentation();thumbnailCandidates=Array(items.filter {$0.kind=="file"}.prefix(24));thumbnailIndex=0
        status.stringValue="Explicit content request: up to 24 thumbnails, three at a time. Unsupported or held sources retain file icons.";pumpThumbnails(thumbnailGeneration)
    }
    func pumpThumbnails(_ token:Int) {
        guard token==thumbnailGeneration else{return}
        while thumbnailInFlight<3 && thumbnailIndex<thumbnailCandidates.count {
            let item=thumbnailCandidates[thumbnailIndex];thumbnailIndex+=1;thumbnailInFlight+=1;busy=true;activityChanged?()
            work.async {[weak self] in guard let self=self else{return};let result=Result {try SourcePreviewSafety.inspect(item.path,allowFixture:self.allowFixture)}
                DispatchQueue.main.async {guard self.thumbnailGeneration==token else{return}
                    guard let source=try? result.get(),!source.directory,source.identity.bytes<=128*1024*1024,self.workspace?.busy != true else {self.thumbnailInFlight-=1;self.pumpThumbnails(token);return}
                    let request=QLThumbnailGenerator.Request(fileAt:URL(fileURLWithPath:source.path),size:CGSize(width:130,height:80),scale:2,representationTypes:.thumbnail)
                    self.thumbnailRequests[source.path]=request
                    func finish(_ image:NSImage?) {
                        guard self.thumbnailGeneration==token,self.thumbnailRequests[source.path] === request else{return}
                        self.thumbnailRequests[source.path]=nil;self.thumbnailInFlight-=1
                        if let image=image {self.thumbnailImages[source.path]=image}
                        self.rebuildGallery();self.pumpThumbnails(token)
                    }
                    QLThumbnailGenerator.shared.generateBestRepresentation(for:request) {thumbnail,_ in DispatchQueue.main.async {finish(thumbnail?.nsImage)}}
                    DispatchQueue.main.asyncAfter(deadline:.now()+15) {if self.thumbnailGeneration==token,self.thumbnailRequests[source.path] === request {QLThumbnailGenerator.shared.cancel(request);finish(nil)}}
                }
            }
        }
        if thumbnailInFlight==0 {busy=false;activityChanged?();status.stringValue="\(thumbnailImages.count) native content thumbnails loaded from \(thumbnailCandidates.count) requested files · held/unsupported formats use system icons. Clear contents releases this view’s images."}
    }
    init(workspace:KonMagicController,path:String,allowFixture:Bool=false) {self.workspace=workspace;initialPath=path;self.allowFixture=allowFixture;super.init(nibName:nil,bundle:nil)}
    required init?(coder:NSCoder) {fatalError("Use exact source")}
    deinit {for request in thumbnailRequests.values {QLThumbnailGenerator.shared.cancel(request)};preview.close()}
    func label(_ value:String)->NSTextField {let t=NSTextField(labelWithString:value);t.lineBreakMode = .byTruncatingMiddle;return t}
    func button(_ text:String,_ action:Selector)->NSButton {let b=NSButton(title:text,target:self,action:action);b.bezelStyle = .rounded;return b}
    func column(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .vertical;s.alignment = .leading;s.spacing=10;return s}
    func row(_ views:[NSView])->NSStackView {let s=NSStackView(views:views);s.orientation = .horizontal;s.spacing=8;return s}
    override func loadView() {
        view=WorkspaceCanvas(frame:NSRect(x:0,y:0,width:1380,height:850))
        heading.font=NSFont.systemFont(ofSize:20,weight:.semibold);location.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular);location.isSelectable=true;status.font=NSFont.systemFont(ofSize:11);status.textColor = .secondaryLabelColor
        search.placeholderString="Filter this folder’s names";search.delegate=self;search.widthAnchor.constraint(greaterThanOrEqualToConstant:180).isActive=true
        mode.selectedSegment=0;mode.target=self;mode.action=#selector(changePresentation)
        table.delegate=self;table.dataSource=self;table.rowHeight=46;table.usesAlternatingRowBackgroundColors=true;table.target=self;table.doubleAction=#selector(openRow)
        for (id,name,width) in [("name","Current files & folders",330.0),("size","Logical size",110.0)] {let c=NSTableColumn(identifier:NSUserInterfaceItemIdentifier(id));c.title=name;c.width=CGFloat(width);table.addTableColumn(c)}
        table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle;table.setAccessibilityLabel("Current source metadata. Select to inspect; double-click explicitly views a file or enters a folder.")
        listScroll=NSScrollView();listScroll.documentView=table;listScroll.hasVerticalScroller=true;listScroll.borderType = .noBorder
        gallery.orientation = .vertical;gallery.alignment = .leading;gallery.spacing=12
        galleryScroll=NSScrollView();galleryScroll.documentView=gallery;galleryScroll.hasVerticalScroller=true;galleryScroll.borderType = .noBorder;galleryScroll.isHidden=true
        let browser=NSView();browser.addSubview(listScroll);browser.addSubview(galleryScroll)
        for s in [listScroll!,galleryScroll!] {s.translatesAutoresizingMaskIntoConstraints=false;NSLayoutConstraint.activate([s.leadingAnchor.constraint(equalTo:browser.leadingAnchor),s.trailingAnchor.constraint(equalTo:browser.trailingAnchor),s.topAnchor.constraint(equalTo:browser.topAnchor),s.bottomAnchor.constraint(equalTo:browser.bottomAnchor)])}
        previous.title="Previous";previous.target=self;previous.action=#selector(previousPage);next.title="Next 200";next.target=self;next.action=#selector(nextPage)
        for b in [previous,next] {b.bezelStyle = .rounded}
        viewButton.title="View file contents";viewButton.target=self;viewButton.action=#selector(openSelection);viewButton.bezelStyle = .rounded;viewButton.setAccessibilityLabel("Explicitly view the selected original with macOS Quick Look after current checks")
        let left=column([row([button("↑ Parent",#selector(parentFolder)),mode]),search,browser,row([previous,next])]);left.widthAnchor.constraint(equalToConstant:470).isActive=true
        browser.heightAnchor.constraint(greaterThanOrEqualToConstant:450).isActive=true
        for v in [browser,search] {v.widthAnchor.constraint(equalTo:left.widthAnchor).isActive=true}
        metadata.isEditable=false;metadata.isSelectable=true;metadata.font=NSFont.monospacedSystemFont(ofSize:11,weight:.regular)
        let info=NSScrollView();info.documentView=metadata;info.hasVerticalScroller=true;info.heightAnchor.constraint(equalToConstant:160).isActive=true;metadata.isVerticallyResizable=true;metadata.autoresizingMask = [.width];metadata.textContainer?.widthTracksTextView=true
        preview.autostarts=false;preview.setAccessibilityLabel("Native Quick Look content viewer")
        let right=column([label("CURRENT SOURCE · READ ONLY"),info,viewButton,preview]);preview.heightAnchor.constraint(greaterThanOrEqualToConstant:330).isActive=true
        for v in [info,preview] {v.widthAnchor.constraint(equalTo:right.widthAnchor).isActive=true}
        let panes=row([left,right]);panes.alignment = .top;right.widthAnchor.constraint(greaterThanOrEqualToConstant:650).isActive=true
        let controls=row([button("Refresh metadata",#selector(refresh)),button("Map this folder",#selector(mapFolder)),button("Recorded folder tree",#selector(showTree)),button("Load up to 24 thumbnails",#selector(loadThumbnails)),button("Clear contents",#selector(clearContents)),button("Reveal in Finder",#selector(reveal)),NSView()])
        let outer=column([heading,location,controls,panes,status]);outer.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(outer)
        NSLayoutConstraint.activate([outer.leadingAnchor.constraint(equalTo:view.leadingAnchor,constant:18),outer.trailingAnchor.constraint(equalTo:view.trailingAnchor,constant:-18),outer.topAnchor.constraint(equalTo:view.topAnchor,constant:18),outer.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant:-18),panes.widthAnchor.constraint(equalTo:outer.widthAnchor),location.widthAnchor.constraint(equalTo:outer.widthAnchor),status.widthAnchor.constraint(equalTo:outer.widthAnchor)])
        observe(initialPath,viewContent:true)
    }
    func observe(_ path:String,viewContent:Bool=false) {
        cancelThumbnails();generation+=1;let serial=generation;busy=true;activityChanged?();viewButton.isEnabled=false;preview.previewItem=nil;status.stringValue="Checking current source identity without following links…"
        work.async {[weak self] in guard let self=self else{return};let result=Result {try SourcePreviewSafety.inspect(path,allowFixture:self.allowFixture)}
            DispatchQueue.main.async {guard self.generation==serial else{return};self.busy=false;self.activityChanged?()
                do {let source=try result.get();self.observed=source;self.location.stringValue=source.path;self.heading.stringValue=source.directory ? "Explore this folder":"View this file";self.renderMetadata(source)
                    if source.directory {self.folder=source.path;self.offset=0;self.loadFolder()}
                    else {self.folder=nil;self.items=[];self.table.reloadData();self.rebuildGallery();self.previous.isEnabled=false;self.next.isEnabled=false;self.viewButton.isEnabled=true;if viewContent {self.requestContent(source)}}
                } catch {self.observed=nil;self.items=[];self.table.reloadData();self.rebuildGallery();self.metadata.string=error.localizedDescription;self.status.stringValue="Preview held. No original content requested."}
            }
        }
    }
    func renderMetadata(_ source:PreviewSource) {
        let i=source.identity
        metadata.string="\(source.path)\n\n\(source.directory ? "Ordinary folder":"Regular file") · \(ByteCountFormatter.string(fromByteCount:i.bytes,countStyle:.file)) logical\nDevice/inode: \(i.device) / \(i.inode)\nModified: \(ISO8601DateFormatter().string(from:Date(timeIntervalSince1970:Double(i.modified))))\n\nCurrent metadata is not a full-data hash. Selection requests no file body. View file contents explicitly requests macOS Quick Look. Originals remain intact."
        viewButton.isEnabled = !source.directory
    }
    func loadFolder() {
        guard let path=folder,let reader=workspace?.catalog else{return};cancelThumbnails();generation+=1;let serial=generation,start=offset,query=search.stringValue;busy=true;activityChanged?()
        work.async {[weak self] in guard let self=self else{return};let result=Result {_ = try SourcePreviewSafety.inspect(path,allowFixture:self.allowFixture);return try reader.liveFolder(path,search:query,offset:start)}
            DispatchQueue.main.async {guard self.generation==serial else{return};self.busy=false;self.activityChanged?();switch result {
                case .success(let rows):self.items=rows;self.table.reloadData();self.rebuildGallery();self.previous.isEnabled=start>0;self.next.isEnabled=rows.count==200;self.status.stringValue="\(rows.count) entries · current metadata page \(start/200+1) · gallery uses system file icons, not body thumbnails. Double-click explicitly views a file or enters a folder."
                case .failure(let e):self.items=[];self.table.reloadData();self.rebuildGallery();self.status.stringValue=e.localizedDescription
            }}
        }
    }
    func numberOfRows(in tableView:NSTableView)->Int {items.count}
    func tableView(_ tableView:NSTableView,viewFor column:NSTableColumn?,row:Int)->NSView? {
        let item=items[row];if column?.identifier.rawValue=="size" {return label(item.kind=="directory" ? "Folder":ByteCountFormatter.string(fromByteCount:item.bytes,countStyle:.file))}
        let icon=NSImageView();icon.image=NSWorkspace.shared.icon(forFile:item.path);icon.widthAnchor.constraint(equalToConstant:26).isActive=true;icon.heightAnchor.constraint(equalToConstant:26).isActive=true
        let t=label(item.name);t.toolTip=item.path;return self.row([icon,t])
    }
    func tableViewSelectionDidChange(_ notification:Notification) {let r=table.selectedRow;guard r>=0,r<items.count else{return};inspectSelection(items[r].path)}
    func inspectSelection(_ path:String) {observeSelection(path,viewContent:false)}
    func observeSelection(_ path:String,viewContent:Bool) {
        cancelThumbnails();generation+=1;let serial=generation;preview.previewItem=nil;viewButton.isEnabled=false;busy=true;activityChanged?()
        work.async {[weak self] in guard let self=self else{return};let result=Result {try SourcePreviewSafety.inspect(path,allowFixture:self.allowFixture)}
            DispatchQueue.main.async {guard self.generation==serial else{return};self.busy=false;self.activityChanged?();do {let source=try result.get();self.observed=source;self.renderMetadata(source);self.status.stringValue="Selection inspected; original body unopened.";if viewContent {if source.directory {self.observe(path)} else {self.requestContent(source)}}} catch {self.observed=nil;self.metadata.string=error.localizedDescription;self.status.stringValue="Selected source remains held."}}
        }
    }
    func requestContent(_ source:PreviewSource) {
        guard workspace?.busy != true else {status.stringValue="Wait for verification or copying before requesting content.";return}
        generation+=1;let serial=generation;busy=true;activityChanged?();viewButton.isEnabled=false
        work.async {[weak self] in guard let self=self else{return};let result=Result {try SourcePreviewSafety.inspect(source.path,expected:source.identity,allowFixture:self.allowFixture)}
            DispatchQueue.main.async {guard self.generation==serial else{return};self.busy=false;self.activityChanged?();do {let current=try result.get();guard !current.directory,self.workspace?.busy != true else {self.status.stringValue="Content request held during verification or copying.";return};self.preview.previewItem=URL(fileURLWithPath:current.path) as NSURL;self.preview.refreshPreviewItem();self.viewButton.isEnabled=true;self.status.stringValue="Explicit native Quick Look request · supported formats use your Mac’s preview providers · viewing does not verify hashes or approve copying."} catch {self.preview.previewItem=nil;self.status.stringValue=error.localizedDescription}}
        }
    }
    func rebuildGallery() {
        for v in gallery.views {gallery.removeView(v);v.removeFromSuperview()}
        for start in stride(from:0,to:items.count,by:3) {
            var cards:[NSView]=[]
            for i in start..<min(start+3,items.count) {let item=items[i],b=NSButton(title:item.name,target:self,action:#selector(openGallery(_:)));b.tag=i;b.image=thumbnailImages[item.path] ?? NSWorkspace.shared.icon(forFile:item.path);b.imagePosition = .imageAbove;b.imageScaling = .scaleProportionallyDown;b.bezelStyle = .regularSquare;b.toolTip="Explicitly open: "+item.path;b.setAccessibilityLabel("Open "+item.name);b.widthAnchor.constraint(equalToConstant:145).isActive=true;b.heightAnchor.constraint(equalToConstant:110).isActive=true;cards.append(b)}
            gallery.addView(row(cards),in:.top)
        }
        gallery.frame=NSRect(x:0,y:0,width:470,height:max(450,CGFloat((items.count+2)/3)*122))
    }
    @objc func openGallery(_ sender:NSButton) {guard sender.tag>=0,sender.tag<items.count else{return};observeSelection(items[sender.tag].path,viewContent:true)}
    @objc func changePresentation() {listScroll.isHidden=mode.selectedSegment==1;galleryScroll.isHidden=mode.selectedSegment==0}
    @objc func openRow() {let r=table.clickedRow;guard r>=0,r<items.count else{return};observeSelection(items[r].path,viewContent:true)}
    @objc func openSelection() {if let source=observed {if source.directory {observe(source.path)} else {requestContent(source)}}}
    @objc func refresh() {observe(folder ?? initialPath)}
    @objc func parentFolder() {guard let path=folder ?? observed?.path else{return};observe(URL(fileURLWithPath:path).deletingLastPathComponent().path)}
    @objc func nextPage() {offset+=200;loadFolder()}
    @objc func previousPage() {offset=max(0,offset-200);loadFolder()}
    func controlTextDidChange(_ obj:Notification) {offset=0;loadFolder()}
    @objc func mapFolder() {guard let path=folder ?? observed.map({URL(fileURLWithPath:$0.path).deletingLastPathComponent().path}),let w=workspace,!w.busy else{return};w.showDiskLens();w.lenses.first?.beginScan(root:path)}
    @objc func showTree() {guard let w=workspace else{return};let path=folder ?? URL(fileURLWithPath:initialPath).deletingLastPathComponent().path;w.showExplorer();if let e=w.explorer {e.dataset.selectItem(at:1);e.folder=path;e.changeDataset();e.mode.selectedSegment=1;e.changeVisualization()}}
    @objc func reveal() {NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath:observed?.path ?? initialPath)])}
}

extension KonMagicController {
    func showSourcePreview(_ path:String,allowFixture:Bool=false) {
        let c=SourcePreviewController(workspace:self,path:path,allowFixture:allowFixture)
        pageHost?.showDetail(c,title:"File & folder viewer",duplicate:{SourcePreviewController(workspace:$0,path:path,allowFixture:allowFixture)})
    }
}
extension CatalogueExplorerController {
    @objc func previewSelectedSource() {if let path=selectedRecords().first?.path {workspace?.showSourcePreview(path)}}
}
extension ReorganizationReviewController {
    @objc func previewSelectedSource() {if let source=selected?.source {workspace?.showSourcePreview(source)}}
}
extension DiskLensController {
    @objc func richPreview() {do {let url=try currentURL();workspace?.showSourcePreview(url.path)} catch {status.stringValue=error.localizedDescription}}
}
