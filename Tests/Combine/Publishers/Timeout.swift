import DependenciesTest
/*
 Заканчивается ошибкой если за время равное таймауту с подписки не пришло ни
 значение ни завершение upstream.
 */
final class Timeout: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 3),
         .success(at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let interval = 3
      let publisher = Publishers.Timeout(
         upstream: upstream,
         interval: VirtualTimeInterval(interval),
         scheduler: handler.scheduler,
         options: nil,
         customError: { () -> Publishers.Timeout<AnyPublisher<String, TestError>, TestScheduler>.Failure in
            return TestError.custom("timeout")
         }
      )
      let completion = publisher.success(at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a"])
      XCTAssertEqual(results.times, [3])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 3),
         .success(at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let interval = 2
      let publisher = Publishers.Timeout(
         upstream: upstream,
         interval: VirtualTimeInterval(interval),
         scheduler: handler.scheduler,
         options: nil,
         customError: { () -> Publishers.Timeout<AnyPublisher<String, TestError>, TestScheduler>.Failure in
            return TestError.custom("timeout")
         }
      )
      let completion = publisher.failure(.custom("timeout"), at: interval)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
