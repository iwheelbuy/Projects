import DependenciesTest
/*
 Из upstream НЕ публикуются первые count значений. Все остальыне публикуются.
 */
final class Drop: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Drop(upstream: upstream, count: 1)
      let completion = publisher.success(at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [1, 2])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Drop(upstream: upstream, count: 1)
      let completion = publisher.failure(.default, at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [1, 2])
   }
}
