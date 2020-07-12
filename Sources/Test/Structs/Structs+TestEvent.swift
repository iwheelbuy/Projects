import EntwineTest

public struct TestEvent<V>: Equatable where V: Equatable {

   public let `case`: TestCase<V>
   public let time: Int

   public init(case: TestCase<V>, time: Int) {
      self.case = `case`
      self.time = time
   }

   public init(case: TestCase<V>, time: VirtualTime) {
      precondition(time <= 1000, "Время должно быть в промежутке [0 ... 999]")
      self.case = `case`
      self.time = Int(time.debugDescription)!
   }

   public static func failure(_ failure: TestError, at time: Int) -> TestEvent<V> {
      return TestEvent<V>(case: .failure(failure), time: time)
   }

   public static func subscription(at time: Int) -> TestEvent<V> {
      return TestEvent<V>(case: .subscription, time: time)
   }

   public static func success(at time: Int) -> TestEvent<V> {
      return TestEvent<V>(case: .success, time: time)
   }

   public static func value(_ value: V, at time: Int) -> TestEvent<V> {
      return TestEvent<V>(case: .value(value), time: time)
   }
}
