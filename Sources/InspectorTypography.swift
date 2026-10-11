import AppKit

// Selectable native text remains available to VoiceOver and copy/paste. Paths
// use a compact monospace face; explanations use normal reading typography.
final class KonMagicInspector:NSTextView {
    override var string:String {
        get {super.string}
        set {
            super.string=newValue
            let paragraph=NSMutableParagraphStyle();paragraph.lineSpacing=3
            let styled=NSMutableAttributedString(string:newValue,attributes:[.font:NSFont.systemFont(ofSize:12),.foregroundColor:NSColor.labelColor,.paragraphStyle:paragraph])
            var offset=0
            for line in newValue.components(separatedBy:"\n") {
                let length=(line as NSString).length,range=NSRange(location:offset,length:length)
                if line.hasPrefix("/") {styled.addAttributes([.font:NSFont.monospacedSystemFont(ofSize:11,weight:.regular),.foregroundColor:NSColor.secondaryLabelColor],range:range)}
                else if !line.isEmpty,line.count<110,line.contains(where:{$0.isLetter}),line==line.uppercased() || line.hasPrefix("SOURCE ·") || line.hasPrefix("CHOSEN DESTINATION") {styled.addAttributes([.font:NSFont.systemFont(ofSize:11,weight:.semibold),.foregroundColor:NSColor.secondaryLabelColor],range:range)}
                offset+=length+1
            }
            textStorage?.setAttributedString(styled)
        }
    }
}

func friendlyObservationDate(_ value:String)->String {
    guard let date=ISO8601DateFormatter().date(from:value) else {return value}
    let f=DateFormatter();f.dateStyle = .medium;f.timeStyle = .short;return f.string(from:date)
}
