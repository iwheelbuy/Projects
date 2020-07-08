import DependenciesTest
/*
 
 */
final class CollectByTime: TestCase {

   func test_common_behavior() {
      let configuration = TestScheduler.Configuration.default
      let scheduler = TestScheduler()
      let upstream: TestablePublisher<String, Never> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .input("d")),
         (5, .input("e")),
         (6, .input("f")),
         (7, .input("g")),
         (8, .input("h")),
         (9, .input("i")),
         (10, .completion(.finished))
      ])
      let window: VirtualTimeInterval = 3
      let strategy = Publishers.TimeGroupingStrategy<TestScheduler>
         .byTime(scheduler, window)
      let publisher = Publishers.CollectByTime(
         upstream: upstream,
         strategy: strategy,
         options: nil
      )
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
   }
}
