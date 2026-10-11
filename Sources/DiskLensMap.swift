import AppKit
import SQLite3

struct LensTile {var node:LensNode,frame:NSRect,label:String,masked=false,virtual=false,path=""}
struct LensMapResult {var tiles:[LensTile]=[],branches:[LensTile]=[],omittedZero:Int64=0,collapsed=0;var totals=LensTotals()}
final class LensMapBuilder {
    let store:LensStore,info:LensSnapshot,reader:AtlasDatabase,preferences:LensPreferences,mask:LensFilter,cancellation:CatalogueCancellation
    var result=LensMapResult()
    init(store:LensStore,info:LensSnapshot,preferences:LensPreferences,mask:LensFilter,cancellation:CatalogueCancellation) throws {
        self.store=store;self.info=info;self.preferences=preferences;self.mask=mask;self.cancellation=cancellation;reader=try AtlasDatabase(store.url.path,seconds:60,cancellation:cancellation)
    }
    // Hierarchy-preserving binary treemap; zero-byte observations keep their true zero area.
    static func rectangles(_ weights:[Int64],rect:NSRect)->[NSRect] {
        var frames=[NSRect](repeating:.zero,count:weights.count)
        func split(_ a:Int,_ b:Int,_ r:NSRect) {
            guard a<b else {return};if b-a==1 {frames[a]=r;return}
            let total=weights[a..<b].reduce(0.0) {$0+Double(max(0,$1))};guard total>0 else {return}
            var subtotal=0.0,cut=a+1
            for i in a..<(b-1) {subtotal+=Double(max(0,weights[i]));cut=i+1;if subtotal>=total/2 {break}}
            let ratio=CGFloat(subtotal/total)
            if r.width>=r.height {let w=r.width*ratio;split(a,cut,NSRect(x:r.minX,y:r.minY,width:w,height:r.height));split(cut,b,NSRect(x:r.minX+w,y:r.minY,width:r.width-w,height:r.height))}
            else {let h=r.height*ratio;split(a,cut,NSRect(x:r.minX,y:r.minY,width:r.width,height:h));split(cut,b,NSRect(x:r.minX,y:r.minY+h,width:r.width,height:r.height-h))}
        };split(0,weights.count,rect);return frames
    }
    func build(focus:LensNode,bounds:NSRect)->LensMapResult {
        do {
            result.totals=focus.total
            var rect=bounds.insetBy(dx:6,dy:6)
            if preferences.showVolume,info.capacity>0 {
                let measured=focus.total.weight(preferences.measure),available=max(0,info.free),other=max(0,info.capacity-measured-available)
                if preferences.measure != .tally {
                    let parts=Self.rectangles([measured,available,other],rect:rect);rect=parts[0]
                    for (i,label) in [(1,"Volume available"),(2,"Other usage / unscanned / shared accounting")] where parts[i].width>0 {
                        var n=LensNode();n.id = -Int64(i);n.name=label;n.total=LensTotals(bytes:i==1 ? available:other,allocated:i==1 ? available:other,count:0)
                        result.tiles.append(LensTile(node:n,frame:parts[i],label:label,virtual:true))
                    }
                }
            }
            try visit(focus,rect:rect,level:0)
        } catch {var n=LensNode();n.name="Map held";n.error=error.localizedDescription;result.tiles=[LensTile(node:n,frame:bounds,label:"Map held · "+error.localizedDescription,virtual:true)]}
        return result
    }
    private func visit(_ parent:LensNode,rect:NSRect,level:Int) throws {
        guard !cancellation.cancelled else {throw KonMagicError("Superseded map cancelled.")}
        if !parent.directory {add(parent,rect:rect);return}
        if level>0,level<=2,rect.width>160,rect.height>100 {result.branches.append(LensTile(node:parent,frame:rect,label:parent.name,path:store.path(parent,info)))}
        if level>=preferences.depth || (preferences.display != .files && parent.package) || rect.width*rect.height<24 || result.tiles.count>=4096 {
            result.collapsed+=1;add(parent,rect:rect,label:parent.name+" · zoom for contents");return
        }
        let column=preferences.measure == .logical ? "tb" : preferences.measure == .allocated ? "ta" : "tc"
        var nodes:[LensNode]=[]
        try reader.rows("SELECT "+LensStore.columns+" FROM nodes n LEFT JOIN nodes p ON p.id=n.parent WHERE n.parent=? ORDER BY n."+column+" DESC,n.name LIMIT 5000",[String(parent.id)]) {s in nodes.append(LensStore.node(s))}
        if nodes.isEmpty {return}
        let sum=nodes.reduce(LensTotals()) {$0+$1.total},remainder=LensTotals(bytes:max(0,parent.total.bytes-sum.bytes),allocated:max(0,parent.total.allocated-sum.allocated),count:max(0,parent.total.count-sum.count))
        var virtual:Set<Int64>=[]
        if remainder.weight(preferences.measure)>0 {var n=LensNode();n.id = -parent.id-100;n.name="More entries · open this folder in the list";n.total=remainder;n.parent=parent.id;nodes.append(n);virtual.insert(n.id)}
        if preferences.display == .folders {
            let leaves=nodes.filter {!$0.directory && !virtual.contains($0.id)}
            if !leaves.isEmpty {
                nodes.removeAll {!$0.directory && !virtual.contains($0.id)}
                var n=parent;n.id = -parent.id-100_000_000;n.name="Files directly in "+parent.name;n.total=leaves.reduce(LensTotals()) {$0+$1.total};nodes.append(n);virtual.insert(n.id)
            }
        }
        result.omittedZero+=Int64(nodes.filter {$0.total.weight(preferences.measure)==0}.count)
        nodes=nodes.filter {$0.total.weight(preferences.measure)>0}
        let frames=Self.rectangles(nodes.map {$0.total.weight(preferences.measure)},rect:rect)
        for (i,node) in nodes.enumerated() {
            if virtual.contains(node.id) {result.tiles.append(LensTile(node:node,frame:frames[i],label:node.name,virtual:true))}
            else {try visit(node,rect:frames[i],level:level+1)}
        }
    }
    private func add(_ node:LensNode,rect:NSRect,label:String?=nil) {
        let path=store.path(node,info)
        result.tiles.append(LensTile(node:node,frame:rect,label:label ?? node.name,masked:!mask.matches(node,path:path),path:path))
    }
}

