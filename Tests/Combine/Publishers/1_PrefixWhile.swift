import DependenciesTest
/*
 Значения из upstream публикуются пока other не опубликует первое значение.
 */
final class PrefixWhile: XCTestCase {

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
      let publisher = Publishers.PrefixWhile(upstream: upstream) { $0 != "c" }
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
      let publisher = Publishers.PrefixWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b"])
         XCTAssertEqual(results.times, [0, 1])
      }
   }
}
