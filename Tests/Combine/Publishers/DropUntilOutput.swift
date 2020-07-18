import DependenciesTest
/*
 Значения из upstream не публикуются пока other не опубликует первое значение.
 Даже если other закончится ошибкой после публикации первого занчения, upstream
 продолжит публиковать значения
 */
final class DropUntilOutput: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 2),
         .value("c", at: 4),
         .success(at: 6)
      ]
      let events1: [TestEvent<String>] = [
         .value("x", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.DropUntilOutput(upstream: upstream0, other: upstream1)
      let completion = publisher.success(at: 6)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [2, 4])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 2),
         .value("c", at: 4),
         .failure(.default, at: 5)
      ]
      let events1: [TestEvent<String>] = [
         .value("x", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.DropUntilOutput(upstream: upstream0, other: upstream1)
      let completion = publisher.failure(.default, at: 5)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["b", "c"])
      XCTAssertEqual(results.times, [2, 4])
   }
}
