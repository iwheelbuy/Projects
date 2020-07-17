import DependenciesTest
/*
 Значения из upstream публикуются пока other не опубликует первое значение.
 */
final class TryPrefixWhile: XCTestCase {

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
      let publisher = Publishers.TryPrefixWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b"])
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
      let publisher = Publishers.TryPrefixWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b"])
         XCTAssertEqual(results.times, [0, 1])
      }
   }

   func test_throwing_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .success(at: 4)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.TryPrefixWhile(upstream: upstream) { _ in throw TestError.thrown }
      let completion = publisher.failure(.thrown, at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
