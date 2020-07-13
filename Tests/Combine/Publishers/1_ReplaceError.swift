import DependenciesTest
/*
 Публикуются все значения из upstream. Если upstream заканчивается ошибкой, то
 публикуется указанное значение и успешо завершается.
 */
final class ReplaceError: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.ReplaceError(upstream: upstream, output: "b")
      let completion = publisher.success(at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b"])
         XCTAssertEqual(results.times, [0, 1])
      }
   }
}
