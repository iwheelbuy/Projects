import Foundation

public extension Array where Element: TestResultRepresentable {

   var times: [Int] {
      return self.map({ $0.time })
   }

   var values: [Element.V] {
      return self.map({ $0.value })
   }
}
