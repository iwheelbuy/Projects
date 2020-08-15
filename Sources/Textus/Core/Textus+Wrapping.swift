import UIKit

public extension Textus {
    
    public enum Wrapping {
        
        case char
        case word
        
        public var lineBreakMode: NSLineBreakMode {
            switch self {
            case .char:
                return .byCharWrapping
            case .word:
                return .byWordWrapping
            }
        }
    }
}
