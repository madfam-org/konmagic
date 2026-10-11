import AppKit
import UniformTypeIdentifiers
import Darwin

enum LensExportSize {
    // At most 32 megapixels / 128 MiB for the uncompressed RGBA surface.
    static func make(bounds:NSRect,width:CGFloat)->NSSize {
        let w=max(1,min(8192,width)),h=max(1,w*max(1,bounds.height)/max(1,bounds.width))
        let factor=min(1,min(8192/max(w,h),sqrt(CGFloat(32*1024*1024)/(w*h))))
        return NSSize(width:max(1,(w*factor).rounded(.down)),height:max(1,(h*factor).rounded(.down)))
    }
}
enum LensMapImage {
    static func bitmap(_ result:LensMapResult,preferences:LensPreferences,size:NSSize,appearance:NSAppearance) throws -> NSBitmapImageRep {
        let width=Int(size.width),height=Int(size.height)
        guard Thread.isMainThread,width>0,height>0,width<=8192,height<=8192,Int64(width)*Int64(height)<=32*1024*1024,
              let bitmap=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:width,pixelsHigh:height,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:width*4,bitsPerPixel:32),let context=NSGraphicsContext(bitmapImageRep:bitmap) else {throw KonMagicError("Cannot allocate the bounded image surface.")}
        bitmap.size=size
        let drawing=LensCanvas(frame:NSRect(origin:.zero,size:size));drawing.preferences=preferences;drawing.result=result
        appearance.performAsCurrentDrawingAppearance {NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=context;drawing.draw(drawing.bounds);NSGraphicsContext.restoreGraphicsState()}
        return bitmap
    }
}

extension DiskLensController {
    func exportResolutionImage() {
        guard !busy,let store=store,let info=info,let focus=focusNode else{return}
        let panel=NSSavePanel();panel.allowedContentTypes=[.png,.tiff];panel.nameFieldStringValue="Disk map.png"
        let size=NSPopUpButton(frame:NSRect(x:0,y:0,width:360,height:28)),bounds=canvas.bounds
        let widths=[bounds.width*(view.window?.backingScaleFactor ?? 2),3840,7680]
        for (title,width) in zip(["Current display pixels","4K wide","8K wide"],widths) {let s=LensExportSize.make(bounds:bounds,width:width);size.addItem(withTitle:title+" · \(Int(s.width)) × \(Int(s.height))")}
        size.selectItem(at:1)
        let help=label("Exports this focused hierarchy and mask, independently of the viewport pan. Higher resolution resolves smaller branches. Maximum 32 megapixels. No source bodies read.",size:11);help.maximumNumberOfLines=3
        panel.accessoryView=dialogAccessory([size,help])
        guard panel.runModal() == .OK,let url=panel.url else{return}
        let target=LensExportSize.make(bounds:bounds,width:widths[max(0,size.indexOfSelectedItem)]),p=preferences,mask=self.mask,detail=LensDetail(rawValue:max(0,resolution.indexOfSelectedItem)) ?? .balanced
        let appearance=canvas.effectiveAppearance
        perform("Preparing a high-resolution map from retained metadata…",{
            try LensMapBuilder(store:store,info:info,preferences:p,mask:mask,cancellation:self.operationCancellation,detail:detail).build(focus:focus,bounds:NSRect(origin:.zero,size:target))
        }) {result in
            do {
                guard !self.operationCancellation.cancelled,!result.tiles.contains(where:{$0.label.hasPrefix("Map held")}) else {throw KonMagicError("Map export was held; no image written.")}
                let width=Int(target.width),height=Int(target.height)
                let bitmap=try LensMapImage.bitmap(result,preferences:p,size:target,appearance:appearance)
                guard let data=bitmap.representation(using:url.pathExtension.lowercased()=="tiff" ? .tiff:.png,properties:[:]) else {throw KonMagicError("Cannot encode the map image.")}
                let parent=try SafeFS.openDirectory(url.deletingLastPathComponent().path);defer {close(parent)}
                try SafeFS.destinationClear(url.path)
                let fd=openat(parent,url.lastPathComponent,O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW,0o600);guard fd>=0 else {throw SafeFS.fail("Map export destination held")};defer {close(fd)}
                try FileHandle(fileDescriptor:fd,closeOnDealloc:false).write(contentsOf:data);guard fsync(fd)==0 else {throw SafeFS.fail("Map export could not be flushed")}
                self.status.stringValue="Exported \(width) × \(height) map · \(result.tiles.count) rectangles. The focused scan and mask are retained; compact groups remain explicit."
                self.mapSelection.stringValue=self.status.stringValue
            } catch {self.status.stringValue=error.localizedDescription;self.mapSelection.stringValue=error.localizedDescription}
        }
    }
}
