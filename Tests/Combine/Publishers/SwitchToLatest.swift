import DependenciesTest
/*
 Для каждого значения из upstream пораждается новый поток данных. Все
 порожденные потоки публикуют значения в downstream. Пораждение каждого нового
 потока никак не влияет на ранее поражденные потоки. Заканчивается успехом
 после того, как все поражденные потоки завершатся успехом. Заканчивается
 ошибкой после того, как любой из поражденных потоков завершится ошибкой.
 */
final class SwitchToLatest: XCTestCase {

   func test_common_behavior() {

      func makeUpstream(value: Int) -> AnyPublisher<Int, TestError> {
         let events: [TestEvent<Int>] = [
            .value(value, at: 0),
            .value(value + 10, at: 3),
            .success(at: 4)
         ]
         return handler.publisher(absolute: false, events: events)
      }

      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .value(0, at: 0),
         .value(1, at: 2),
         .success(at: 3)
      ]
      let upstream = handler
         .publisher(events: events)
         .map({ makeUpstream(value: $0) })
      let publisher = Publishers.SwitchToLatest(upstream: upstream).eraseToAnyPublisher()
      let completion = publisher.success(at: 6)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [0, 1, 11])
      XCTAssertEqual(results.times, [0, 2, 5])
   }

   func test_failure_behavior() {

      func makeUpstream(value: Int) -> AnyPublisher<Int, TestError> {
         let events: [TestEvent<Int>] = [
            .value(value, at: 0),
            .value(value + 10, at: 3),
            .failure(.custom("\(value)"), at: 4)
         ]
         return handler.publisher(absolute: false, events: events)
      }

      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .value(0, at: 0),
         .value(1, at: 2),
         .success(at: 3)
      ]
      let upstream = handler
         .publisher(events: events)
         .map({ makeUpstream(value: $0) })
      let publisher = Publishers.SwitchToLatest(upstream: upstream).eraseToAnyPublisher()
      let completion = publisher.failure(.custom("1"), at: 6)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [0, 1, 11])
      XCTAssertEqual(results.times, [0, 2, 5])
   }
}
