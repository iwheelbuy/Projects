import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream и предыдущему
 результату трансформации. Финальное значение трансформации публикуется
 непосредственно перед успешным завершением upstream. В случае завершения с
 ошибкой - значение не будет опубликовано.
 */
final class Reduce: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Reduce(
         upstream: upstream,
         initial: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["ab"])
         XCTAssertEqual(results.times, [2])
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
      let publisher = Publishers.Reduce(
         upstream: upstream,
         initial: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
