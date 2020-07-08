import DependenciesTest
/*
 
 */
final class CollectByTime: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<Int, TestError> = scheduler.createRelativeTestablePublisher([
         (25, .input(1)),
         (26, .input(2)),
         (27, .input(3)),
         (28, .input(4)),
         (28, .input(5)),
         (29, .input(6)),
         (30, .input(7)),
         (99, .input(8)),
         (99, .completion(.finished))
      ])
      let count: Int = 5
      let interval: VirtualTimeInterval = 10
      let strategy = Publishers.TimeGroupingStrategy<TestScheduler>
         .byTimeOrCount(scheduler, interval, count)
      let publisher = Publishers.CollectByTime(
         upstream: upstream,
         strategy: strategy,
         options: nil
      )
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs, [[1, 2, 3, 4, 5], [6, 7], [8]])
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 99))
   }
}
