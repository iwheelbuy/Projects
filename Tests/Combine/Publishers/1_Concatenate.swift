import DependenciesTest
/*
 Из prefix upstream публикуются все значения. Только после успешного завершения
 prefix upstream начнут публиковаться новые значения из suffix upstream.
 */
final class Concatenate: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 2),
         .success(at: 4)
      ]
      let events1: [TestEvent<String>] = [
         .value("c", at: 1),
         .value("d", at: 3),
         .value("e", at: 5),
         .success(at: 7)
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.Concatenate(prefix: upstream0, suffix: upstream1)
      let completion = publisher.success(at: 7)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b", "e"])
         XCTAssertEqual(results.times, [0, 2, 5])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 2),
         .failure(.default, at: 4)
      ]
      let events1: [TestEvent<String>] = [
         .value("c", at: 1),
         .value("d", at: 3),
         .value("e", at: 5),
         .success(at: 7)
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.Concatenate(prefix: upstream0, suffix: upstream1)
      let completion = publisher.failure(.default, at: 4)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a", "b"])
         XCTAssertEqual(results.times, [0, 2])
      }
   }
}
