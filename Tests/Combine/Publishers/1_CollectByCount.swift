import DependenciesTest
/*
 Публикует массив собранных данных размером count в момент времени, когда массив
 наполняется до размера count. После публикации массив очищается. Если к моменту
 успешного завершения upstream будет собран неполный массив, то этот массив
 будет опубликован перед завершением. Если к моменту завершения с ошибкой будет
 собран неполный массив, то этот массив опубликован не будет.
 */
final class CollectByCount: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .value("c", at: timer[2]),
         .success(at: timer[3])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.CollectByCount(upstream: upstream, count: 2)
      let completion = publisher.success(at: timer[3])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [["a", "b"], ["c"]])
         XCTAssertEqual(results.times, [timer[1], timer[3]])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage(timer: timer)
      let events: [TestEvent<String>] = [
         .value("a", at: timer[0]),
         .value("b", at: timer[1]),
         .value("c", at: timer[2]),
         .failure(.default, at: timer[3])
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.CollectByCount(upstream: upstream, count: 2)
      let completion = publisher.failure(.default, at: timer[3])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [["a", "b"]])
         XCTAssertEqual(results.times, [timer[1]])
      }
   }
}
