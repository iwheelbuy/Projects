import DependenciesTest
/*
 Публикуется последнее полученное из upstream значение при условии, что с
 момента его публикации прошло время равное dueTime и новых значений
 опубликовано не было.
 */
final class Debounce: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 1),
         .value("b", at: 2),
         .value("c", at: 8),
         .success(at: 99)
      ]
      let upstream = handler.publisher(events: events)
      let dueTime = 5
      let publisher = Publishers.Debounce(
         upstream: upstream,
         dueTime: VirtualTimeInterval(dueTime),
         scheduler: handler.scheduler,
         options: nil
      )
      let completion = publisher.success(at: 99)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [2 + dueTime, 8 + dueTime])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<String>] = [
         .value("a", at: 1),
         .value("b", at: 2),
         .value("c", at: 8),
         .failure(.default, at: 9)
      ]
      let upstream = handler.publisher(events: events)
      let dueTime = 5
      let publisher = Publishers.Debounce(
         upstream: upstream,
         dueTime: VirtualTimeInterval(dueTime),
         scheduler: handler.scheduler,
         options: nil
      )
      let completion = publisher.failure(.default, at: 9)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b"])
      XCTAssertEqual(results.times, [2 + dueTime])
   }
}
