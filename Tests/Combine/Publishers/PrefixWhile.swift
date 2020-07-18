import DependenciesTest
/*
 Значения из upstream публикуются пока other не опубликует первое значение.
 */
final class PrefixWhile: XCTestCase {

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
      let publisher = Publishers.PrefixWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.success(at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "b"])
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
      let publisher = Publishers.PrefixWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.failure(.default, at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a", "b"])
      XCTAssertEqual(results.times, [0, 1])
   }
}
