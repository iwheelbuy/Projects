import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream. Каждое
 значение трансформации публикуется.
 */
final class TryMap: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .success(at: timer[2])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryMap(upstream: upstream, transform: { $0.uppercased() })
      let completion = publisher.success(at: timer[2])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["A", "B"])
         XCTAssertEqual(results.times, [timer[0], timer[1]])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .failure(.default, at: timer[2])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryMap(upstream: upstream, transform: { $0.uppercased() })
      let completion = publisher.failure(.default, at: timer[2])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["A", "B"])
         XCTAssertEqual(results.times, [timer[0], timer[1]])
      }
   }

   func test_throwing_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .success(at: timer[2])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryMap(upstream: upstream, transform: { _ -> String in throw TestError.thrown })
      let completion = publisher.failure(.thrown, at: timer[0])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
