import AppKit

// Native, appearance-aware surfaces. Decorative artwork never carries controls or evidence.
enum FriendlyUI {
    static func ink(_ light:UInt32,_ dark:UInt32)->NSColor {
        func rgb(_ v:UInt32)->NSColor {NSColor(srgbRed:CGFloat((v>>16)&255)/255,green:CGFloat((v>>8)&255)/255,blue:CGFloat(v&255)/255,alpha:1)}
        return NSColor(name:nil) {appearance in rgb(appearance.bestMatch(from:[.aqua,.darkAqua]) == .darkAqua ? dark:light)}
    }
    static let background=ink(0xFAF9FD,0x1D2029),surface=ink(0xFFFFFF,0x282D39),text=ink(0x292640,0xEFEAF8),muted=ink(0x646779,0xBEC3D1)
    static let teal=ink(0x087F83,0x78DDD5),violet=ink(0x7150B7,0xC7AFF4),orange=ink(0xB75D21,0xF3B781),green=ink(0x447C38,0xA4D594),pink=ink(0xAE416A,0xF1A8C5)
    static func wash(_ tint:NSColor)->NSColor {ink(0xFFFFFF,0x282D39).blended(withFraction:0.10,of:tint) ?? surface}
    static func label(_ text:String,size:CGFloat=12,weight:NSFont.Weight = .regular,wrapping:Bool=false)->NSTextField {
        let v=wrapping ? NSTextField(wrappingLabelWithString:text):NSTextField(labelWithString:text);v.font=NSFont.systemFont(ofSize:size,weight:weight);v.textColor=self.text;return v
    }
    static func image(_ symbol:String,tint:NSColor,size:CGFloat=20)->NSImageView {
        let v=NSImageView();v.image=NSImage(systemSymbolName:symbol,accessibilityDescription:nil);v.contentTintColor=tint;v.imageScaling = .scaleProportionallyDown
        v.widthAnchor.constraint(equalToConstant:size).isActive=true;v.heightAnchor.constraint(equalToConstant:size).isActive=true;return v
    }
    static func row(_ views:[NSView],spacing:CGFloat=10)->NSStackView {let v=NSStackView(views:views);v.orientation = .horizontal;v.alignment = .centerY;v.spacing=spacing;return v}
    static func column(_ views:[NSView],spacing:CGFloat=10)->NSStackView {let v=NSStackView(views:views);v.orientation = .vertical;v.alignment = .leading;v.spacing=spacing;return v}
    static func panel(_ content:NSView,tint:NSColor?=nil,padding:CGFloat=16)->FriendlyPanel {
        let v=FriendlyPanel(tint:tint);content.translatesAutoresizingMaskIntoConstraints=false;v.addSubview(content)
        NSLayoutConstraint.activate([content.leadingAnchor.constraint(equalTo:v.leadingAnchor,constant:padding),content.trailingAnchor.constraint(equalTo:v.trailingAnchor,constant:-padding),content.topAnchor.constraint(equalTo:v.topAnchor,constant:padding),content.bottomAnchor.constraint(equalTo:v.bottomAnchor,constant:-padding)])
        return v
    }
    static func scrollingPanel(_ content:NSView,width:CGFloat,tint:NSColor?=nil,padding:CGFloat=14)->FriendlyPanel {
        let scroll=NSScrollView(),document=FriendlyDocument();scroll.hasVerticalScroller=true;scroll.autohidesScrollers=true;scroll.drawsBackground=false;scroll.documentView=document
        document.translatesAutoresizingMaskIntoConstraints=false;content.translatesAutoresizingMaskIntoConstraints=false;document.addSubview(content)
        NSLayoutConstraint.activate([document.widthAnchor.constraint(equalTo:scroll.contentView.widthAnchor),content.leadingAnchor.constraint(equalTo:document.leadingAnchor),content.trailingAnchor.constraint(equalTo:document.trailingAnchor),content.topAnchor.constraint(equalTo:document.topAnchor),content.bottomAnchor.constraint(equalTo:document.bottomAnchor)])
        let v=panel(scroll,tint:tint,padding:padding);v.widthAnchor.constraint(equalToConstant:width).isActive=true;return v
    }
    static func button(_ title:String,symbol:String?=nil,tint:NSColor?=nil,target:AnyObject?,action:Selector)->NSButton {
        let b:NSButton=tint.map {FriendlyActionButton(title:title,tint:$0,target:target,action:action)} ?? NSButton(title:title,target:target,action:action);b.bezelStyle = .rounded;b.controlSize = .large;b.font=NSFont.systemFont(ofSize:12,weight:.medium)
        if let symbol=symbol {b.image=NSImage(systemSymbolName:symbol,accessibilityDescription:nil);b.imagePosition = .imageLeading}
        if let tint=tint {b.bezelColor=tint}
        return b
    }
    static func artwork(_ name:String)->NSImage? {
        let paths=[Bundle.main.resourceURL?.appendingPathComponent("Artwork/"+name+".png"),URL(fileURLWithPath:CommandLine.arguments[0]).deletingLastPathComponent().appendingPathComponent("Resources/Artwork/"+name+".png")]
        return paths.compactMap {$0}.compactMap {NSImage(contentsOf:$0)}.first
    }
}

