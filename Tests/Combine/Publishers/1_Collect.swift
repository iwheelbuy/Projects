import DependenciesTest
/*
 Публикует весь массив собранных данных в момент завершения upstream. Если
 upstream завершится ошибкой, то ничего опубликовано не будет.
 */
final class Collect: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .success(at: timer[2])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Collect(upstream: upstream)
      let completion = publisher.success(at: timer[2])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [["a", "b"]])
         XCTAssertEqual(results.times, [timer[2]])
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
      let publisher = Publishers.Collect(upstream: upstream)
      let completion = publisher.failure(.default, at: timer[2])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
