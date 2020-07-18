import DependenciesTest
/*
 Для каждого значения из upstream пораждается новый поток данных. Все
 порожденные потоки публикуют значения в downstream. Пораждение каждого нового
 потока никак не влияет на ранее поражденные потоки. Заканчивается успехом
 после того, как все поражденные потоки завершатся успехом. Заканчивается
 ошибкой после того, как любой из поражденных потоков завершится ошибкой.
 Пораждается не больше, чем demand потоков.
 */
final class FlatMap: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .value(0, at: 0),
         .value(1, at: 2),
         .value(2, at: 3),
         .success(at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.FlatMap(
         upstream: upstream,
         maxPublishers: .max(2),
         transform: { value -> AnyPublisher<Int, TestError> in
            return handler.makeUpstream(value: value, completion: { .success(at: $0) })
         }
      )
      let completion = publisher.success(at: 6)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [0, 1, 10, 11])
      XCTAssertEqual(results.times, [0, 2, 3, 5])
   }

   func test_failure_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .value(0, at: 0),
         .value(1, at: 2),
         .value(2, at: 3),
         .success(at: 3)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.FlatMap(
         upstream: upstream,
         maxPublishers: .max(2),
         transform: { value -> AnyPublisher<Int, TestError> in
            return handler.makeUpstream(value: value, completion: { .failure(.custom("\(value)"), at: $0) })
         }
      )
      let completion = publisher.failure(.custom("0"), at: 4)
      let results = handler.test(publisher, completion: completion)
      XCTAssertEqual(results.values, [0, 1, 10])
      XCTAssertEqual(results.times, [0, 2, 3])
   }
}

private extension TestHandler {

   func makeUpstream(value: Int, completion: (Int) -> TestEvent<Int>) -> AnyPublisher<Int, TestError> {
      let events: [TestEvent<Int>] = [
         .value(value, at: 0),
         .value(value + 10, at: 3),
         completion(4)
      ]
      return publisher(absolute: false, events: events)
   }
}