final class FriendlyCanvas:NSView {
    override func draw(_ rect:NSRect) {FriendlyUI.background.setFill();rect.fill()}
}
final class FriendlyDocument:NSView {override var isFlipped:Bool {true}}
final class FriendlyMascot:NSView {
    let kind:Int,image=FriendlyUI.artwork("journey-companions")
    init(kind:Int) {self.kind=kind;super.init(frame:.zero)}
    required init?(coder:NSCoder) {fatalError("Use a companion")}
    override func draw(_ rect:NSRect) {guard let image=image else{return};let side=image.size.width/3,scale=min(bounds.width/side,bounds.height/image.size.height),size=NSSize(width:side*scale,height:image.size.height*scale)
        image.draw(in:NSRect(x:(bounds.width-size.width)/2,y:(bounds.height-size.height)/2,width:size.width,height:size.height),from:NSRect(x:CGFloat(kind)*side,y:0,width:side,height:image.size.height),operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high])
    }
}

class FriendlyPanel:NSView {
    let tint:NSColor?
    var radius:CGFloat=18
    init(tint:NSColor?=nil) {self.tint=tint;super.init(frame:.zero)}
    required init?(coder:NSCoder) {fatalError("Use a native panel")}
    override func draw(_ rect:NSRect) {
        let shape=NSBezierPath(roundedRect:bounds.insetBy(dx:0.5,dy:0.5),xRadius:radius,yRadius:radius)
        (tint.map(FriendlyUI.wash) ?? FriendlyUI.surface).setFill();shape.fill()
        (tint?.withAlphaComponent(0.28) ?? FriendlyUI.ink(0xDADBE7,0x4B5265)).setStroke();shape.lineWidth=1;shape.stroke()
    }
    override func viewDidChangeEffectiveAppearance() {super.viewDidChangeEffectiveAppearance();needsDisplay=true}
}

// A native button retains AppKit target/action, keyboard and accessibility behavior.
// Only its pill-shaped primary-action surface is drawn here.
final class FriendlyActionButton:NSButton {
    let tint:NSColor
    private var presentation=""
    init(title:String,tint:NSColor,target:AnyObject?,action:Selector) {
        self.tint=tint;super.init(frame:.zero);self.title=title;self.target=target;self.action=action
        setButtonType(.momentaryPushIn);isBordered=false;focusRingType = .exterior
    }
    required init?(coder:NSCoder) {fatalError("Use an action")}
    override var intrinsicContentSize:NSSize {let size=super.intrinsicContentSize;return NSSize(width:size.width+22,height:max(34,size.height))}
    override func draw(_ dirtyRect:NSRect) {
        let dark=effectiveAppearance.bestMatch(from:[.aqua,.darkAqua]) == .darkAqua
        let key="\(title)|\(isEnabled)|\(dark)|\(font?.pointSize ?? 12)"
        if presentation != key {
            presentation=key
            let ink=dark ? NSColor(srgbRed:0.12,green:0.14,blue:0.19,alpha:1):NSColor.white
            attributedTitle=NSAttributedString(string:title,attributes:[.font:font ?? NSFont.systemFont(ofSize:12,weight:.medium),.foregroundColor:ink.withAlphaComponent(isEnabled ? 1:0.55)])
            contentTintColor=ink.withAlphaComponent(isEnabled ? 1:0.55)
        }
        let shape=NSBezierPath(roundedRect:bounds.insetBy(dx:1,dy:1),xRadius:14,yRadius:14)
        tint.withAlphaComponent(isEnabled ? ((cell?.isHighlighted ?? false) ? 0.78:1):0.30).setFill();shape.fill()
        super.draw(dirtyRect)
    }
    override func viewDidChangeEffectiveAppearance() {super.viewDidChangeEffectiveAppearance();needsDisplay=true}
}

final class FriendlyMetric:NSView {
    let value=FriendlyUI.label("—",size:19,weight:.bold)
    init(title:String,symbol:String,tint:NSColor,compact:Bool=false) {
        super.init(frame:.zero)
        let caption=FriendlyUI.label(title,size:10);caption.textColor=FriendlyUI.muted
        let words=FriendlyUI.column([value,caption],spacing:3)
        let row=FriendlyUI.row([FriendlyUI.image(symbol,tint:tint,size:compact ? 20:25),words],spacing:10);row.translatesAutoresizingMaskIntoConstraints=false;addSubview(row)
        NSLayoutConstraint.activate([row.leadingAnchor.constraint(equalTo:leadingAnchor),row.trailingAnchor.constraint(equalTo:trailingAnchor),row.topAnchor.constraint(equalTo:topAnchor),row.bottomAnchor.constraint(equalTo:bottomAnchor)])
        setAccessibilityLabel(title)
    }
    required init?(coder:NSCoder) {fatalError("Use a metric")}
}

