import DependenciesTest
/*
 Из upstream публикуется лишь первое значение и сразу успешно завершается.
 */
final class First: XCTestCase {

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
      let publisher = Publishers.First(upstream: upstream)
      let completion = publisher.success(at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a"])
      XCTAssertEqual(results.times, [0])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.First(upstream: upstream)
      let completion = publisher.failure(.default, at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
