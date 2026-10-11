import AppKit

// AppKit provides native pinch zoom, two-axis trackpad panning and Retina drawing.
// Canvas geometry stays in document points; detail is resolved after gestures,
// rather than starting a database traversal for every magnification frame.
final class LensViewport:NSScrollView {
    var resized:(()->Void)?
    private var sizing=false
    init(canvas:NSView) {
        super.init(frame:.zero);documentView=canvas;drawsBackground=false
        hasHorizontalScroller=true;hasVerticalScroller=true;autohidesScrollers=true
        allowsMagnification=true;minMagnification=1;maxMagnification=8
        setAccessibilityLabel("Disk map viewport. Pinch to zoom, scroll to pan.")
    }
    required init?(coder:NSCoder) {fatalError("Use the map canvas")}
    override func tile() {
        super.tile();guard !sizing,let canvas=documentView else{return};sizing=true;defer {sizing=false}
        let size=NSSize(width:max(1,contentSize.width),height:max(1,contentSize.height))
        if canvas.frame.size != size {canvas.setFrameSize(size);resized?()}
    }
    func zoom(by factor:CGFloat) {
        let clip=contentView.bounds
        setMagnification(min(8,max(1,magnification*factor)),centeredAt:NSPoint(x:clip.midX,y:clip.midY))
    }
    func fitMap() {magnification=1;contentView.scroll(to:.zero);reflectScrolledClipView(contentView)}
}

extension DiskLensController {
    @objc func toggleMapFocus() {setMapFocus(!mapFocused)}
    func setMapFocus(_ focused:Bool) {
        _ = view;mapFocused=focused
        mapTools.isHidden = !focused
        for v in secondaryChrome {v.isHidden=focused}
        mapFocusButton.title=focused ? "Exit map focus":"Focus map"
        mapFocusButton.toolTip="Give the map the full window; exit with Escape after unlocking selection. ⇧⌘M"
        inspectorVisible = !focused;rightPanel?.isHidden = !inspectorVisible
        fullMapWidth?.isActive = !inspectorVisible
        inspectorToggle.state=inspectorVisible ? .on:.off
        rootStack?.spacing=focused ? 0:16;mapCenter?.spacing=focused ? 4:10;contentStack?.spacing=focused ? 0:18
        for c in outerEdges {c.constant=focused ? 0:(c.firstAttribute == .top ? 20:c.firstAttribute == .bottom ? -16:c.firstAttribute == .leading ? 24:-24)}
        for c in mapPanel?.constraints ?? [] where c.firstItem as? NSView === mapCenter {c.constant=focused ? 0:(c.firstAttribute == .bottom || c.firstAttribute == .trailing ? -16:16)}
        workspace?.pageHost?.updateMapFocus()
        view.layoutSubtreeIfNeeded();scheduleMapRender();view.window?.makeFirstResponder(canvas)
    }
    @objc func toggleMapInspector() {
        inspectorVisible.toggle();rightPanel?.isHidden = !inspectorVisible;inspectorToggle.state=inspectorVisible ? .on:.off
        fullMapWidth?.isActive = !inspectorVisible
        workspace?.pageHost?.updateMapFocus()
        view.layoutSubtreeIfNeeded();scheduleMapRender()
    }
    @objc func enterFullScreen() {view.window?.toggleFullScreen(nil)}
    @objc func zoomInMap() {mapViewport.zoom(by:1.5);opticalZoomChanged()}
    @objc func zoomOutMap() {mapViewport.zoom(by:1/1.5);opticalZoomChanged()}
    @objc func fitMap() {mapViewport.fitMap();opticalZoomChanged()}
    @objc func goRoot() {navigate(1)}
    @objc func mapBack() {
        guard let id=mapHistory.popLast(),let current=focusNode?.id else{return}
        mapFuture.append(current);navigate(id,remember:false)
    }
    @objc func mapForward() {
        guard let id=mapFuture.popLast(),let current=focusNode?.id else{return}
        mapHistory.append(current);navigate(id,remember:false)
    }
    @objc func chooseAncestor() {
        if let id=ancestor.selectedItem?.representedObject as? Int64 {navigate(id)}
    }
    @objc func detailChanged() {render()}
    func opticalZoomChanged() {
        canvas.displayScale=mapViewport.magnification;canvas.needsDisplay=true
        zoomLevel.stringValue="\(Int((mapViewport.magnification*100).rounded()))%"
        scheduleMapRender()
    }
    func scheduleMapRender() {
        mapDebounce?.cancel()
        let work=DispatchWorkItem {[weak self] in self?.render()};mapDebounce=work
        DispatchQueue.main.asyncAfter(deadline:.now()+0.16,execute:work)
    }
    func updateMapNavigation() {
        mapBackButton.isEnabled = !mapHistory.isEmpty;mapForwardButton.isEnabled = !mapFuture.isEmpty
        ancestor.removeAllItems();guard let store=store,let info=info,var node=focusNode else {ancestor.addItem(withTitle:"No scan loaded");return}
        var chain=[node],seen:Set<Int64>=[node.id]
        while node.parent>0,chain.count<128,let parent=try? store.node(node.parent),seen.insert(parent.id).inserted {chain.append(parent);node=parent}
        for n in chain.reversed() {
            ancestor.addItem(withTitle:(n.id==focusNode?.id ? "● ":"")+String(repeating:"  ",count:min(8,n.depth))+(n.name.isEmpty ? info.root:n.name));ancestor.lastItem?.representedObject=n.id
        }
        ancestor.selectItem(at:ancestor.numberOfItems-1);ancestor.toolTip=store.path(focusNode!,info)
    }
}
