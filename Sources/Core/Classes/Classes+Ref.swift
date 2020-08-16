import Foundation

@propertyWrapper
public struct Ref<V> {

   public let read: () -> V
   public let write: (V) -> Void

   public init(read: @escaping () -> V, write: @escaping (V) -> Void) {
      self.read = read
      self.write = write
   }

   public var wrappedValue: V {
      get {
         return read()
      }
      nonmutating set {
         write(newValue)
      }
   }

   public subscript<U>(keyPath: WritableKeyPath<V, U>) -> Ref<U> {
      let read: () -> U = {
         return self.wrappedValue[keyPath: keyPath]
      }
      let write: (U) -> Void = { (value: U) -> Void in
         self.wrappedValue[keyPath: keyPath] = value
      }
      return Ref<U>(read: read, write: write)
   }
}
