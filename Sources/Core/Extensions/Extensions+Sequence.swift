import Foundation

public extension Sequence where Element: Hashable {

   var set: Set<Element> {
      return Set(self)
   }
}
