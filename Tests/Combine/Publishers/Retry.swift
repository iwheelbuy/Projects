import DependenciesTest
/*
 Пытаемся переподписаться на upstream при ошибке. nil или отрицательно значение
 retries приводит к бесконечным попыткам.
 */
final class Retry: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let upstream = handler.publisher(absolute: false, events: events)
      let publisher = Publishers.Retry(upstream: upstream, retries: 2)
      let completion = publisher.failure(.default, at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "a", "a"])
      XCTAssertEqual(results.times, [0, 1, 2])
   }
}
