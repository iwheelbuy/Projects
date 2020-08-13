import UIKit

public struct Textus: Hashable, TextusRepresentable {
    ///
    public let alignment: Textus.Alignment
    ///
    public let lineHeight: CGFloat
    ///
    public let parts: [Textus.Part]
    ///
    public let truncating: Textus.Truncating
    ///
    public let wrapping: Textus.Wrapping
    /// Elements without line height
    public init(alignment: Textus.Alignment = .left, lineHeight: CGFloat? = nil, parts: [Textus.Part], truncating: Textus.Truncating = .tail, wrapping: Textus.Wrapping = .word) {
        self.alignment = alignment
        self.lineHeight = lineHeight ?? parts.map({ ceil($0.font.lineHeight) }).max() ?? 0
        self.parts = parts
        self.truncating = truncating
        self.wrapping = wrapping
    }
    /// String
    public init(alignment: Textus.Alignment = .left, font: UIFont, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil, lineHeight: CGFloat? = nil, position: Textus.Position? = nil, strikethrough: Textus.Accent? = nil, string: String?, truncating: Textus.Truncating = .tail, underline: Textus.Accent? = nil, wrapping: Textus.Wrapping = .word) {
        self.alignment = alignment
        self.lineHeight = lineHeight ?? ceil(font.lineHeight)
        self.parts = {
            let part = Textus.Part(
                font: font,
                foregroundColor: foregroundColor,
                letterSpacing: letterSpacing,
                position: position,
                strikethrough: strikethrough,
                string: string,
                underline: underline
            )
            return [part]
        }()
        self.truncating = truncating
        self.wrapping = wrapping
    }
    /// HTML
    public init(alignment: Textus.Alignment = .left, font: UIFont, foregroundColor: UIColor? = nil, html string: String?, letterSpacing: CGFloat? = nil, lineHeight: CGFloat? = nil, modifier: Textus.Modifier? = Textus.modifier, position: Textus.Position? = nil, strikethrough: Textus.Accent? = nil, truncating: Textus.Truncating = .tail, underline: Textus.Accent? = nil, wrapping: Textus.Wrapping = .word) throws {
        self.alignment = alignment
        self.parts = try Textus.Part.html(
            font: font,
            foregroundColor: foregroundColor,
            letterSpacing: letterSpacing,
            modifier: modifier,
            position: position,
            strikethrough: strikethrough,
            string: string,
            underline: underline
        )
        self.lineHeight = lineHeight ?? ceil(font.lineHeight)
        self.truncating = truncating
        self.wrapping = wrapping
    }
}
