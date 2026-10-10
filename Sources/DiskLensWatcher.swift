import Foundation
import CoreServices

// Incremental refresh is available only for a live view watched in this session.
final class LensWatcher {
    private var stream:FSEventStreamRef?
    private let lock=NSLock(),queue=DispatchQueue(label:"org.madfam.konmagic.disk-events",qos:.utility)
    private var paths:Set<String>=[],gap=false
    init?(root:String) {
        var context=FSEventStreamContext(version:0,info:Unmanaged.passUnretained(self).toOpaque(),retain:nil,release:nil,copyDescription:nil)
        let flags=FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents|kFSEventStreamCreateFlagWatchRoot)
        stream=FSEventStreamCreate(nil,{_,context,count,eventPaths,eventFlags,_ in
            guard let context=context else{return};let watcher=Unmanaged<LensWatcher>.fromOpaque(context).takeUnretainedValue()
            let values=eventPaths.assumingMemoryBound(to:UnsafePointer<CChar>.self)
            watcher.lock.lock();defer {watcher.lock.unlock()}
            for i in 0..<count {
                let flag=eventFlags[i]
                if flag & UInt32(kFSEventStreamEventFlagMustScanSubDirs|kFSEventStreamEventFlagUserDropped|kFSEventStreamEventFlagKernelDropped|kFSEventStreamEventFlagRootChanged|kFSEventStreamEventFlagUnmount) != 0 {watcher.gap=true}
                let path=String(cString:values[i])
                watcher.paths.insert(URL(fileURLWithPath:path).deletingLastPathComponent().path)
                if flag & UInt32(kFSEventStreamEventFlagItemIsDir) != 0 {watcher.paths.insert(path)}
            }
            if watcher.paths.count>10_000 {watcher.gap=true;watcher.paths.removeAll()}
        },&context,[root] as CFArray,FSEventStreamEventId(kFSEventStreamEventIdSinceNow),0.25,flags)
        guard let stream=stream else{return nil};FSEventStreamSetDispatchQueue(stream,queue)
        if !FSEventStreamStart(stream) {FSEventStreamInvalidate(stream);FSEventStreamRelease(stream);self.stream=nil;return nil}
    }
    deinit {if let stream=stream {FSEventStreamStop(stream);FSEventStreamInvalidate(stream);queue.sync {};FSEventStreamRelease(stream)}}
    func consume()->Set<String>? {
        if let stream=stream {FSEventStreamFlushSync(stream)}
        lock.lock();defer {lock.unlock()};let result=gap ? nil:paths;paths=[];gap=false;return result
    }
}
