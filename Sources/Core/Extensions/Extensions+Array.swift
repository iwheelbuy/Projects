import Foundation

public extension Array {
   ///
   var isNotEmpty: Bool {
      return isEmpty == false
   }
   /// Разделить массив на подмассивы определенного размера [1, 2, 3] = [[1, 2], [3]]
   func slices(size: Int) -> [ArraySlice<Element>] {
      guard size > 0, size < count else {
         return [ArraySlice<Element>(self)]
      }
      var drop = 0
      var slices = [ArraySlice<Element>]()
      slices.reserveCapacity(1 + count / size)
      while true {
         let slice: ArraySlice<Element> = self.dropFirst(drop).prefix(size)
         if slice.isNotEmpty {
            slices.append(slice)
            drop += size
         } else {
            break
         }
      }
      return slices
   }
}
