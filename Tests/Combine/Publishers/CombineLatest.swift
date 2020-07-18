import DependenciesTest
/*
 Первое значение публикуется только после того как каждый из upstream опубликует
 хотябы одно значение. Публикуется каждый раз когда любой из upstream публикует
 новое значение. Завершается успехом когда каждый из upstream завершится успехом
 в момент когда последний незавершившийся upstream завершится. Завершается
 ошибкой в момент завершения ошибкой любого из upstream.
 */
final class CombineLatest: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
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
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.CombineLatest(upstream0, upstream1)
         .map({ [$0.0, $0.1] })
      let completion = publisher.success(at: 7)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [["a", "c"], ["b", "c"], ["b", "d"], ["b", "e"]])
      XCTAssertEqual(results.times, [1, 2, 3, 5])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events0: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 2),
         .failure(.custom("0"), at: 4)
      ]
      let events1: [TestEvent<String>] = [
         .value("c", at: 1),
         .value("d", at: 3),
         .value("e", at: 5),
         .failure(.custom("1"), at: 7)
      ]
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.CombineLatest(upstream0, upstream1)
         .map({ [$0.0, $0.1] })
      let completion = publisher.failure(.custom("0"), at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [["a", "c"], ["b", "c"], ["b", "d"]])
      XCTAssertEqual(results.times, [1, 2, 3])
   }
}
