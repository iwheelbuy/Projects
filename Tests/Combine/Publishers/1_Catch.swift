import DependenciesTest
/*
 Если исходный upstream заканчивается ошибкой, то паблишер возвращает новый
 upstream. Подписка на новый upstream происходит в момент окончания ошибкой
 исходного upstream.
 */
final class Catch: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage(timer: timer)
      let events0: [TestEvent<String>] = [
         .failure(.default, at: timer[0])
      ]
      let events1: [TestEvent<String>] = [
         .value("a", at: timer[1]),
         .success(at: timer[2])
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.success(at: timer[2])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a"])
         XCTAssertEqual(results.times, [timer[1]])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage(timer: timer)
      let events0: [TestEvent<String>] = [
         .failure(.default, at: timer[0])
      ]
      let events1: [TestEvent<String>] = [
         .failure(.thrown, at: timer[1])
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.failure(.thrown, at: timer[1])
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
