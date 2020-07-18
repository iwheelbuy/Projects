import DependenciesTest
/*
 Применяется трансформация к ошибке.
 */
final class MapError: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.MapError(upstream: upstream, { _ in TestError.custom("a") })
      let completion = publisher.failure(.custom("a"), at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
