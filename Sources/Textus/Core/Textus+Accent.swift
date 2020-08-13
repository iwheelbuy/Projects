import UIKit

public extension Textus {
    ///
    public struct Accent: Hashable {

        public let color: UIColor
        public let style: NSUnderlineStyle

        public init(color: UIColor, style: NSUnderlineStyle) {
            self.color = color
            self.style = style
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(color)
            hasher.combine(style.rawValue)
        }

        public static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.color == rhs.color && lhs.style.rawValue == rhs.style.rawValue
        }
    }
}
