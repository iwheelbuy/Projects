import DependenciesTest
/*
 Если upstream публикует ожидаемое значение, то downstream публикует true и
 успешно завершается. Если downstream так и не дожидается ожидаемого значения,
 то непосредственно перед успешным завершением будет опубликовано false. Если
 upstream не публикует ожидаемого значения и заканчивается ошибкой, то
 downstream не опубликут ничего и завершится ошибкой.
 */
final class Contains: XCTestCase {

   func test_common_behavior() {
      for index in [0, 1] {
         let storage = TestStorage()
         let events: [TestEvent<String>] = [
            .value("a", at: 0),
            .value("b", at: 1),
            .success(at: 2)
         ]
         let upstream = storage.publisher(events: events)
         switch index {
         case 0:
            let publisher = Publishers.Contains(upstream: upstream, output: "b")
            let completion = publisher.success(at: 1)
            storage.test(publisher, completion: completion) { results in
               XCTAssertEqual(results.values, [true])
               XCTAssertEqual(results.times, [1])
            }
         case 1:
            let publisher = Publishers.Contains(upstream: upstream, output: "c")
            let completion = publisher.success(at: 2)
            storage.test(publisher, completion: completion) { results in
               XCTAssertEqual(results.values, [false])
               XCTAssertEqual(results.times, [2])
            }
         default:
            fatalError()
         }
      }
   }

   func test_failure_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<String>] = [
         .value("a", at: 0),
         .value("b", at: 1),
         .failure(.default, at: 2)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.Contains(upstream: upstream, output: "c")
      let completion = publisher.failure(.default, at: 2)
      storage.test(publisher, completion: completion) { results in
         XCTAssertEqual(results.values, [])
         XCTAssertEqual(results.times, [])
      }
   }
}
