import Foundation

@propertyWrapper
public final class Box<V> {

   public var wrappedValue: V

   public init(wrappedValue: V) {
      self.wrappedValue = wrappedValue
   }

   public var projectedValue: Ref<V> {
      get {
         let read: () -> V = {
            return self.wrappedValue
         }
         let write: (V) -> Void = { (wrappedValue: V) -> Void in
            self.wrappedValue = wrappedValue
         }
         return Ref<V>(read: read, write: write)
      }
   }
}
