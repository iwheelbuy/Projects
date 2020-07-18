import DependenciesTest
/*
 Публикуются все значения из upstream. Если upstream заканчивается ошибкой, то
 публикуется указанное значение и успешо завершается.
 */
final class ReplaceError: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.ReplaceError(upstream: upstream, output: "b")
      let completion = publisher.success(at: 1)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "b"])
      XCTAssertEqual(results.times, [0, 1])
   }
}
