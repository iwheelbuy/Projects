import Core
import UIKit

extension Textus {

   struct Engine {

      private struct Key: Hashable {

         let textus: TextusRepresentable
         let width: CGFloat

         func hash(into hasher: inout Hasher) {
            hasher.combine(textus.parts.count)
            hasher.combine(textus.parts.first?.string.count)
            hasher.combine(width)
         }

         static func ==(lhs: Key, rhs: Key) -> Bool {
            guard lhs.width == rhs.width else {
               return false
            }
            guard lhs.textus.alignment == rhs.textus.alignment else {
               return false
            }
            guard lhs.textus.lineHeight == rhs.textus.lineHeight else {
               return false
            }
            guard lhs.textus.truncating == rhs.textus.truncating else {
               return false
            }
            guard lhs.textus.wrapping == rhs.textus.wrapping else {
               return false
            }
            guard lhs.textus.parts == rhs.textus.parts else {
               return false
            }
            return true
         }
      }

      private static let cache = Cache<Textus.Engine.Key, Textus.Engine>(countLimit: 5000)

      let container: NSTextContainer
      let manager: NSLayoutManager
      let storage: NSTextStorage

      private var values = [Textus.Limit: (ranges: [NSRange], size: CGSize)]()

      init(textus: TextusRepresentable, width: CGFloat) {
         let key = Textus.Engine.Key(textus: textus, width: width)
         if let engine = Textus.Engine.cache[key] {
            self = engine
         } else {
            let container = NSTextContainer()
            container.lineFragmentPadding = 0
            container.maximumNumberOfLines = 0
            container.size = CGSize(width: width, height: Textus.Crop.height)
            let manager = NSLayoutManager()
            manager.usesFontLeading = false
            let storage = NSTextStorage(attributedString: textus.attributedString)
            manager.addTextContainer(container)
            storage.addLayoutManager(manager)
            self.container = container
            self.manager = manager
            self.storage = storage
            Textus.Engine.cache[key] = self
         }
      }

      func value(limit: Textus.Limit) -> (ranges: [NSRange], size: CGSize)? {
         if let value = values[limit] {
            return value
         }
         let value = makeValue(limit: limit)
         values[limit] = value
         return value
      }

      private func makeValue(limit: Textus.Limit) -> (ranges: [NSRange], size: CGSize)? {
         var height: CGFloat = 0
         var maxX: CGFloat = 0
         var minX: CGFloat = .greatestFiniteMagnitude
         let ranges: [NSRange] = {
            var index = 0
            var ranges = [NSRange]()
            for _ in 0 ..< limit.lines {
               guard manager.isValidGlyphIndex(index), ranges.count < limit.lines else {
                  break
               }
               var range = NSRange()
               manager.lineFragmentRect(forGlyphAt: index, effectiveRange: &range)
               let rect = manager.boundingRect(forGlyphRange: range, in: container)
               if limit.height < rect.maxY {
                  break
               }
               height = Swift.max(height, rect.maxY)
               maxX = Swift.max(maxX, rect.maxX)
               minX = Swift.min(minX, rect.minX)
               ranges.append(range)
               index = range.next
            }
            return ranges
         }()
         let width = maxX - minX
         guard height > 0, width > 0, ranges.isNotEmpty else {
            return nil
         }
         let size = CGSize(width: width, height: height)
         return (ranges, size)
      }
   }
}



