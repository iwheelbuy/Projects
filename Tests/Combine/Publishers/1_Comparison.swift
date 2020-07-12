import DependenciesTest
/*
 Непосредственно перед успешным завершением публикует последнее значение,
 которое находится в возрастающем порядке к предыдущему результату сравения или
 к первому опубликованному значению из upstream. Первый параметр в замыкании -
 это новое значение.
 */
final class Comparison: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("c", at: 1),
         .value("b", at: 2),
         .success(at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Comparison(upstream: upstream, areInIncreasingOrder: { $0 > $1 })
      let completion = publisher.success(at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, ["c"])
         XCTAssertEqual(results.times, [3])
      }
   }

   func test_empty_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<Int>] = [
         .success(at: 0)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Comparison(upstream: upstream, areInIncreasingOrder: { $0 > $1 })
      let completion = publisher.success(at: 0)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("c", at: 1),
         .value("b", at: 2),
         .failure(.default, at: 3)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Comparison(upstream: upstream, areInIncreasingOrder: { $0 > $1 })
      let completion = publisher.failure(.default, at: 3)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }

   func test_max_behavior() {
      let storage = TestStorage()
      let count = 50
      let values = Array(0 ..< count)
         .set
         .map({ _ in Int(arc4random_uniform(1000) ) })
      let events: [TestEvent<Int>] = values
         .enumerated()
         .map({ TestEvent.value($0.element, at: $0.offset) })
         .appending(.success(at: count))
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Comparison.max(upstream: upstream)
      let completion = publisher.success(at: count)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [values.max()!])
         XCTAssertEqual(results.times, [count])
      }
   }

   func test_min_behavior() {
      let storage = TestStorage()
      let count = 50
      let values = Array(0 ..< count)
         .set
         .map({ _ in Int(arc4random_uniform(1000) ) })
      let events: [TestEvent<Int>] = values
         .enumerated()
         .map({ TestEvent.value($0.element, at: $0.offset) })
         .appending(.success(at: count))
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Comparison.min(upstream: upstream)
      let completion = publisher.success(at: count)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [values.min()!])
         XCTAssertEqual(results.times, [count])
      }
   }
}
