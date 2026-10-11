import Foundation
import AppKit
import Darwin

struct VolumeContext {
    let observed:Date
    let details:String
    static func command(_ arguments:[String],cancellation:CatalogueCancellation?=nil) throws -> [String:Any] {
        let task=Process(),pipe=Pipe(),ended=DispatchSemaphore(value:0),drained=DispatchSemaphore(value:0),lock=NSLock()
        var data=Data(),overflow=false
        task.executableURL=URL(fileURLWithPath:"/usr/sbin/diskutil");task.arguments=arguments
        task.standardOutput=pipe;task.standardError=FileHandle.nullDevice;task.terminationHandler={_ in ended.signal()}
        try task.run()
        DispatchQueue.global(qos:.utility).async {
            while true {
                let chunk=pipe.fileHandleForReading.readData(ofLength:16*1024)
                if chunk.isEmpty {break}
                lock.lock();if data.count+chunk.count<=16*1024*1024 {data.append(chunk)} else {overflow=true};let stop=overflow;lock.unlock()
                if stop {if task.isRunning {task.terminate()};break}
            };drained.signal()
        }
        let deadline=Date().addingTimeInterval(12)
        var done=false
        while Date()<deadline,cancellation?.cancelled != true {if ended.wait(timeout:.now()+0.1) == .success {done=true;break}}
        if !done {
            if task.isRunning {task.terminate()}
            if ended.wait(timeout:.now()+1) == .timedOut {kill(task.processIdentifier,SIGKILL)}
            throw KonMagicError(cancellation?.cancelled == true ? "Volume observation stopped. No settings changed." : "Volume observation timed out. No disk settings were changed.")
        }
        guard drained.wait(timeout:.now()+2) == .success else {throw KonMagicError("Volume metadata could not be completely read.")}
        lock.lock();let bytes=data,tooLarge=overflow;lock.unlock()
        guard task.terminationStatus==0,!tooLarge,let record=try PropertyListSerialization.propertyList(from:bytes,options:[],format:nil) as? [String:Any] else {throw KonMagicError("macOS did not provide eligible volume metadata. No repair or privilege escalation was attempted.")}
        return record
    }
    static func observe(_ root:String,cancellation:CatalogueCancellation?=nil) throws -> VolumeContext {
        _ = try SafeFS.components(root)
        let record=try command(["info","-plist",root],cancellation:cancellation),time=Date()
        let apfs=(record["FilesystemType"] as? String)=="apfs"
        let amount:(Any?)->String={value in guard let n=value as? NSNumber else{return "Unknown"};return ByteCountFormatter.string(fromByteCount:n.int64Value,countStyle:.binary)}
        var lines=["LIVE VOLUME CONTEXT",ISO8601DateFormatter().string(from:time),"Requested path: "+root,"Mount: "+(record["MountPoint"] as? String ?? "Unknown"),"Filesystem: "+(record["FilesystemType"] as? String ?? "Unknown"),"Volume: "+(record["VolumeName"] as? String ?? "Unknown"),"Read-only observation · no source file bodies opened",""]
        if !apfs {lines += ["Volume size: "+amount(record["TotalSize"]),"Reported free: "+amount(record["FreeSpace"])]}
        else {
            lines += ["APFS container size: "+amount(record["APFSContainerSize"]),"Shared container free: "+amount(record["APFSContainerFree"]),"Booted from an APFS snapshot: "+String(record["APFSSnapshot"] as? Bool ?? false),""]
            let all=try command(["apfs","list","-plist"],cancellation:cancellation),ref=record["APFSContainerReference"] as? String
            if let container=(all["Containers"] as? [[String:Any]])?.first(where:{$0["ContainerReference"] as? String==ref}) {
                lines += ["SHARED CONTAINER VOLUMES","Container capacity: "+amount(container["CapacityCeiling"]),"Container free at second observation: "+amount(container["CapacityFree"])]
                for v in ((container["Volumes"] as? [[String:Any]]) ?? []).prefix(16) {
                    guard cancellation?.cancelled != true else {throw KonMagicError("Volume observation stopped; disk settings unchanged.")}
                    let id=v["DeviceIdentifier"] as? String ?? "",name=v["Name"] as? String ?? "Unnamed",roles=(v["Roles"] as? [String])?.joined(separator:", ") ?? ""
                    lines += ["",name+" · "+id+" · "+roles,"Capacity in use: "+amount(v["CapacityInUse"]),"Quota: "+amount(v["CapacityQuota"])+" · Reserve: "+amount(v["CapacityReserve"])]
                    guard id.range(of:"^disk[0-9]+(s[0-9]+)*$",options:.regularExpression) != nil else {continue}
                    do {
                        let snapshots=try command(["apfs","listSnapshots",id,"-plist"],cancellation:cancellation)
                        let list=snapshots["Snapshots"] as? [[String:Any]] ?? []
                        lines.append("Snapshots reported: \(list.count)")
                        for s in list.prefix(100) {lines.append("  "+(s["Name"] as? String ?? "Unnamed")+" · purgeable: "+String(s["Purgeable"] as? Bool ?? false))}
                        if list.count>100 {lines.append("  First 100 snapshot names shown.")}
                    } catch {lines.append("Snapshot coverage unavailable: "+error.localizedDescription)}
                }
            } else {lines.append("Matching container details unavailable.")}
        }
        lines += ["","INTERPRETATION","APFS volumes share container space. File allocation totals can overlap through clones, hard links, snapshots and multiple observations. Snapshot names and purgeable flags do not establish reclaimable bytes. Removing a file may not release its blocks while a snapshot retains them.","","This view reports macOS metadata only. KonMagic does not purge snapshots, repair volumes, change quotas or create a backup. Keep unique data and recovery snapshots until independent preservation is verified."]
        return VolumeContext(observed:time,details:lines.joined(separator:"\n"))
    }
}
extension DiskLensController {
    @objc func showVolumeContext() {
        let root=info?.root ?? "/"
        perform("Reading volume and snapshot metadata…",{try VolumeContext.observe(root,cancellation:self.operationCancellation)}) {context in
            let w=NSWindow(contentRect:NSRect(x:0,y:0,width:850,height:650),styleMask:[.titled,.closable,.resizable],backing:.buffered,defer:false)
            w.title="KonMagic · Volume & snapshots";w.isReleasedWhenClosed=false
            let t=KonMagicInspector(frame:NSRect(x:0,y:0,width:850,height:650));t.isEditable=false;t.isVerticallyResizable=true;t.font=NSFont.monospacedSystemFont(ofSize:12,weight:.regular);t.string=context.details;t.textContainerInset=NSSize(width:18,height:18);t.autoresizingMask=[.width];t.textContainer?.widthTracksTextView=true
            let scroll=NSScrollView(frame:t.frame);scroll.documentView=t;scroll.hasVerticalScroller=true;scroll.autoresizingMask=[.width,.height];w.contentView=scroll;w.center();w.makeKeyAndOrderFront(nil);self.comparisonWindows.append(w)
            self.status.stringValue="Live volume context observed; no disk settings or snapshots changed."
        }
    }
}
