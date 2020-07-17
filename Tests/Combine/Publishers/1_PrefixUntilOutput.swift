import DependenciesTest
/*
 Значения из upstream не публикуются пока other не опубликует первое значение.
 Даже если other закончится ошибкой после публикации первого занчения, upstream
 продолжит публиковать значения
 */
final class PrefixUntilOutput: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
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
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.PrefixUntilOutput(upstream: upstream0, other: upstream1)
      let completion = publisher.success(at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a"])
         XCTAssertEqual(results.times, [0])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .failure(.default, at: 1)
      ]
      let events1: [TestEvent<String>] = [
         .value("x", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.PrefixUntilOutput(upstream: upstream0, other: upstream1)
      let completion = publisher.failure(.default, at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a"])
         XCTAssertEqual(results.times, [0])
      }
   }
}
