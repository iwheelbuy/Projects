import UIKit

public protocol TextusRepresentable {
    //
    var alignment: Textus.Alignment { get }
    ///
    var parts: [Textus.Part] { get }
    ///
    var lineHeight: CGFloat { get }
    ///
    var truncating: Textus.Truncating { get }
    ///
    var wrapping: Textus.Wrapping { get }
}

extension TextusRepresentable {

    public var attributedString: NSAttributedString {
        let lineHeight = self.lineHeight
        let paragraphStyle: NSParagraphStyle = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.alignment
            paragraphStyle.lineBreakMode = self.wrapping.lineBreakMode
            paragraphStyle.lineSpacing = 0
            paragraphStyle.maximumLineHeight = lineHeight
            paragraphStyle.minimumLineHeight = lineHeight
            return paragraphStyle
        }()
        return parts
            .reduce(into: NSMutableAttributedString(), { (full, part) in
                let part = part.attributedString(
                    lineHeight: lineHeight,
                    paragraphStyle: paragraphStyle
                )
                full.append(part)
            })
    }

    public var attributedText: NSAttributedString {
        return self.attributedString
    }

    @available(*, deprecated, message: "Надо заменить вытаскивание параметров из NSAttributedString на вытаскивание параметров напрямую из Textus")
    public var attributes: [NSAttributedString.Key: Any] {
        let attirbutedString = self.attributedString
        let length = attirbutedString.length
        let range = NSRange(location: 0, length: length)
        var dictionary = [NSAttributedString.Key: Any]()
        attirbutedString.enumerateAttributes(in: range, options: []) { [length] (attributes, range, _) in
            if range.location == 0, range.length == length {
                for (key, value) in attributes {
                    dictionary[key] = value
                }
            }
        }
        return dictionary
    }

    public var string: String {
        return parts.map({ $0.string }).joined()
    }

    public var urls: [URL] {
        return parts.compactMap({ $0.load?.url })
    }

    public func appending<T>(_ string: T) -> Textus where T: TextusRepresentable {
        return self.with(
            lineHeight: max(self.lineHeight, string.lineHeight),
            parts: self.parts + string.parts
        )
    }

    public func prefix(_ maxLength: Int) -> Textus {
        var index: Int = 0
        var parts = [Textus.Part]()
        parts.reserveCapacity(self.parts.count)
        for part in self.parts where index < maxLength {
            let count = maxLength - index
            if part.string.count <= count {
                parts.append(part)
                index += part.string.count
            } else {
                let string = String(part.string.prefix(count))
                parts.append(part.with(string: string))
                index += string.count
            }
        }
        return self.with(parts: parts)
    }

    public func with(alignment: Textus.Alignment? = nil, lineHeight: CGFloat? = nil, parts: [Textus.Part]? = nil, truncating: Textus.Truncating? = nil, wrapping: Textus.Wrapping? = nil) -> Textus {
        return Textus(
            alignment: alignment ?? self.alignment,
            lineHeight: lineHeight ?? self.lineHeight,
            parts: parts ?? self.parts,
            truncating: truncating ?? self.truncating,
            wrapping: wrapping ?? self.wrapping
        )
    }
}
