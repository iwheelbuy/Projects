import Foundation

public struct TestResult<V>: Equatable, TestResultRepresentable where V: Equatable {

   public let time: Int
   public let value: V

   public init(time: Int, value: V) {
      self.time = time
      self.value = value
   }
}
