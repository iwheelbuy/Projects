import DependenciesTest
/*
 Публикуются только те значения из upstream, которые не равны предыдущим.
 */
final class TryRemoveDuplicates: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("a", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryRemoveDuplicates(upstream: upstream, predicate: { $0 == $1 })
      let completion = publisher.success(at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "c"])
      XCTAssertEqual(results.times, [0, 2])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("a", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryRemoveDuplicates(upstream: upstream, predicate: { $0 == $1 })
      let completion = publisher.failure(.default, at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "c"])
      XCTAssertEqual(results.times, [0, 2])
   }

   func test_throwing_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("a", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryRemoveDuplicates(upstream: upstream, predicate: { _, _ in throw TestError.thrown })
      let completion = publisher.failure(.thrown, at: 1)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a"])
      XCTAssertEqual(results.times, [0])
   }
}