final class LensCanvas:NSView {
    var result=LensMapResult(),preferences=LensPreferences(),selected:Int64=0,locked=false
    var selectedRelative:String?,selectedDirectory=false
    var selection:((LensTile)->Void)?,zoom:((LensTile)->Void)?,zoomOut:(()->Void)?,preview:(()->Void)?,focus:((Int)->Void)?
    override var isOpaque:Bool {true}
    override var acceptsFirstResponder:Bool {true}
    override func accessibilityRole()->NSAccessibility.Role? {.group}
    override func accessibilityLabel()->String? {"Hierarchical disk-size map. Hover inspects; click locks selection; double-click zooms; arrows select; Space previews. The adjacent native list offers equivalent accessible navigation."}
    override func updateTrackingAreas() {for area in trackingAreas {removeTrackingArea(area)};addTrackingArea(NSTrackingArea(rect:bounds,options:[.mouseMoved,.activeInKeyWindow,.inVisibleRect],owner:self,userInfo:nil));super.updateTrackingAreas()}
    func value(_ tile:LensTile)->String {
        switch preferences.color {
        case .name:return tile.node.name;case .extensionName:return (tile.node.name as NSString).pathExtension.lowercased()
        case .type:return preferences.typeMappings[(tile.node.name as NSString).pathExtension.lowercased()] ?? MetadataLabels.tags(path:tile.path,kind:tile.node.kindName,inherited:"")["family"] ?? "Unknown"
        case .parent:return (tile.path as NSString).deletingLastPathComponent
        case .top:return tile.node.relative.split(separator:"/").first.map(String.init) ?? "Root"
        case .depth:return String(tile.node.depth)
        case .size:return "Size band "+String(Int(log2(Double(max(1,tile.node.total.weight(preferences.measure)))))/4)
        case .creation:return tile.node.created>0 ? String(tile.node.created/2_592_000) : "Unknown creation"
        case .modified:return tile.node.modified>0 ? String(tile.node.modified/2_592_000) : "Unknown modification"
        case .access:return tile.node.accessed>0 ? String(tile.node.accessed/2_592_000) : "Unknown access"
        case .protection:return tile.node.cloud ? "Cloud placeholder" : tile.node.duplicate ? "Repeated hard link" : SafeFS.guardedName(tile.node.name) ? "Protected collection" : "Ordinary metadata"
        case .none:return "Uniform"
        }
    }
    func color(_ value:String)->NSColor {
        var hash:UInt64=5381;for b in value.utf8 {hash=(hash &* 33)&+UInt64(b)}
        let dark=effectiveAppearance.bestMatch(from:[.darkAqua,.aqua]) == .darkAqua
        let hue:CGFloat
        switch preferences.palette {case .ocean:hue=0.48+CGFloat(hash%100)/500;case .forest:hue=0.23+CGFloat(hash%100)/600;case .ember:hue=CGFloat(hash%80)/600;case .monochrome:hue=0.58;case .accessible:
            let colors:[NSColor]=[.systemBlue,.systemOrange,.systemTeal,.systemPurple,.systemPink,.systemYellow];return colors[Int(hash%UInt64(colors.count))].withAlphaComponent(dark ? 0.6:0.35)
        case .pastel:
            let colors=[FriendlyUI.ink(0xC9EAE6,0x294C4C),FriendlyUI.ink(0xE2D9F4,0x453A5E),FriendlyUI.ink(0xF7DDC4,0x574331),FriendlyUI.ink(0xDCEACF,0x3C4C36),FriendlyUI.ink(0xD5E8F2,0x324754),FriendlyUI.ink(0xF3DCE7,0x553A4B)]
            return colors[Int(hash%UInt64(colors.count))]
        case .rainbow:hue=CGFloat(hash%360)/360}
        return NSColor(calibratedHue:hue,saturation:preferences.palette == .monochrome ? 0.1:0.5,brightness:dark ? 0.43+CGFloat(hash%10)/100:0.8+CGFloat(hash%15)/100,alpha:1)
    }
    override func draw(_ rect:NSRect) {
        FriendlyUI.surface.setFill();rect.fill()
        if result.tiles.isEmpty {let paragraph=NSMutableParagraphStyle();paragraph.alignment = .center
            ("A little perspective starts here.\nScan a folder or import your recorded machine." as NSString).draw(in:NSRect(x:20,y:bounds.midY-25,width:max(0,bounds.width-40),height:65),withAttributes:[.font:NSFont.systemFont(ofSize:15,weight:.medium),.foregroundColor:FriendlyUI.muted,.paragraphStyle:paragraph]);return}
        for tile in result.tiles {
            guard tile.frame.intersects(rect) else {continue}
            let r=tile.frame.insetBy(dx:1.5,dy:1.5);guard r.width>0,r.height>0 else {continue}
            let shape=NSBezierPath(roundedRect:r,xRadius:min(9,r.width/8),yRadius:min(9,r.height/8))
            if tile.masked {NSColor.quaternaryLabelColor.setFill();r.fill();continue}
            (tile.virtual ? NSColor.separatorColor : color(value(tile))).setFill();shape.fill();FriendlyUI.surface.withAlphaComponent(0.8).setStroke();shape.lineWidth=1;shape.stroke()
            if tile.node.id==selected {FriendlyUI.teal.setStroke();shape.lineWidth=3;shape.stroke()}
            if r.width>85 && r.height>34 {
                let paragraph=NSMutableParagraphStyle();paragraph.lineBreakMode = .byTruncatingTail
                let amount=preferences.measure == .tally ? String(tile.node.total.count)+" files" : ByteCountFormatter.string(fromByteCount:tile.node.total.weight(preferences.measure),countStyle:preferences.binaryUnits ? .binary:.decimal)
                let labelRect=r.insetBy(dx:9,dy:9)
                (tile.label+"\n"+amount as NSString).draw(in:labelRect,withAttributes:[.font:NSFont.systemFont(ofSize:11,weight:.medium),.foregroundColor:FriendlyUI.text,.paragraphStyle:paragraph])
            }
        }
        for branch in result.branches {
            let r=branch.frame.insetBy(dx:1,dy:1),outline=NSBezierPath(roundedRect:r,xRadius:10,yRadius:10)
            FriendlyUI.muted.withAlphaComponent(0.3).setStroke();outline.lineWidth=1.5;outline.stroke()
            let header=NSRect(x:r.minX+5,y:r.maxY-26,width:r.width-10,height:22)
            let label=NSBezierPath(roundedRect:header,xRadius:6,yRadius:6);FriendlyUI.surface.setFill();label.fill()
            let paragraph=NSMutableParagraphStyle();paragraph.lineBreakMode = .byTruncatingTail
            ("▸ "+branch.label as NSString).draw(in:header.insetBy(dx:6,dy:3),withAttributes:[.font:NSFont.systemFont(ofSize:11,weight:.semibold),.foregroundColor:FriendlyUI.text,.paragraphStyle:paragraph])
        }
        if selectedDirectory,let relative=selectedRelative {
            let frames=result.tiles.filter {!$0.virtual && ($0.node.relative==relative || $0.node.relative.hasPrefix(relative.isEmpty ? "":relative+"/"))}.map(\.frame)
            if let first=frames.first {let box=frames.dropFirst().reduce(first) {$0.union($1)};let outline=NSBezierPath(roundedRect:box.insetBy(dx:1,dy:1),xRadius:10,yRadius:10);outline.lineWidth=3;FriendlyUI.teal.setStroke();outline.stroke()}
        }
    }
    func at(_ event:NSEvent)->LensTile? {let point=convert(event.locationInWindow,from:nil)
        if let branch=result.branches.reversed().first(where:{NSRect(x:$0.frame.minX+6,y:$0.frame.maxY-27,width:$0.frame.width-12,height:22).contains(point)}) {return branch}
        return result.tiles.first {$0.frame.contains(point) && !$0.masked}
    }
    override func mouseMoved(with event:NSEvent) {if !locked,let tile=at(event) {selected=tile.node.id;needsDisplay=true;selection?(tile)}}
    override func mouseDown(with event:NSEvent) {window?.makeFirstResponder(self);guard let tile=at(event) else{return};selected=tile.node.id;locked=true;needsDisplay=true;selection?(tile);if event.clickCount==2 {zoom?(tile)}}
    override func scrollWheel(with event:NSEvent) {if abs(event.scrollingDeltaY)>1 {focus?(event.scrollingDeltaY>0 ? 1:-1)}}
    override func keyDown(with event:NSEvent) {
        if event.keyCode==49 {preview?();return}
        if event.keyCode==53 {locked=false;return}
        if event.modifierFlags.contains(.command),let text=event.charactersIgnoringModifiers {
            if text=="[" {focus?(1);return};if text=="]" {focus?(-1);return};if text=="-" {zoomOut?();return}
            if text=="=" || text=="+",let tile=result.tiles.first(where:{$0.node.id==selected}) {zoom?(tile);return}
        }
        let visible=result.tiles.filter {!$0.masked && !$0.virtual};guard !visible.isEmpty else{return}
        if [123,124,125,126].contains(event.keyCode) {
            let current=visible.first {$0.node.id==selected} ?? visible[0],dx:CGFloat=event.keyCode==123 ? -1:event.keyCode==124 ? 1:0,dy:CGFloat=event.keyCode==125 ? -1:event.keyCode==126 ? 1:0
            let next=visible.filter {($0.frame.midX-current.frame.midX)*dx+($0.frame.midY-current.frame.midY)*dy>0.1}.min {a,b in
                func distance(_ tile:LensTile)->CGFloat {let x=tile.frame.midX-current.frame.midX,y=tile.frame.midY-current.frame.midY;return sqrt(x*x+y*y)+abs(x*dy-y*dx)*2}
                return distance(a)<distance(b)
            } ?? current
            locked=true;selected=next.node.id;selection?(next);needsDisplay=true
        } else if event.keyCode==36,let tile=visible.first(where:{$0.node.id==selected}) {zoom?(tile)} else {super.keyDown(with:event)}
    }
}
