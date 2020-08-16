import UIKit

extension Textus {

   open class View: UIView {

      private static let queue: OperationQueue = {
         let queue = OperationQueue()
         queue.maxConcurrentOperationCount = 1
         queue.underlyingQueue = DispatchQueue(label: "rich view queue", qos: .background)
         return queue
      }()

      open override var backgroundColor: UIColor? {
         get {
            return super.backgroundColor
         }
         set {
            viewText.backgroundColor = newValue
            super.backgroundColor = newValue
         }
      }

      public var action: ((Textus.Part) -> Void)?
      private var group: DispatchGroup?
      private var links: [Textus.View.Link] = []
      private var operation: Operation?
      private var size = CGSize.zero
      public var textus: TextusRepresentable? {
         didSet(previous) {
            self.update(previous)
         }
      }
      private lazy var viewText = self.makeViewText()

      public init() {
         super.init(frame: .zero)
         let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
         self.addGestureRecognizer(recognizer)
         self.addSubview(viewText)
         NSLayoutConstraint.activate([
            viewText.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            viewText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            viewText.topAnchor.constraint(equalTo: self.topAnchor),
            viewText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
         ])
         self.viewText.textContainerInset = .zero
      }

      public required init?(coder: NSCoder) {
         super.init(coder: coder)
         let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
         self.addGestureRecognizer(recognizer)
         self.addSubview(viewText)
         NSLayoutConstraint.activate([
            viewText.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            viewText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            viewText.topAnchor.constraint(equalTo: self.topAnchor),
            viewText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
         ])
         self.viewText.textContainerInset = .zero
      }

      @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
         let point = recognizer.location(in: self)
         guard let link = self.link(point) else {
            return
         }
         self.action?(link.part)
      }

      public override func layoutSubviews() {
         super.layoutSubviews()
         let current = bounds.size
         self.update(current)
      }

      func update() {
         self.operation?.cancel()
         self.operation = nil
         self.links = []
         self.group = nil
         self.viewText.attributedText = NSAttributedString()
         guard let textus = self.textus, self.size.height > 0, self.size.width > 0 else {
            return
         }
         let group = DispatchGroup()
         group.enter()
         self.group = group
         let lineHeight = textus.lineHeight
         let paragraphStyle: NSParagraphStyle = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textus.alignment
            paragraphStyle.lineBreakMode = textus.wrapping.lineBreakMode
            paragraphStyle.lineSpacing = 0
            paragraphStyle.maximumLineHeight = lineHeight
            paragraphStyle.minimumLineHeight = lineHeight
            return paragraphStyle
         }()
         let minimumCapacity = textus.parts.reduce(0, { $1.load == nil ? $0 : $0 + 1 })
         var parts = [NSRange: Textus.Part](minimumCapacity: minimumCapacity)
         var location = 0
         let attributedText = NSMutableAttributedString()
         for part in textus.parts {
            let substring = part.attributedString(
               lineHeight: lineHeight,
               paragraphStyle: paragraphStyle
            )
            let length = substring.length
            if part.load != nil {
               let range = NSRange(location: location, length: length)
               parts[range] = part
            }
            location += length
            attributedText.append(substring)
         }
         self.viewText.attributedText = attributedText
         let operation = self.makeOperation(parts: parts, group: group, textus: textus)
         Textus.View.queue.addOperation(operation)
      }

      func update(_ current: CGSize) {
         guard current != self.size else {
            return
         }
         self.size = current
         self.update()
      }

      func update(_ previous: TextusRepresentable?) {
         if let textus = self.textus as? Textus, let previous = previous as? Textus, textus == previous {
            return
         }
         if let textus = self.textus as? Textus.Crop, let previous = previous as? Textus.Crop, textus == previous {
            return
         }
         self.update()
      }

      private func makeOperation(parts: [NSRange: Textus.Part], group: DispatchGroup, textus: TextusRepresentable) -> Operation {
         return BlockOperation { [height = size.height, weak view = self, width = size.width] in
            defer {
               group.leave()
            }
            let engine = Textus.Engine(textus: textus, width: width)
            let limit = Textus.Limit(height: height)
            guard let (glyphRanges, _) = engine.value(limit: limit) else {
               return
            }
            view?.links = parts
               .reduce(into: [Textus.View.Link](), { (result, object) in
                  let ranges: [NSRange] = {
                     let range = engine.manager.glyphRange(forCharacterRange: object.key, actualCharacterRange: nil)
                     guard let index = glyphRanges.firstIndex(where: { NSIntersectionRange($0, range).length > 0 }) else {
                        return []
                     }
                     return glyphRanges
                        .suffix(from: index)
                        .prefix(while: { NSIntersectionRange($0, range).length > 0 })
                        .map({ NSIntersectionRange($0, range) })
                  }()
                  let frames = ranges
                     .map({ engine.manager.boundingRect(forGlyphRange: $0, in: engine.container) })
                  let link = Textus.View.Link(part: object.value, frames: frames)
                  result.append(link)
               })
         }
      }

      private func makeViewText() -> UITextView {
         let view = UITextView(frame: .zero)
         #if os(iOS)
         view.isEditable = false
         #endif
         view.isOpaque = true
         view.isUserInteractionEnabled = false
         view.layer.zPosition = 1
         view.layoutManager.usesFontLeading = false
         view.textContainer.lineFragmentPadding = 0
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
      }

      public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
         self.group?.wait()
         return self.action != nil && self.link(point) != nil
      }

      private func link(_ point: CGPoint) -> Textus.View.Link? {
         if let link = links.first(where: { $0.frames.contains(where: { $0.contains(point) }) }) {
            return link
         }
         guard let link = links.sorted(by: { $0.frames.distance(point) < $1.frames.distance(point) }).first else {
            return nil
         }
         return link.frames.distance(point) < 10 ? link : nil
      }
   }
}

extension Array where Element == CGRect {

   func distance(_ point: CGPoint) -> CGFloat {
      return map({ $0.distance(point) }).min() ?? CGFloat.greatestFiniteMagnitude
   }
}

extension Textus.View {

   struct Link: Hashable {

      let part: Textus.Part
      let frames: [CGRect]

      func hash(into hasher: inout Hasher) {
         hasher.combine(frames.first?.origin.x)
         hasher.combine(frames.first?.origin.y)
         hasher.combine(frames.first?.size.height)
         hasher.combine(frames.first?.size.width)
      }
   }
}

extension CGPoint {

   func distance(_ point: CGPoint) -> CGFloat {
      return hypot(point.x.distance(to: x), point.y.distance(to: y))
   }

   func distance(_ rect: CGRect) -> CGFloat {
      return rect.distance(self)
   }

   func middle(_ point: CGPoint) -> CGPoint {
      return CGPoint(
         x: (self.x + point.x) / 2,
         y: (self.y + point.y) / 2
      )
   }
}

extension CGRect {

   func distance(_ point: CGPoint) -> CGFloat {
      let dx = Swift.max(self.minX - point.x, point.x - self.maxX, 0)
      let dy = Swift.max(self.minY - point.y, point.y - self.maxY, 0)
      switch (dx, dy) {
      case (0, 0):
         return 0
      case (0, _):
         return dy
      case (_, 0):
         return dx
      default:
         return hypot(dx, dy)
      }
   }
}

