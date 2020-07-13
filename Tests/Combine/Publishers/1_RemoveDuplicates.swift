import DependenciesTest
/*
 Публикуются только те значения из upstream, которые не равны предыдущим.
 */
final class RemoveDuplicates: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("a", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.RemoveDuplicates(upstream: upstream, predicate: { $0 == $1 })
      let completion = publisher.success(at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "c"])
         XCTAssertEqual(results.times, [0, 2])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("a", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.RemoveDuplicates(upstream: upstream, predicate: { $0 == $1 })
      let completion = publisher.failure(.default, at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "c"])
         XCTAssertEqual(results.times, [0, 2])
      }
   }
}