final class ToolkitHero:FriendlyPanel {
    let artwork=FriendlyUI.artwork("toolkit-garden")
    init() {super.init(tint:FriendlyUI.pink)}
    required init?(coder:NSCoder) {fatalError("Use a hero")}
    override func draw(_ rect:NSRect) {
        super.draw(rect);NSGraphicsContext.saveGraphicsState()
        NSBezierPath(roundedRect:bounds,xRadius:radius,yRadius:radius).addClip()
        if let image=artwork,image.size.height>0 {
            // Preserve the characters' aspect ratio; only stretch the quiet central sky.
            let size=image.size,scale=bounds.height/size.height,left=size.width*0.22,right=size.width*0.30,lw=left*scale,rw=right*scale
            let source=[NSRect(x:0,y:0,width:left,height:size.height),NSRect(x:left,y:0,width:size.width-left-right,height:size.height),NSRect(x:size.width-right,y:0,width:right,height:size.height)]
            let target=[NSRect(x:0,y:0,width:lw,height:bounds.height),NSRect(x:lw,y:0,width:max(0,bounds.width-lw-rw),height:bounds.height),NSRect(x:bounds.width-rw,y:0,width:rw,height:bounds.height)]
            for (from,to) in zip(source,target) {image.draw(in:to,from:from,operation:.sourceOver,fraction:1,respectFlipped:true,hints:[.interpolation:NSImageInterpolation.high])}
        }
        if effectiveAppearance.bestMatch(from:[.aqua,.darkAqua]) == .darkAqua {NSColor(calibratedWhite:0.05,alpha:0.65).setFill();bounds.fill()}
        NSGraphicsContext.restoreGraphicsState()
    }
}

// Small code-native illustrations remain crisp at any backing scale.
final class FriendlyTaskIcon:NSView {
    let kind:Int,tint:NSColor
    init(kind:Int,tint:NSColor) {self.kind=kind;self.tint=tint;super.init(frame:.zero);widthAnchor.constraint(equalToConstant:74).isActive=true;heightAnchor.constraint(equalToConstant:80).isActive=true}
    required init?(coder:NSCoder) {fatalError("Use an icon")}
    override func draw(_ rect:NSRect) {
        let body:NSBezierPath
        switch kind {
        case 0:body=NSBezierPath(roundedRect:NSRect(x:12,y:12,width:50,height:58),xRadius:10,yRadius:10)
        case 1:
            let handle=NSBezierPath();handle.move(to:NSPoint(x:18,y:14));handle.line(to:NSPoint(x:32,y:33));handle.lineWidth=10;handle.lineCapStyle = .round;tint.withAlphaComponent(0.65).setStroke();handle.stroke()
            body=NSBezierPath(ovalIn:NSRect(x:23,y:26,width:47,height:47))
        case 2:
            body=NSBezierPath(roundedRect:NSRect(x:7,y:15,width:62,height:43),xRadius:8,yRadius:8)
            let tab=NSBezierPath(roundedRect:NSRect(x:7,y:48,width:32,height:16),xRadius:5,yRadius:5);tint.withAlphaComponent(0.24).setFill();tab.fill();tint.setStroke();tab.lineWidth=2;tab.stroke()
        default:body=NSBezierPath(roundedRect:NSRect(x:14,y:11,width:48,height:59),xRadius:8,yRadius:8)
        }
        (FriendlyUI.surface.blended(withFraction:0.22,of:tint) ?? FriendlyUI.surface).setFill();body.fill();tint.setStroke();body.lineWidth=2.2;body.stroke()
        let cx:CGFloat=kind==1 ? 46:38,cy:CGFloat=kind==1 ? 49:40
        FriendlyUI.text.setFill();for x in [cx-8,cx+8] {NSBezierPath(ovalIn:NSRect(x:x-2,y:cy,width:4,height:5)).fill()}
        FriendlyUI.pink.withAlphaComponent(0.30).setFill();for x in [cx-15,cx+15] {NSBezierPath(ovalIn:NSRect(x:x-4,y:cy-5,width:8,height:5)).fill()}
        let smile=NSBezierPath();smile.move(to:NSPoint(x:cx-4,y:cy-5));smile.curve(to:NSPoint(x:cx+4,y:cy-5),controlPoint1:NSPoint(x:cx-2,y:cy-10),controlPoint2:NSPoint(x:cx+2,y:cy-10));FriendlyUI.text.setStroke();smile.lineWidth=1.5;smile.stroke()
        if kind==0 {tint.withAlphaComponent(0.4).setFill();NSBezierPath(roundedRect:NSRect(x:19,y:18,width:37,height:5),xRadius:2,yRadius:2).fill()}
        if kind==3 {let check=NSBezierPath();check.move(to:NSPoint(x:24,y:57));check.line(to:NSPoint(x:28,y:53));check.line(to:NSPoint(x:34,y:61));tint.setStroke();check.lineWidth=2;check.stroke()}
    }
}
