import Foundation

public extension Textus {

    public typealias Modifier = ([NSAttributedString.Key: Any], Textus.Part) -> Textus.Part

    public static let modifier: Textus.Modifier = { (attributes: [NSAttributedString.Key: Any], part: Textus.Part) -> Textus.Part in
        guard let url = attributes[.link] as? URL else {
            return part
        }
        let load = Textus.Load.url(url)
        return part.with(load: load)
    }
}
