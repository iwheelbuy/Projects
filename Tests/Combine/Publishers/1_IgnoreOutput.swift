import DependenciesTest
/*
 Игнорирует все значения из upstream.
 */
final class IgnoreOutput: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .success(at: 1)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let completion = publisher.success(at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let completion = publisher.failure(.default, at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
