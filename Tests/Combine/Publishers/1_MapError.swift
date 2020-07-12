import DependenciesTest
/*
 Применяется трансформация к ошибке.
 */
final class MapError: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.MapError(upstream: upstream, { _ in TestError.custom("a") })
      let completion = publisher.failure(.custom("a"), at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
