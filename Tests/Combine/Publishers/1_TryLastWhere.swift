import DependenciesTest
/*
 Если upstream успешно завершился, то в момент завершения публикуется последнее
 значение из upstream, которое подошло под условие.
 */
final class TryLastWhere: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .success(at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryLastWhere(upstream: upstream, predicate: { $0 == "c" })
      let completion = publisher.success(at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["c"])
      XCTAssertEqual(results.times, [4])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .failure(.default, at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryLastWhere(upstream: upstream, predicate: { $0 == "c" })
      let completion = publisher.failure(.default, at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }

   func test_throwing_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .success(at: 4)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryLastWhere(upstream: upstream, predicate: { _ in throw TestError.thrown })
      let completion = publisher.failure(.thrown, at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
