import DependenciesTest
/*
 Из upstream публикуется лишь первое значение подошедшее под услови и сразу
 успешно завершается.
 */
final class FirstWhere: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .success(at: 4)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.FirstWhere(upstream: upstream, predicate: { $0 == "c" })
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["c"])
         XCTAssertEqual(results.times, [2])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.FirstWhere(upstream: upstream, predicate: { $0 == "c" })
      let completion = publisher.failure(.default, at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
