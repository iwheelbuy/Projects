//import DependenciesTest
///*
//
// */
//final class Debounce: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (8, .input("c")),
//         (99, .completion(.finished))
//      ])
//      let publisher = Publishers.Debounce(
//         upstream: upstream,
//         dueTime: 5,
//         scheduler: scheduler,
//         options: nil
//      )
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs, ["b", "c"])
////      XCTAssertEqual(subscriber.values[1].time, configuration.subscribed + 2)
////      XCTAssertEqual(subscriber.values[2].time, configuration.subscribed + 4)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 99))
//   }
//
//   func test_failure_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .input("c")),
//         (4, .completion(.failure(.empty)))
//      ])
//      let publisher = Publishers.CollectByCount(upstream: upstream, count: 2)
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs.count, 1)
//      XCTAssertEqual(subscriber.inputs.map({ $0.joined() }), ["ab"])
//      XCTAssertEqual(subscriber.values[1].time, configuration.subscribed + 2)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 4))
//   }
//}
