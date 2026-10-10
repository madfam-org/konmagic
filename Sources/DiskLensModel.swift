import Foundation
import Darwin
import UniformTypeIdentifiers

enum LensMeasure:String,CaseIterable,Codable {case logical,allocated,tally
    var title:String {switch self {case .logical:return "Logical bytes";case .allocated:return "Allocated bytes";case .tally:return "File tally"}}
}
enum LensDisplay:String,CaseIterable,Codable {case files,packages,folders
    var title:String {switch self {case .files:return "Files";case .packages:return "Packages & files";case .folders:return "Packages & folders"}}
}
enum LensColor:String,CaseIterable,Codable {case name,extensionName,type,parent,top,depth,size,creation,modified,access,protection,none
    var title:String {switch self {case .extensionName:return "Extension";case .type:return "File type";case .parent:return "Parent folder";case .top:return "Top folder";case .depth:return "Hierarchy depth";case .creation:return "Creation time";case .modified:return "Modification time";case .access:return "Last access time";case .protection:return "Protection";default:return rawValue.capitalized}}
}
enum LensPalette:String,CaseIterable,Codable {case rainbow,ocean,forest,ember,accessible,monochrome}
enum LensField:String,CaseIterable,Codable {case name,path,extensionName,type,logical,allocated,modified,creation,access,hardLink,package,cloud,kind
    var title:String {switch self {case .extensionName:return "Extension";case .hardLink:return "Hard link";default:return rawValue.capitalized}}
}
enum LensOperator:String,CaseIterable,Codable {case contains,equals,starts,ends,conforms,minimum,maximum,isTrue,isFalse}
struct LensRule:Codable,Equatable {
    var field:LensField = .name,operation:LensOperator = .contains,value="",negated=false
    func matches(_ node:LensNode,path:String)->Bool {
        let string:String,number:Int64?,boolean:Bool?
        switch field {
        case .name:string=node.name;number=nil;boolean=nil
        case .path:string=path;number=nil;boolean=nil
        case .extensionName:string=(node.name as NSString).pathExtension;number=nil;boolean=nil
        case .type:string=UTType(filenameExtension:(node.name as NSString).pathExtension)?.identifier ?? "public.data";number=nil;boolean=nil
        case .kind:string=node.kindName;number=nil;boolean=nil
        case .logical:string="";number=node.bytes;boolean=nil
        case .allocated:string="";number=node.allocated;boolean=nil
        case .modified:string="";number=node.modified;boolean=nil
        case .creation:string="";number=node.created;boolean=nil
        case .access:string="";number=node.accessed;boolean=nil
        case .hardLink:string="";number=nil;boolean=(!node.directory && node.links>1) || node.duplicate
        case .package:string="";number=nil;boolean=node.package
        case .cloud:string="";number=nil;boolean=node.cloud
        }
        let result:Bool
        if let boolean=boolean {result=operation == .isFalse ? !boolean : operation == .isTrue && boolean}
        else if let number=number,let target=Int64(value) {
            result=operation == .minimum ? number>=target : operation == .maximum ? number<=target : operation == .equals && number==target
        } else {
            let a=string.lowercased(),b=value.lowercased()
            switch operation {case .contains:result=a.contains(b);case .equals:result=a==b;case .starts:result=a.hasPrefix(b);case .ends:result=a.hasSuffix(b);case .conforms:result=field == .type && UTType(importedAs:a).conforms(to:UTType(importedAs:b));default:result=false}
        }
        return negated ? !result : result
    }
}
struct LensTestGroup:Codable,Equatable {
    var name="Compound test",rules:[LensRule]=[],negated=false,scope="files"
    func matches(_ node:LensNode,path:String)->Bool {
        if scope=="files" && node.directory {return false}
        if scope=="folders" && !node.directory {
            var ancestor=URL(fileURLWithPath:path).deletingLastPathComponent()
            for _ in 0..<256 {
                var folder=LensNode();folder.kind=1;folder.name=ancestor.lastPathComponent;folder.package=LensNode.packageName(folder.name)
                if rules.allSatisfy({$0.matches(folder,path:ancestor.path+"/")}) {return true}
                if ancestor.path=="/" {break};ancestor.deleteLastPathComponent()
            };return false
        }
        return rules.allSatisfy {$0.matches(node,path:node.directory ? path+"/":path)}
    }
}
struct LensFilter:Codable,Equatable {
    var name="Untitled filter",rules:[LensRule]=[],matchAll=true
    var includeAnyExcludeAll=false
    var groups:[LensTestGroup]=[]
    init(name:String="Untitled filter",rules:[LensRule]=[],matchAll:Bool=true,includeAnyExcludeAll:Bool=false,groups:[LensTestGroup]=[]) {self.name=name;self.rules=rules;self.matchAll=matchAll;self.includeAnyExcludeAll=includeAnyExcludeAll;self.groups=groups}
    enum CodingKeys:String,CodingKey {case name,rules,matchAll,includeAnyExcludeAll,groups}
    init(from decoder:Decoder) throws {let c=try decoder.container(keyedBy:CodingKeys.self);name=try c.decodeIfPresent(String.self,forKey:.name) ?? "Untitled filter";rules=try c.decodeIfPresent([LensRule].self,forKey:.rules) ?? [];matchAll=try c.decodeIfPresent(Bool.self,forKey:.matchAll) ?? true;includeAnyExcludeAll=try c.decodeIfPresent(Bool.self,forKey:.includeAnyExcludeAll) ?? false;groups=try c.decodeIfPresent([LensTestGroup].self,forKey:.groups) ?? []}
    func matches(_ node:LensNode,path:String)->Bool {
        let base:Bool
        if rules.isEmpty {base=true}
        else if includeAnyExcludeAll {let positive=rules.filter {!$0.negated},negative=rules.filter(\.negated);base=(positive.isEmpty || positive.contains {$0.matches(node,path:path)}) && negative.allSatisfy {$0.matches(node,path:path)}}
        else {base=matchAll ? rules.allSatisfy {$0.matches(node,path:path)} : rules.contains {$0.matches(node,path:path)}}
        let positive=groups.filter {!$0.negated},negative=groups.filter(\.negated)
        return base && (positive.isEmpty || positive.contains {$0.matches(node,path:path)}) && negative.allSatisfy {!$0.matches(node,path:path)}
    }
    func validate() throws {
        guard rules.count<=32,groups.count<=8,rules.count+groups.reduce(0,{$0+$1.rules.count})<=64,name.count<=160 else {throw KonMagicError("Keep within 32 flat tests, eight compound groups and 64 subtests total.")}
        for group in groups {
            guard ["files","folders","both"].contains(group.scope),!group.rules.isEmpty else {throw KonMagicError("Give each compound group a scope and at least one test.")}
            if group.scope=="folders" {guard group.negated,group.rules.allSatisfy({[.name,.path,.package,.kind].contains($0.field)}) else {throw KonMagicError("Folder groups exclude ancestors and use name, path, package or kind. File-only size/date/type tests belong in a file group.")}}
        }
        for rule in rules+groups.flatMap(\.rules) {
            guard rule.value.count<=500,!rule.value.contains("\0") else {throw KonMagicError("Filter value exceeds its bound.")}
            if [.logical,.allocated,.modified,.creation,.access].contains(rule.field) {
                guard [.minimum,.maximum,.equals].contains(rule.operation),let n=Int64(rule.value),n>=0 else {throw KonMagicError("Size tests use nonnegative bytes. Date tests use nonnegative Unix seconds. Choose minimum, maximum or equals.")}
            } else if [.hardLink,.package,.cloud].contains(rule.field) {
                guard [.isTrue,.isFalse].contains(rule.operation) else {throw KonMagicError("Boolean tests use isTrue or isFalse.")}
            } else if rule.operation == .conforms && rule.field != .type {throw KonMagicError("Conforms tests require a file type identifier, such as public.image.")}
            else if ![.contains,.equals,.starts,.ends,.conforms].contains(rule.operation) {throw KonMagicError("Text tests use contains, equals, starts or ends.")}
        }
    }
}
struct LensTotals:Codable,Equatable {
    var bytes:Int64=0,allocated:Int64=0,count:Int64=0
    static func +(a:LensTotals,b:LensTotals)->LensTotals {LensTotals(bytes:a.bytes+b.bytes,allocated:a.allocated+b.allocated,count:a.count+b.count)}
    func weight(_ measure:LensMeasure)->Int64 {switch measure {case .logical:return bytes;case .allocated:return allocated;case .tally:return count}}
}
struct LensNode {
    var id:Int64=0,parent:Int64=0,name="",kind=0,relative=""
    var bytes:Int64=0,allocated:Int64=0,modified:Int64=0,created:Int64=0,accessed:Int64=0,device:Int64=0,inode:Int64=0,links:Int64=0,flags:UInt32=0
    var package=false,duplicate=false,error="",depth=0,total=LensTotals()
    var directory:Bool {kind==1}
    var cloud:Bool {flags & 0x40000000 != 0 || name.hasSuffix(".icloud")}
    var kindName:String {switch kind {case 0:return "file";case 1:return "directory";case 2:return "link";default:return "special"}}
    var ownTotal:LensTotals {kind==0 && !duplicate ? LensTotals(bytes:max(0,bytes),allocated:max(0,allocated),count:1) : LensTotals()}
    static func metadata(_ s:stat,name:String,parent:Int64,relative:String,depth:Int)->LensNode {
        var n=LensNode();n.parent=parent;n.name=name;n.relative=relative;n.depth=depth
        n.kind=SafeFS.isDirectory(s) ? 1 : SafeFS.isFile(s) ? 0 : s.st_mode & S_IFMT == S_IFLNK ? 2 : 3
        n.bytes=max(0,s.st_size);n.allocated=max(0,Int64(s.st_blocks)*512);n.modified=Int64(s.st_mtimespec.tv_sec);n.created=Int64(s.st_birthtimespec.tv_sec);n.accessed=Int64(s.st_atimespec.tv_sec)
        n.device=Int64(s.st_dev);n.inode=Int64(bitPattern:UInt64(s.st_ino));n.links=Int64(s.st_nlink);n.flags=s.st_flags
        n.package=n.directory && packageName(name);return n
    }
    static func packageName(_ name:String)->Bool {let ext=(name as NSString).pathExtension.lowercased();return ["app","bundle","framework","plugin","component","vst","vst3","aaxplugin","photoslibrary","musiclibrary","imovielibrary","band","pages","numbers","key","rtfd","playground","xcworkspace","xcodeproj"].contains(ext)}
}
struct LensSnapshot:Codable {
    var version=1,id=UUID().uuidString,root="",source="",started=Date(),finished:Date?,status="scanning",entries:Int64=0,issues:Int64=0
    var totals=LensTotals(),capacity:Int64=0,free:Int64=0,filter=LensFilter(),comments="",datesKnown=true,linksKnown=true
    var excluded:Int64=0,cloud:Int64=0,duplicates:Int64=0
    var exclusions:LensFilter?
}
struct LensPreferences:Codable {
    var measure=LensMeasure.allocated,display=LensDisplay.packages,color=LensColor.extensionName,palette=LensPalette.ocean,depth=4,binaryUnits=true,showVolume=false
    var filters:[LensFilter]=[],defaultFilter=LensFilter(),recent:[String]=[]
    var scanExclusion=LensFilter(),typeMappings:[String:String]=[:]
    var lastWindow="quit",retainPreviousWindow=false
    static func load(_ directory:URL)->LensPreferences {
        guard let parent=try? SafeFS.openDirectory(directory.path) else {return Self()};defer {close(parent)}
        let fd=openat(parent,"disk-lens-preferences.json",O_RDONLY|O_NOFOLLOW);guard fd>=0 else{return Self()};defer {close(fd)}
        var st=stat();guard fstat(fd,&st)==0,SafeFS.isFile(st),st.st_size<=1024*1024,st.st_uid==getuid(),st.st_mode & 0o077==0 else{return Self()}
        let data=FileHandle(fileDescriptor:fd,closeOnDealloc:false).readDataToEndOfFile();return (try? JSONDecoder().decode(Self.self,from:data)) ?? Self()
    }
    func save(_ directory:URL) throws {try SafeFS.writeRecord(self,at:directory.appendingPathComponent("disk-lens-preferences.json"))}
}
