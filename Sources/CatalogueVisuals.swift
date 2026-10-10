import AppKit

struct CatalogueMapTile {
    let label:String
    let count:Int64
    let bytes:Int64
    let readings:Int64
    let choices:[CatalogueDimension:String]
    var frame=NSRect.zero
}
// Interactive native canvases use retained aggregates, never an invented sample.
final class CatalogueMapView:NSView {
    var tiles:[CatalogueMapTile]=[]
    var relations:[(Int,Int,Int64)]=[]
    var connections=false
    var byBytes=false
    var selected=0
    var activated:(([CatalogueDimension:String])->Void)?
    override var acceptsFirstResponder:Bool {true}
    override var isOpaque:Bool {true}
    override func accessibilityRole()->NSAccessibility.Role? {.group}
    override func accessibilityLabel()->String? {"Catalogue map. Arrow keys select groups; Return opens their observations. The native facet list offers the same categories."}
    func configure(_ summary:CatalogueSummary,dimension:CatalogueDimension,connections:Bool,byBytes:Bool) {
        self.connections=connections;self.byBytes=byBytes;relations=[];selected=0
        let groups=summary.groups(dimension)
        if !connections {
            tiles=groups.prefix(39).map {CatalogueMapTile(label:$0.value,count:$0.count,bytes:$0.bytes,readings:$0.readings,choices:[dimension:$0.value])}
            if groups.count>39 {
                let rest=groups.dropFirst(39),count=rest.reduce(Int64(0)) {$0+$1.count},bytes=rest.reduce(Int64(0)) {$0+$1.bytes}
                tiles.append(CatalogueMapTile(label:"Other · \(rest.count) categories\nUse the complete facet list",count:count,bytes:bytes,readings:rest.reduce(0) {$0+$1.readings},choices:[:]))
            }
        } else {
            let left:CatalogueDimension = dimension == .project ? .project : .owner
            let right:CatalogueDimension = left == .project ? .family : .project
            let a=Array(summary.groups(left).prefix(12)),b=Array(summary.groups(right).prefix(12))
            tiles=a.map {CatalogueMapTile(label:$0.value,count:$0.count,bytes:$0.bytes,readings:$0.readings,choices:[left:$0.value])}
            tiles += b.map {CatalogueMapTile(label:$0.value,count:$0.count,bytes:$0.bytes,readings:$0.readings,choices:[right:$0.value])}
            let leftIndex=Dictionary(uniqueKeysWithValues:a.enumerated().map {($0.element.value,$0.offset)})
            let rightIndex=Dictionary(uniqueKeysWithValues:b.enumerated().map {($0.element.value,$0.offset)})
            var weights:[Int:Int64]=[:]
            for p in summary.partitions {
                if let x=p.values[left.rawValue],let y=p.values[right.rawValue],let i=leftIndex[x],let j=rightIndex[y] {weights[i*16+j,default:0]+=p.count}
            }
            for (key,count) in weights {relations.append((key/16,a.count+key%16,count))}
            leftCount=a.count
        }
        needsDisplay=true
    }
    var leftCount=0
    func configureDisk(_ values:[String:Int64]) {
        connections=false;byBytes=false;relations=[];selected=0
        tiles=values.map {CatalogueMapTile(label:$0.key,count:$0.value,bytes:0,readings:0,choices:[:])}.sorted {$0.count>$1.count}
        needsDisplay=true
    }
    private func color(_ name:String)->NSColor {
        var hash:UInt64=5381;for byte in name.utf8 {hash=(hash &* 33) &+ UInt64(byte)}
        let dark=effectiveAppearance.bestMatch(from:[.darkAqua,.aqua]) == .darkAqua
        return NSColor(calibratedHue:CGFloat(hash%360)/360,saturation:dark ? 0.45 : 0.28,brightness:dark ? 0.42 : 0.94,alpha:1)
    }
    private func partition(_ indexes:[Int],in rect:NSRect) {
        guard !indexes.isEmpty else {return}
        if indexes.count==1 {tiles[indexes[0]].frame=rect.insetBy(dx:2,dy:2);return}
        let weights=indexes.map {max(1,byBytes ? tiles[$0].bytes : tiles[$0].count)}
        let total=weights.reduce(Int64(0),+);var subtotal:Int64=0,cut=1
        for i in 0..<(indexes.count-1) {subtotal+=weights[i];cut=i+1;if subtotal*2>=total {break}}
        let ratio=CGFloat(subtotal)/CGFloat(total)
        if rect.width>=rect.height {
            let width=rect.width*ratio
            partition(Array(indexes.prefix(cut)),in:NSRect(x:rect.minX,y:rect.minY,width:width,height:rect.height))
            partition(Array(indexes.dropFirst(cut)),in:NSRect(x:rect.minX+width,y:rect.minY,width:rect.width-width,height:rect.height))
        } else {
            let height=rect.height*ratio
            partition(Array(indexes.prefix(cut)),in:NSRect(x:rect.minX,y:rect.minY,width:rect.width,height:height))
            partition(Array(indexes.dropFirst(cut)),in:NSRect(x:rect.minX,y:rect.minY+height,width:rect.width,height:rect.height-height))
        }
    }
    override func draw(_ dirtyRect:NSRect) {
        NSColor.controlBackgroundColor.setFill();dirtyRect.fill()
        let rect=bounds.insetBy(dx:12,dy:12)
        if connections {
            for i in tiles.indices {
                let left=i<leftCount,index=left ? i : i-leftCount,count=max(1,left ? leftCount : tiles.count-leftCount)
                let height=min(50,rect.height/CGFloat(count)-6)
                let y=rect.maxY-CGFloat(index+1)*rect.height/CGFloat(count)
                tiles[i].frame=NSRect(x:left ? rect.minX : rect.maxX-rect.width*0.36,y:y,width:rect.width*0.36,height:max(20,height))
            }
            for (a,b,count) in relations {
                let path=NSBezierPath(),start=NSPoint(x:tiles[a].frame.maxX,y:tiles[a].frame.midY),end=NSPoint(x:tiles[b].frame.minX,y:tiles[b].frame.midY)
                path.move(to:start);path.curve(to:end,controlPoint1:NSPoint(x:rect.midX,y:start.y),controlPoint2:NSPoint(x:rect.midX,y:end.y))
                path.lineWidth=max(1,min(12,CGFloat(log10(Double(count)+1))*2));NSColor.controlAccentColor.withAlphaComponent(0.3).setStroke();path.stroke()
            }
        } else {partition(Array(tiles.indices),in:rect)}
        for (i,tile) in tiles.enumerated() {
            let shape=NSBezierPath(roundedRect:tile.frame,xRadius:6,yRadius:6);color(tile.label).setFill();shape.fill()
            if i==selected {shape.lineWidth=3;NSColor.controlAccentColor.setStroke();shape.stroke()}
            guard tile.frame.width>65,tile.frame.height>35 else {continue}
            let metric=byBytes ? ByteCountFormatter.string(fromByteCount:tile.bytes,countStyle:.file) : NumberFormatter.localizedString(from:NSNumber(value:tile.count),number:.decimal)+" entries"
            let text=tile.label+"\n"+metric
            let paragraph=NSMutableParagraphStyle();paragraph.lineBreakMode = .byTruncatingTail
            let attrs:[NSAttributedString.Key:Any]=[.font:NSFont.systemFont(ofSize:12,weight:.medium),.foregroundColor:NSColor.labelColor,.paragraphStyle:paragraph]
            (text as NSString).draw(in:tile.frame.insetBy(dx:8,dy:7),withAttributes:attrs)
        }
    }
    override func mouseDown(with event:NSEvent) {
        window?.makeFirstResponder(self);let point=convert(event.locationInWindow,from:nil)
        if let i=tiles.firstIndex(where:{$0.frame.contains(point)}) {selected=i;needsDisplay=true;activated?(tiles[i].choices)}
    }
    override func keyDown(with event:NSEvent) {
        if event.keyCode==123 || event.keyCode==125 {selected=max(0,selected-1);needsDisplay=true}
        else if event.keyCode==124 || event.keyCode==126 {selected=min(max(0,tiles.count-1),selected+1);needsDisplay=true}
        else if event.keyCode==36,selected<tiles.count {activated?(tiles[selected].choices)}
        else {super.keyDown(with:event)}
    }
}
