import DependenciesTest
/*
 Если исходный upstream заканчивается ошибкой, то паблишер возвращает новый
 upstream. Подписка на новый upstream происходит в момент окончания ошибкой
 исходного upstream.
 */
final class Catch: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events0: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let events1: [TestEvent<String>] = [
         .value("a", at: 1),
         .success(at: 2)
      ]
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.success(at: 2)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, ["a"])
      XCTAssertEqual(results.times, [1])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events0: [TestEvent<String>] = [
         .failure(.default, at: 0)
      ]
      let events1: [TestEvent<String>] = [
         .failure(.thrown, at: 1)
      ]
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let completion = publisher.failure(.thrown, at: 1)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
