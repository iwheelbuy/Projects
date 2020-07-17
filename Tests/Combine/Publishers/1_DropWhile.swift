import DependenciesTest
/*
 Значения из upstream не публикуются пока other не опубликует первое значение.
 Даже если other закончится ошибкой после публикации первого занчения, upstream
 продолжит публиковать значения
 */
final class DropWhile: XCTestCase {

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
      let publisher = Publishers.DropWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.success(at: 4)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["c", "d"])
         XCTAssertEqual(results.times, [2, 3])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .value("c", at: 2),
         .value("d", at: 3),
         .failure(.default, at: 4)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.DropWhile(upstream: upstream) { $0 != "c" }
      let completion = publisher.failure(.default, at: 4)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["c", "d"])
         XCTAssertEqual(results.times, [2, 3])
      }
   }
}
