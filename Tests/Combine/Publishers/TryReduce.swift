import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream и предыдущему
 результату трансформации. Финальное значение трансформации публикуется
 непосредственно перед успешным завершением upstream. В случае завершения с
 ошибкой - значение не будет опубликовано. Если во время трансформации
 произошла ошибка, то паблишер завершится ошибкой и не опубликует значений.
 */
final class TryReduce: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryReduce(
         upstream: upstream,
         initial: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.success(at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["ab"])
      XCTAssertEqual(results.times, [2])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryReduce(
         upstream: upstream,
         initial: "",
         nextPartialResult: { previous, current -> String in
            return previous + current
         }
      )
      let completion = publisher.failure(.default, at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }

   func test_throwing_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .success(at: 2)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.TryReduce(
         upstream: upstream,
         initial: "",
         nextPartialResult: { previous, current -> String in
            throw TestError.thrown
         }
      )
      let completion = publisher.failure(.thrown, at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
