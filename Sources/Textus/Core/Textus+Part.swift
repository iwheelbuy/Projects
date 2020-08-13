import UIKit

public extension Textus {
    ///
    public struct Part: Hashable {
        ///
        public let font: UIFont
        ///
        public let foregroundColor: UIColor?
        ///
        public let letterSpacing: CGFloat?
        ///
        public let load: Textus.Load?
        ///
        public let position: Textus.Position?
        ///
        public let strikethrough: Textus.Accent?
        ///
        public let string: String
        ///
        public let underline: Textus.Accent?
        /// Normal
        public init(font: UIFont, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil, load: Textus.Load? = nil, position: Textus.Position? = nil, strikethrough: Textus.Accent? = nil, string: String?, underline: Textus.Accent? = nil) {
            self.font = font
            self.foregroundColor = foregroundColor
            self.letterSpacing = letterSpacing
            self.load = load
            self.position = position
            self.strikethrough = strikethrough
            self.string = string ?? ""
            self.underline = underline
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(string.count)
        }

        public static func ==(lhs: Textus.Part, rhs: Textus.Part) -> Bool {
            guard lhs.letterSpacing == rhs.letterSpacing else {
                return false
            }
            guard lhs.position == rhs.position else {
                return false
            }
            guard lhs.strikethrough == rhs.strikethrough else {
                return false
            }
            guard lhs.underline == rhs.underline else {
                return false
            }
            guard lhs.load == rhs.load else {
                return false
            }
            guard lhs.string == rhs.string else {
                return false
            }
            guard lhs.font == rhs.font else {
                return false
            }
            guard lhs.foregroundColor == rhs.foregroundColor else {
                return false
            }
            return true
        }
    }
}

extension Textus.Part {
    /// HTML
    public static func html(font: UIFont, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil, modifier: Textus.Modifier? = Textus.modifier, position: Textus.Position? = nil, strikethrough: Textus.Accent? = nil, string: String?, underline: Textus.Accent? = nil) throws -> [Textus.Part] {
        let string = string ?? ""
        return try {
            let attributedString: NSAttributedString = try {
                let html = "<div>" + string + "</div>"
                guard let data = html.data(using: String.Encoding.unicode, allowLossyConversion: true) else {
                    throw NSError(domain: #file, code: #line, userInfo: nil)
                }
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.html
                ]
                return try NSAttributedString(data: data, options: options, documentAttributes: nil)
                }()
            let range: NSRange = {
                let length = attributedString.length
                return NSRange(location: 0, length: length)
            }()
            var parts = [Textus.Part]()
            attributedString.enumerateAttributes(in: range, options: [], using: { (attributes: [NSAttributedString.Key: Any], range, _) in
                let string = attributedString.attributedSubstring(from: range).string
                let part = Textus.Part(
                    font: font,
                    foregroundColor: foregroundColor,
                    letterSpacing: letterSpacing,
                    position: position,
                    strikethrough: strikethrough,
                    string: string,
                    underline: underline
                )
                parts.append(modifier?(attributes, part) ?? part)
            })
            return parts
        }()
    }

    public func with(font: UIFont? = nil, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil, load: Textus.Load? = nil, position: Textus.Position? = nil, strikethrough: Textus.Accent? = nil, string: String? = nil, underline: Textus.Accent? = nil) -> Textus.Part {
        return Textus.Part(
            font: font ?? self.font,
            foregroundColor: foregroundColor ?? self.foregroundColor,
            letterSpacing: letterSpacing ?? self.letterSpacing,
            load: load ?? self.load,
            position: position ?? self.position,
            strikethrough: strikethrough ?? self.strikethrough,
            string: string ?? self.string,
            underline: underline ?? self.underline
        )
    }

    private func baselineOffset(lineHeight: CGFloat) -> CGFloat {
        let position = self.position ?? .center(0)
        switch lineHeight - font.lineHeight {
        case ..<0:
            switch position {
            case .bottom(let offset):
                return offset + (lineHeight - font.lineHeight) / 4
            case .center(let offset):
                return offset + (lineHeight - font.lineHeight) / 2
            case .top(let offset):
                return offset + 3 * (lineHeight - font.lineHeight) / 4
            }
        case 0:
            switch position {
            case .bottom(let offset), .center(let offset), .top(let offset):
                return offset
            }
        default:
            switch position {
            case .bottom(let offset):
                return offset
            case .center(let offset):
                return offset + (lineHeight - font.lineHeight) / 4
            case .top(let offset):
                return offset + (lineHeight - font.lineHeight) / 2
            }
        }
    }

    public func attributedString(lineHeight: CGFloat, paragraphStyle: NSParagraphStyle) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.baselineOffset] = self.baselineOffset(lineHeight: lineHeight)
        attributes[.font] = self.font
        if let value = self.foregroundColor {
            attributes[.foregroundColor] = value
        }
        if let value = self.letterSpacing {
            attributes[.kern] = value
        }
        attributes[.paragraphStyle] = paragraphStyle
        if let value = self.strikethrough {
            attributes[.strikethroughColor] = value.color
            attributes[.strikethroughStyle] = value.style.rawValue
        }
        if let value = self.underline {
            attributes[.underlineColor] = value.color
            attributes[.underlineStyle] = value.style.rawValue
        }
        return NSAttributedString(string: self.string, attributes: attributes)
    }
}
