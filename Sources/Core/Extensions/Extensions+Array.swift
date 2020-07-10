import Foundation

public extension Array {
   /// Разделить массив на подмассивы определенного размера [1, 2, 3] = [[1, 2], [3]]
   func split(count: Int) -> [Self] {
      guard count > 0 || count >= self.count  else {
         return [self]
      }
      var arrays = [Self]()
      arrays.reserveCapacity(1 + self.count / count)
      var array: Self = []
      for value in self {
         array.append(value)
         if array.count == count {
            arrays.append(array)
            array = []
         }
      }
      if array.isEmpty == false {
         arrays.append(array)
      }
      return arrays
   }
}
