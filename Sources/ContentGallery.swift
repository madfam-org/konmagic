import AppKit
import QuickLookThumbnailing
import UniformTypeIdentifiers

final class ContentGalleryCard:FriendlyPanel {
    let image=NSImageView(),check=NSButton(),index:Int
    var chosen=false {didSet {check.state=chosen ? .on:.off;needsDisplay=true}}
    init(_ item:CatalogItem,index:Int,owner:ContentGallery) {
        self.index=index;super.init()
        check.setButtonType(.switch);check.title="";check.tag=index;check.target=owner;check.action=#selector(ContentGallery.toggle(_:));check.setAccessibilityLabel("Select "+item.name)
        image.image=owner.images[item.path] ?? owner.icon(item);image.imageScaling = .scaleProportionallyDown
        let thumbnail=NSButton(title:"",target:owner,action:#selector(ContentGallery.choose(_:)));thumbnail.isBordered=false;thumbnail.tag=index;thumbnail.setAccessibilityLabel("Inspect "+item.name);thumbnail.toolTip=item.path
        thumbnail.addSubview(image);image.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([image.leadingAnchor.constraint(equalTo:thumbnail.leadingAnchor),image.trailingAnchor.constraint(equalTo:thumbnail.trailingAnchor),image.topAnchor.constraint(equalTo:thumbnail.topAnchor),image.bottomAnchor.constraint(equalTo:thumbnail.bottomAnchor),thumbnail.heightAnchor.constraint(equalToConstant:100)])
        let name=FriendlyUI.label(item.name,size:11,weight:.semibold);name.lineBreakMode = .byTruncatingMiddle;name.toolTip=item.path
        let size=FriendlyUI.label(item.kind=="directory" ? "Folder · hierarchy retained":ByteCountFormatter.string(fromByteCount:item.bytes,countStyle:.file)+" · "+URL(fileURLWithPath:item.path).pathExtension.uppercased(),size:10);size.textColor=FriendlyUI.muted
        let tags=FriendlyUI.label([item.tags["owner"],item.tags["family"]].compactMap {$0}.joined(separator:" · "),size:10);tags.textColor=FriendlyUI.violet;tags.lineBreakMode = .byTruncatingTail
        let content=FriendlyUI.column([FriendlyUI.row([check,NSView()]),thumbnail,name,size,tags],spacing:5);content.translatesAutoresizingMaskIntoConstraints=false;addSubview(content)
        NSLayoutConstraint.activate([content.leadingAnchor.constraint(equalTo:leadingAnchor,constant:10),content.trailingAnchor.constraint(equalTo:trailingAnchor,constant:-10),content.topAnchor.constraint(equalTo:topAnchor,constant:8),content.bottomAnchor.constraint(lessThanOrEqualTo:bottomAnchor,constant:-8)])
        for v in [thumbnail,name,size,tags] {v.widthAnchor.constraint(equalTo:content.widthAnchor).isActive=true}
    }
    required init?(coder:NSCoder) {fatalError("Use an observation")}
    override func draw(_ rect:NSRect) {super.draw(rect);if chosen {FriendlyUI.violet.setStroke();let p=NSBezierPath(roundedRect:bounds.insetBy(dx:1,dy:1),xRadius:18,yRadius:18);p.lineWidth=2;p.stroke()}}
}

// A bounded page gallery. Merely changing visualization never requests a file body.
final class ContentGallery:NSView {
    weak var owner:CatalogueExplorerController?
    var cards:[ContentGalleryCard]=[],images:[String:NSImage]=[:],requests:[String:QLThumbnailGenerator.Request]=[:]
    var candidates:[CatalogItem]=[],next=0,inFlight=0,generation=0
    private var renderedPage:Int?,arranging=false,icons:[String:NSImage]=[:],scrollObserver:NSObjectProtocol?
    let work=DispatchQueue(label:"org.madfam.konmagic.content-thumbnails",qos:.utility)
    override var isFlipped:Bool {true}
    init(owner:CatalogueExplorerController) {self.owner=owner;super.init(frame:.zero)}
    required init?(coder:NSCoder) {fatalError("Use an explorer")}
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if let observer=scrollObserver {NotificationCenter.default.removeObserver(observer);scrollObserver=nil}
        if let clip=enclosingScrollView?.contentView {
            clip.postsBoundsChangedNotifications=true
            scrollObserver=NotificationCenter.default.addObserver(forName:NSView.boundsDidChangeNotification,object:clip,queue:nil) {[weak self] _ in self?.arrange()}
        }
    }
    func icon(_ item:CatalogItem)->NSImage {
        let ext=URL(fileURLWithPath:item.name).pathExtension.lowercased(),type=item.kind=="directory" ? UTType.folder : UTType(filenameExtension:ext) ?? .data,key=type.identifier
        if let image=icons[key] {return image}
        // Type icons use retained metadata; resolving an original custom icon is unnecessary.
        let image=NSWorkspace.shared.icon(for:type);icons[key]=image;return image
    }
    func invalidatePage() {
        clear();renderedPage=nil;cards.forEach {$0.removeFromSuperview()};cards=[];icons=[:]
    }
    func rebuild() {
        guard let owner=owner,owner.displayedView==5,!owner.selectionPending else{return}
        if renderedPage != owner.generation {cards.forEach {$0.removeFromSuperview()};cards=[];renderedPage=owner.generation}
        arrange();syncSelection()
    }
    override func setFrameSize(_ size:NSSize) {super.setFrameSize(size);arrange()}
    func arrange() {
        guard !arranging,let owner=owner,owner.displayedView==5,!owner.selectionPending,renderedPage==owner.generation else{return}
        arranging=true;defer {arranging=false}
        let width=max(300,superview?.bounds.width ?? frame.width),columns=max(2,min(4,Int(width/180))),gap:CGFloat=12
        let cardWidth=(width-CGFloat(columns+1)*gap)/CGFloat(columns)
        let count=min(200,owner.records.count),height=max(200,CGFloat((count+columns-1)/columns)*218+gap)
        if frame.size != NSSize(width:width,height:height) {super.setFrameSize(NSSize(width:width,height:height))}
        let visible=visibleRect,first=max(0,Int(visible.minY/218)-1)*columns,last=min(count,(Int(max(visible.maxY,400)/218)+2)*columns)
        let wanted=Set(first..<max(first,last))
        cards.filter {!wanted.contains($0.index)}.forEach {$0.removeFromSuperview()};cards.removeAll {!wanted.contains($0.index)}
        let existing=Set(cards.map(\.index))
        for i in wanted.subtracting(existing).sorted() where i<count {let card=ContentGalleryCard(owner.records[i],index:i,owner:self);addSubview(card);cards.append(card)}
        cards.sort {$0.index<$1.index}
        for card in cards {let i=card.index;card.frame=NSRect(x:gap+CGFloat(i%columns)*(cardWidth+gap),y:gap+CGFloat(i/columns)*218,width:cardWidth,height:206);card.chosen=owner.table.selectedRowIndexes.contains(i)}
    }
    func syncSelection() {guard let owner=owner else{return};for card in cards {card.chosen=owner.table.selectedRowIndexes.contains(card.index)};owner.selectionImage.image=owner.selectedRecords().first.flatMap {images[$0.path]} ?? NSImage(systemSymbolName:"doc.text.magnifyingglass",accessibilityDescription:nil)}
    func updateImages() {guard let owner=owner else{return};for card in cards where card.index<owner.records.count {let item=owner.records[card.index];card.image.image=images[item.path] ?? icon(item)};syncSelection()}
    @objc func toggle(_ sender:NSButton) {guard let owner=owner,!owner.selectionPending,sender.tag>=0,sender.tag<owner.records.count else{return};if sender.state == .on {owner.table.selectRowIndexes(IndexSet(integer:sender.tag),byExtendingSelection:true)} else {owner.table.deselectRow(sender.tag)};owner.showMetadata();syncSelection()}
    @objc func choose(_ sender:NSButton) {guard let owner=owner,!owner.selectionPending,sender.tag>=0,sender.tag<owner.records.count else{return};owner.table.selectRowIndexes(IndexSet(integer:sender.tag),byExtendingSelection:NSApp.currentEvent?.modifierFlags.contains(.command)==true);owner.showMetadata();syncSelection();if let event=NSApp.currentEvent,[NSEvent.EventType.leftMouseDown,.leftMouseUp].contains(event.type),event.clickCount==2 {owner.open(owner.records[sender.tag])}}
    func clear() {generation+=1;for request in requests.values {QLThumbnailGenerator.shared.cancel(request)};requests=[:];candidates=[];inFlight=0;next=0;let hadImages = !images.isEmpty;images=[:];if hadImages {updateImages()}}
    func loadThumbnails() {
        guard let owner=owner,!owner.selectionPending,owner.workspace?.busy != true else{return};clear();candidates=Array(owner.records.filter {$0.kind=="file"}.prefix(24));owner.status.stringValue="Explicit thumbnail request · up to 24 regular files · three at a time · held sources keep icons";pump(generation)
    }
    func pump(_ token:Int) {
        guard token==generation,let owner=owner else{return}
        while inFlight<3,next<candidates.count {
            let item=candidates[next];next+=1;inFlight+=1
            // The fixture allowance is available only inside validated documentation capture.
            let fixture=CommandLine.arguments.contains("--documentation-capture") && item.path.hasPrefix(owner.workspace!.store.directory.deletingLastPathComponent().appendingPathComponent("Sources").path+"/")
            work.async {[weak self] in guard let self=self else{return};let result=Result {try SourcePreviewSafety.inspect(item.path,allowFixture:fixture)}
                DispatchQueue.main.async {guard self.generation==token else{return}
                    guard let source=try? result.get(),!source.directory,source.identity.bytes<=128*1024*1024,self.owner?.workspace?.busy != true else {self.inFlight-=1;self.pump(token);return}
                    let request=QLThumbnailGenerator.Request(fileAt:URL(fileURLWithPath:source.path),size:CGSize(width:240,height:160),scale:2,representationTypes:.thumbnail);self.requests[source.path]=request
                    let finish:(NSImage?)->Void={[weak self] image in guard let self=self,self.generation==token,self.requests[source.path] === request else{return};self.requests[source.path]=nil;self.inFlight-=1;if let image=image {self.images[source.path]=image};self.updateImages();self.pump(token)}
                    QLThumbnailGenerator.shared.generateBestRepresentation(for:request) {thumbnail,_ in DispatchQueue.main.async {finish(thumbnail?.nsImage)}}
                    DispatchQueue.main.asyncAfter(deadline:.now()+15) {if self.generation==token,self.requests[source.path] === request {QLThumbnailGenerator.shared.cancel(request);finish(nil)}}
                }
            }
        }
        if inFlight==0 {owner.status.stringValue="\(images.count) content thumbnails · \(candidates.count) requested · unsupported/held sources use system icons"}
    }
    deinit {if let observer=scrollObserver {NotificationCenter.default.removeObserver(observer)};for request in requests.values {QLThumbnailGenerator.shared.cancel(request)}}
}
