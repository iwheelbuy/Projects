import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream. Каждое
 значение трансформации публикуется если оно не nil.
 */
final class CompactMap: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .value("c", at: timer[2]),
         .success(at: timer[3])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.CompactMap(upstream: upstream) { string -> String? in
         return string == "a" ? nil : string
      }
      let completion = publisher.success(at: timer[3])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["b", "c"])
         XCTAssertEqual(results.times, [timer[1], timer[2]])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .value("c", at: timer[2]),
         .failure(.default, at: timer[3])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.CompactMap(upstream: upstream) { string -> String? in
         return string == "a" ? nil : string
      }
      let completion = publisher.failure(.default, at: timer[3])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["b", "c"])
         XCTAssertEqual(results.times, [timer[1], timer[2]])
      }
   }
}
