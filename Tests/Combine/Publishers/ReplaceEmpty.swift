import DependenciesTest
/*
 Если к успешному завершению upstream не опубликовал ни одного значения, то
 перед успешные завершением будет опубликовано указанное значение.
 */
final class ReplaceEmpty: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .success(at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.ReplaceEmpty(upstream: upstream, output: "a")
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
      let publisher = Publishers.ReplaceEmpty(upstream: upstream, output: "a")
      let completion = publisher.failure(.default, at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
