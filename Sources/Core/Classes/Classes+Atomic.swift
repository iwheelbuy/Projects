import Foundation

@propertyWrapper
public final class Atomic<V> {

   private let lock = NSLock()
   private var value: V

   public init(wrappedValue value: V) {
      self.value = value
   }

   public var wrappedValue: V {
      get {
         lock.lock()
         defer {
            lock.unlock()
         }
         return value
      }
      set {
         lock.lock()
         defer {
            lock.unlock()
         }
         value = newValue
      }
   }
}
