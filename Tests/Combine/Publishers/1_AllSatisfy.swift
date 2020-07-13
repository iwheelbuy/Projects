import DependenciesTest
/*
 Если все значения из upstream подходят под условие, то после завершения
 upstream будет опубликовано true и успешное завершение. В противном случае
 будет опубликовано false и успешное завершение, но только после успешного
 завершения upstream.
 */
final class AllSatisfy: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let values = Array(0 ... 100)
         .map({ _ in Int(arc4random_uniform(50)) })
         .set
         .sorted()
      let max = values.max()!
      let events: [TestEvent<Int>] = values
         .map({ TestEvent(case: .value($0), time: $0) })
         .appending({ _ in TestEvent<Int>.success(at: max) })
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.AllSatisfy(upstream: upstream, predicate: { $0 <= max })
      let completion = publisher.success(at: max)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [true])
         XCTAssertEqual(results.times, [max])
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let values = Array(0 ... 100)
         .map({ _ in Int(arc4random_uniform(50)) })
         .set
         .sorted()
      let max = values.max()!
      let events: [TestEvent<Int>] = values
         .map({ TestEvent(case: .value($0), time: $0) })
         .appending({ _ in TestEvent<Int>.failure(.default, at: max) })
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.AllSatisfy(upstream: upstream, predicate: { $0 <= max })
      let completion = publisher.failure(.default, at: max)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
