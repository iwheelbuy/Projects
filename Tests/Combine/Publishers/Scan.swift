import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream и предыдущему
 результату трансформации. Каждое значение трансформации публикуется.
 */
final class Scan: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Scan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.success(at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "ab"])
      XCTAssertEqual(results.times, [0, 1])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Scan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.failure(.default, at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "ab"])
      XCTAssertEqual(results.times, [0, 1])
   }
}
