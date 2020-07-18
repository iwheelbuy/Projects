import DependenciesTest
/*
 Количество значений из upstream публикуется непосредственно перед успешным
 завершением upstream. В случае завершения с ошибкой - количество значений не
 будет опубликовано.
 */
final class Count: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let count = 20 + Int(arc4random_uniform(30))
      let events: [TestEvent<Int>] = Array(0 ..< count)
         .enumerated()
         .map({ TestEvent.value($0.element, at: $0.offset) })
         .appending(.success(at: count))
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Count(upstream: upstream)
      let completion = publisher.success(at: count)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [count])
      XCTAssertEqual(results.times, [count])
   }

   func test_epmty_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .success(at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Count(upstream: upstream)
      let completion = publisher.success(at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [0])
      XCTAssertEqual(results.times, [0])
   }

   func test_failury_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .failure(.default, at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Count(upstream: upstream)
      let completion = publisher.failure(.default, at: 0)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [])
      XCTAssertEqual(results.times, [])
   }
}
