//import DependenciesTest
///*
// Применяется трансформация к каждому новому значению из upstream. Каждое
// значение трансформации публикуется.
// */
//final class Map: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (4, .completion(.finished))
//      ])
//      let publisher = Publishers.Map(upstream: upstream, transform: { $0.uppercased() })
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs, ["A", "B", "C"])
//      for index in 1 ... 3 {
//         let time = VirtualTime(index)
//         XCTAssertEqual(subscriber.values[index].time, configuration.subscribed + time)
//      }
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 4))
//   }
//
//   func test_failure_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (4, .completion(.failure(.empty)))
//      ])
//      let publisher = Publishers.Map(upstream: upstream, transform: { $0.uppercased() })
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs, ["A", "B", "C"])
//      for index in 1 ... 3 {
//         let time = VirtualTime(index)
//         XCTAssertEqual(subscriber.values[index].time, configuration.subscribed + time)
//      }
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 4))
//   }
//}
