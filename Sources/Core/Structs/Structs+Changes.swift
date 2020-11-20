import Foundation

@dynamicMemberLookup
public struct Changes<V> where V: Changeable {

   private var keyPaths = [PartialKeyPath<V>: Bool]()

   private init(type: V.Type) {
      keyPaths.reserveCapacity(10)
   }

   public static var `default`: Changes<V> {
      return Changes(type: V.self)
   }

   var isChanged: Bool {
      return keyPaths.contains(where: { $0.value }) == true
   }

   public subscript<T>(dynamicMember keyPath: KeyPath<V, T>) -> Bool {
      get {
         return keyPaths[keyPath] ?? false
      }
      set {
         keyPaths[keyPath] = newValue
      }
   }
}
