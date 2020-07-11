//import DependenciesTest
///*
// Применяется трансформация к каждому новому значению из upstream и предыдущему
// результату трансформации. Финальное значение трансформации публикуется
// непосредственно перед успешным завершением upstream. В случае завершения с
// ошибкой - значение не будет опубликовано. Если во время трансформации
// произошла ошибка, то паблишер завершится ошибкой и не опубликует значений.
// */
//final class TryReduce: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (9, .completion(.finished))
//      ])
//      let publisher = Publishers.TryReduce(
//         upstream: upstream,
//         initial: "",
//         nextPartialResult: { previous, next -> String in
//            return previous + next
//         }
//      )
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs.count, 1)
//      XCTAssertEqual(subscriber.inputs.first, "abc")
//      XCTAssertEqual(subscriber.values[1].time, configuration.subscribed + 9)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 9))
//   }
//
//   func test_failure_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (9, .completion(.failure(.empty)))
//      ])
//      let publisher = Publishers.TryReduce(
//         upstream: upstream,
//         initial: "",
//         nextPartialResult: { previous, next -> String in
//            return previous + next
//         }
//      )
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs.count, 0)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 9))
//   }
//
//   func test_throwing_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (9, .completion(.finished))
//      ])
//      let publisher = Publishers.TryReduce(
//         upstream: upstream,
//         initial: "",
//         nextPartialResult: { previous, next -> String in
//            throw TestError.thrown
//         }
//      )
//      let subscriber = scheduler.start(configuration: configuration, create: {
//         return publisher
//            .mapError({ error -> TestError in
//               if let error = error as? TestError {
//                  return error
//               } else {
//                  return TestError.undefined
//               }
//            })
//      })
//      XCTAssertEqual(subscriber.inputs.count, 0)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(failure: .thrown, time: configuration.subscribed + 1))
//   }
//}
