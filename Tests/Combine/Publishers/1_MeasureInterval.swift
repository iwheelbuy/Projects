import DependenciesTest
/*
 Вместо публикации значения из upstream публикуют временной промежуток, который
 прошел с момент публикции предыдущего значения или подписки.
 */
final class MeasureInterval: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.MeasureInterval(upstream: upstream, scheduler: storage.scheduler)
      let completion = publisher.success(at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [0, 1, 1].map({ VirtualTimeInterval($0) }))
         XCTAssertEqual(results.times, [0, 1, 2])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.MeasureInterval(upstream: upstream, scheduler: storage.scheduler)
      let completion = publisher.failure(.default, at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [0, 1, 1].map({ VirtualTimeInterval($0) }))
         XCTAssertEqual(results.times, [0, 1, 2])
      }
   }
}
