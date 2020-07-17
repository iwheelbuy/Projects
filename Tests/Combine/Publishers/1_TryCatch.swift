import DependenciesTest
/*
 Если исходный upstream заканчивается ошибкой, то паблишер возвращает новый
 upstream. Подписка на новый upstream происходит в момент окончания ошибкой
 исходного upstream.
 */
final class TryCatch: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events0: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let events1: [TestEvent<String>] = [
         .value("a", at: 1),
         .success(at: 2)
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.TryCatch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.success(at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["a"])
         XCTAssertEqual(results.times, [1])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events0: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let events1: [TestEvent<String>] = [
         .failure(.thrown, at: 1)
      ]
      let upstream0 = storage.publisher(events: events0)
      let upstream1 = storage.publisher(events: events1)
      let publisher = Publishers.TryCatch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.failure(.thrown, at: 1)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }

   func test_throwing_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let upstream = storage.publisher(events: events)
      typealias X = AnyPublisher<String, TestError>
      let publisher = Publishers.TryCatch<X, X>(upstream: upstream, handler: { _ in throw TestError.thrown })
      let completion = publisher.failure(.thrown, at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
