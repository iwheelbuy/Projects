import Foundation

public struct TestResult<V>: Equatable, TestResultRepresentable where V: Equatable {

   public let time: Int
   public let value: V

   public init(time: Int, value: V) {
      precondition(time <= 1000, "Время должно быть в промежутке [0 ... 999]")
      self.time = time
      self.value = value
   }
}
