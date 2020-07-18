import DependenciesTest
/*
 Из upstream публикуются значения, номера которых соответсвуют range. После
 публикации последнего значения с номером из range происходит успешное
 завершение.
 */
final class Output: XCTestCase {

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
      let publisher = Publishers.Output(upstream: upstream, range: 1 ..< 3)
      let completion = publisher.success(at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [1, 2])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Output(upstream: upstream, range: 1 ..< 3)
      let completion = publisher.failure(.default, at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b"])
      XCTAssertEqual(results.times, [1])
   }
}
