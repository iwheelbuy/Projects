import Foundation

@propertyWrapper
public struct Hashablified<T>: Hashable {

   public var wrappedValue: T

   public init(wrappedValue: T) {
      self.wrappedValue = wrappedValue
   }

   public func hash(into hasher: inout Hasher) {

   }

   public static func ==(lhs: Self, rhs: Self) -> Bool {
      return true
   }
}
