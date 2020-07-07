import DependenciesTest

final class Sequence: TestCase {

   func test_default_behavior() {
      let sequence = Array(0 ... 1 + arc4random() % 10).map({ _ in arc4random() })
      let publisher = Publishers.Sequence<[UInt32], Never>(sequence: sequence)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssert(subscriber.inputs == sequence)
      subscriber.values.forEach({ value in
         XCTAssert(value.time == configuration.subscribed)
      })
      XCTAssert(subscriber.isSubscribed)
      XCTAssert(subscriber.isCompleted)
   }
}
