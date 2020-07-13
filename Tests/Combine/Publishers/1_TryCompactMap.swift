import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream. Каждое
 значение трансформации публикуется если оно не nil.
 */
final class TryCompactMap: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryCompactMap(upstream: upstream) { string -> String? in
         return string == "b" ? nil : string
      }
      let completion = publisher.success(at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "c"])
         XCTAssertEqual(results.times, [0, 2])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryCompactMap(upstream: upstream) { string -> String? in
         return string == "b" ? nil : string
      }
      let completion = publisher.failure(.default, at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "c"])
         XCTAssertEqual(results.times, [0, 2])
      }
   }

   func test_throwing_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .success(at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryCompactMap(upstream: upstream) { string -> String? in
         if string == "b" {
            throw TestError.thrown
         }
         return string
      }
      let completion = publisher.failure(.thrown, at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a"])
         XCTAssertEqual(results.times, [0])
      }
   }
}
