import DependenciesTest
/*
 Игнорирует все значения из upstream.
 */
final class IgnoreOutput: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .success(at: 1)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let completion = publisher.success(at: 1)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let completion = publisher.failure(.default, at: 1)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
