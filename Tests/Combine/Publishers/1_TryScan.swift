import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream и предыдущему
 результату трансформации. Каждое значение трансформации публикуется.
 */
final class TryScan: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "ab"])
         XCTAssertEqual(results.times, [0, 1])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "ab"])
         XCTAssertEqual(results.times, [0, 1])
      }
   }

   func test_throwing_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, current -> String in
            throw TestError.thrown
         }
      )
      let completion = publisher.failure(.thrown, at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
