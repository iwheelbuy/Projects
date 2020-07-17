import DependenciesTest
/*
 Из upstream публикуются значения, номера которых соответсвуют range. После
 публикации последнего значения с номером из range происходит успешное
 завершение.
 */
final class Output: XCTestCase {

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
      let publisher = Publishers.Output(upstream: upstream, range: 1 ..< 3)
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["b", "c"])
         XCTAssertEqual(results.times, [1, 2])
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
      let publisher = Publishers.Output(upstream: upstream, range: 1 ..< 3)
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["b"])
         XCTAssertEqual(results.times, [1])
      }
   }
}
