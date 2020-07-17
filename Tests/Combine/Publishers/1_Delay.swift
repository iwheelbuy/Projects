import DependenciesTest
/*
 Задерживает публикацию и завершение из upstream на указанное время.
 */
final class Delay: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 1),
         .value("b", at: 2),
         .value("c", at: 4),
         .success(at: 5)
      ]
      let upstream = storage.publisher(events: events)
      let interval = 2
      let publisher = Publishers.Delay(
         upstream: upstream,
         interval: VirtualTimeInterval(interval),
         tolerance: storage.scheduler.minimumTolerance,
         scheduler: storage.scheduler,
         options: nil
      )
      let completion = publisher.success(at: 5 + interval)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b", "c"])
         XCTAssertEqual(results.times, [1, 2, 4].map({ $0 + interval }))
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 1),
         .value("b", at: 2),
         .value("c", at: 4),
         .failure(.default, at: 5)
      ]
      let upstream = storage.publisher(events: events)
      let interval = 2
      let publisher = Publishers.Delay(
         upstream: upstream,
         interval: VirtualTimeInterval(interval),
         tolerance: storage.scheduler.minimumTolerance,
         scheduler: storage.scheduler,
         options: nil
      )
      let completion = publisher.failure(.default, at: 5 + interval)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b", "c"])
         XCTAssertEqual(results.times, [1, 2, 4].map({ $0 + interval }))
      }
   }
}
