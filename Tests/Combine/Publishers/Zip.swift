import DependenciesTest
/*
 Публикует группу значений из upstream таким образом, что порядковые номера
 опубликованных пар равны. Заканчивается успехом/неудачей когда первый из
 upstream заканчивается успехом/неудачей.
 */
final class Zip: XCTestCase {

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
      let publisher = Publishers.Zip(upstream0, upstream1)
         .map({ [$0.0, $0.1] })
      let completion = publisher.success(at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [["a", "c"], ["b", "d"]])
      XCTAssertEqual(results.times, [1, 3])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
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
      let upstream0 = handler.publisher(events: events0)
      let upstream1 = handler.publisher(events: events1)
      let publisher = Publishers.Zip(upstream0, upstream1)
         .map({ [$0.0, $0.1] })
      let completion = publisher.failure(.default, at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [["a", "c"], ["b", "d"]])
      XCTAssertEqual(results.times, [1, 3])
   }
}
