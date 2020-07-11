import Foundation

public extension Array {
   /// Добавить элемент в конец
   func appending(_ element: Element?) -> Array {
      guard let element = element else {
         return self
      }
      return self + [element]
   }
   /// Добавить элемент в конец
   func appending(_ block: (Array) -> Element?) -> Array {
      return self + [block(self)].compactMap({ $0 })
   }
   /// Добавить массив в конец
   func appending(_ block: (Array) -> Array?) -> Array {
      guard let array = block(self) else {
         return self
      }
      return self + array
   }
   /// Добавить массив в конец
   func appending(_ elements: [Element]) -> Array {
      return self + elements
   }
   /// Вставить по индексу
   func inserting(_ block: (Array) -> (Int, Element)?) -> Array {
      guard let (index, element) = block(self) else {
         return self
      }
      var array = self
      array.insert(element, at: index)
      return array
   }
   /// Массив не пустой
   var isNotEmpty: Bool {
      return isEmpty == false
   }
   /// Добавить элемент в начало
   func prepending(_ block: (Array) -> Element?) -> Array {
      return [block(self)].compactMap({ $0 }) + self
   }
   /// Добавить элемент в начало
   func prepending(_ element: Element?) -> Array {
      guard let element = element else {
         return self
      }
      return [element] + self
   }
   /// Добавить массив в начало
   func prepending(_ block: (Array) -> Array) -> Array {
      return block(self) + self
   }
   /// Добавить массив в начало
   func prepending(_ elements: [Element]) -> Array {
      return elements + self
   }
   /// Удалить по индексу
   func removing(at index: Int) -> Array {
      var array = self
      array.remove(at: index)
      return array
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
