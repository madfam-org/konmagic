import AppKit
import Foundation

let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:1024,pixelsHigh:1024,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
let context=NSGraphicsContext(bitmapImageRep:bitmap)!
NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=context
NSColor(calibratedRed:0.12,green:0.11,blue:0.20,alpha:1).setFill()
NSBezierPath(roundedRect:NSRect(x:46,y:46,width:932,height:932),xRadius:210,yRadius:210).fill()
let folder=NSBezierPath();folder.move(to:NSPoint(x:184,y:286));folder.line(to:NSPoint(x:184,y:664));folder.curve(to:NSPoint(x:224,y:704),controlPoint1:NSPoint(x:184,y:696),controlPoint2:NSPoint(x:193,y:704));folder.line(to:NSPoint(x:415,y:704));folder.line(to:NSPoint(x:486,y:641));folder.line(to:NSPoint(x:810,y:641));folder.line(to:NSPoint(x:810,y:286));folder.close()
NSGradient(starting:NSColor(calibratedRed:0.48,green:0.39,blue:0.94,alpha:1),ending:NSColor(calibratedRed:0.29,green:0.23,blue:0.63,alpha:1))!.draw(in:folder,angle:70)
let k=NSAttributedString(string:"K",attributes:[.font:NSFont.systemFont(ofSize:320,weight:.bold),.foregroundColor:NSColor.white])
k.draw(at:NSPoint(x:370,y:302))
let star=NSBezierPath();star.move(to:NSPoint(x:764,y:847));star.line(to:NSPoint(x:793,y:780));star.line(to:NSPoint(x:862,y:750));star.line(to:NSPoint(x:793,y:720));star.line(to:NSPoint(x:764,y:650));star.line(to:NSPoint(x:734,y:720));star.line(to:NSPoint(x:665,y:750));star.line(to:NSPoint(x:734,y:780));star.close()
NSColor(calibratedRed:0.55,green:0.90,blue:0.77,alpha:1).setFill();star.fill()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))
