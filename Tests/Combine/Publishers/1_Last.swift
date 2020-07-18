import DependenciesTest
/*
 Если upstream успешно завершился, то в момент завершения публикуется последнее
 значение из upstream.
 */
final class Last: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .success(at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Last(upstream: upstream)
      let completion = publisher.success(at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["d"])
      XCTAssertEqual(results.times, [4])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .failure(.default, at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Last(upstream: upstream)
      let completion = publisher.failure(.default, at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
