import Foundation

public extension Textus {
    
    public enum Truncating: Hashable {
        
        case clip
        case head
        case middle
        case tail
        
        public var lineBreakMode: NSLineBreakMode {
            switch self {
            case .clip:
                return .byClipping
            case .head:
                return .byTruncatingHead
            case .middle:
                return .byTruncatingMiddle
            case .tail:
                return .byTruncatingTail
            }
        }
    }
}
