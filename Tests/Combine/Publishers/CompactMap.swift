import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream. Каждое
 значение трансформации публикуется если оно не nil.
 */
final class CompactMap: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.CompactMap(upstream: upstream) { string -> String? in
         return string == "b" ? nil : string
      }
      let completion = publisher.success(at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "c"])
      XCTAssertEqual(results.times, [0, 2])
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
      let publisher = Publishers.CompactMap(upstream: upstream) { string -> String? in
         return string == "b" ? nil : string
      }
      let completion = publisher.failure(.default, at: 3)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "c"])
      XCTAssertEqual(results.times, [0, 2])
   }
}
