import Core
import UIKit

extension Textus {

    public struct Crop: Hashable {

        private struct Key: Hashable {

            let limit: Textus.Limit
            let textus: Textus?
            let width: CGFloat
        }

        public static let height: CGFloat = 10000
        public static let lines: Int = 1000

        private static let cache = Cache<Textus.Crop.Key, Textus.Crop>(countLimit: 5000)
        private static let groupAsync = DispatchGroup()
        private static let groupSync = DispatchGroup()
        private static let queue: OperationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.underlyingQueue = DispatchQueue(label: "rich text queue", qos: .background)
            return queue
        }()

        public let full: Bool
        public let lines: Int
        public let size: CGSize
        public let width: CGFloat

        private let original: Textus
        private let truncated: Textus

        public func hash(into hasher: inout Hasher) {
            hasher.combine(full)
            hasher.combine(lines)
            hasher.combine(size.height)
            hasher.combine(size.width)
        }

        public static func ==(lhs: Textus.Crop, rhs: Textus.Crop) -> Bool {
            guard lhs.full == rhs.full else {
                return false
            }
            guard lhs.lines == rhs.lines else {
                return false
            }
            guard lhs.size.height == rhs.size.height else {
                return false
            }
            guard lhs.size.width == rhs.size.width else {
                return false
            }
            return lhs.truncated == rhs.truncated
        }

        public static func async(height: CGFloat = Textus.Crop.height, lines: Int = Textus.Crop.lines, textus: Textus, width: CGFloat, _ completion: ((Textus.Crop) -> Void)? = nil) {
            Textus.Crop.queue.addOperation {
                Textus.Crop.groupAsync.wait()
                if let text = Textus.Crop(height: height, lines: lines, textus: textus, width: width) {
                    completion?(text)
                }
            }
        }

        @discardableResult
        public init?(height: CGFloat = Textus.Crop.height, lines: Int = Textus.Crop.lines, textus: Textus, width: CGFloat) {
            Textus.Crop.groupAsync.enter()
            Textus.Crop.groupSync.wait()
            Textus.Crop.groupSync.enter()
            defer {
                Textus.Crop.groupSync.leave()
                Textus.Crop.groupAsync.leave()
            }
            let maker: () -> Textus.Crop? = {
                return {
                    guard width > 0 else {
                        return nil
                    }
                    let limit = Limit(height: height, lines: lines)
                    let key = Key(limit: limit, textus: textus, width: width)
                    if let text = Textus.Crop.cache[key] {
                        return text
                    } else {
                        let engine = Engine(textus: textus, width: width)
                        guard let (ranges, size) = engine.value(limit: limit) else {
                            return nil
                        }
                        guard let range = ranges.last else {
                            return nil
                        }
                        let full = engine.manager.isValidGlyphIndex(range.next) == false
                        let lines = ranges.count
                        let original = textus
                        let truncated: Textus = {
                            let length = engine.manager.characterIndexForGlyph(at: range.last) + 1
                            return textus.prefix(length)
                        }()
                        let text = Textus.Crop(
                           full: full,
                           lines: lines,
                           original: original,
                           size: size,
                           truncated: truncated,
                           width: width
                        )
                        Textus.Crop.cache[key] = text
                        return text
                    }
                }
            }()
            guard let text = maker() else {
                return nil
            }
            self = text
        }

        private init(full: Bool, lines: Int, original: Textus, size: CGSize, truncated: Textus, width: CGFloat) {
            self.full = full
            self.lines = lines
            self.original = original
            self.size = size
            self.truncated = truncated
            self.width = width
        }
    }
}

extension Textus.Crop: TextusRepresentable {

    public var alignment: Textus.Alignment {
        return truncated.alignment
    }

    public var parts: [Textus.Part] {
        return truncated.parts
    }

    public var lineHeight: CGFloat {
        return truncated.lineHeight
    }

    public var truncating: Textus.Truncating {
        return truncated.truncating
    }

    public var wrapping: Textus.Wrapping {
        return truncated.wrapping
    }
}
