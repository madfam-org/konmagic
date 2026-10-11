import AppKit

extension KonMagicDelegate {
    func runToolkitQA() {
        DispatchQueue.main.asyncAfter(deadline:.now()+3) {
            guard let hub=self.controller.toolkit,let v=self.window.contentView else {exit(1)}
            v.layoutSubtreeIfNeeded()
            if let bitmap=v.bitmapImageRepForCachingDisplay(in:v.bounds) {v.effectiveAppearance.performAsCurrentDrawingAppearance {v.cacheDisplay(in:v.bounds,to:bitmap)};if let data=bitmap.representation(using:.png,properties:[:]),let path=ProcessInfo.processInfo.environment["KONMAGIC_QA_IMAGE"] {try? data.write(to:URL(fileURLWithPath:path));try? FileManager.default.setAttributes([.posixPermissions:0o600],ofItemAtPath:path)}}
            let cards=hub.cards.count==4 && hub.cards.allSatisfy {$0.frame.width>400 && $0.frame.height>=200 && $0.actionButton.action != nil && $0.actionButton.target === hub}
            let keys=NSApp.mainMenu?.items.flatMap {$0.submenu?.items ?? []}.compactMap {"01234".contains($0.keyEquivalent) && !$0.keyEquivalent.isEmpty ? $0.keyEquivalent : nil} ?? []
            self.controller.showWorkspace();self.controller.showReview();self.controller.showToolkit()
            let routed=self.controller.view.window != nil && hub.view.window===self.window && !self.controller.applyButton.isEnabled
            let passed=cards && Set(keys)==Set(["0","1","2","3","4"]) && routed
            print("TOOLKIT_UI_QA passed=\(passed); cards=\(hub.cards.count); keyboardRoutes=\(keys.count); returnToOverview=\(routed); sourceOperations=0")
            if !passed {exit(1)};NSApp.terminate(nil)
        }
    }
}
