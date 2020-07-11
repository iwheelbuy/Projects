//import DependenciesTest
///*
// Количество значений из upstream публикуется непосредственно перед успешным
// завершением upstream. В случае завершения с ошибкой - количество значений не
// будет опубликовано.
// */
//final class Count: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .completion(.finished))
//      ])
//      let publisher = Publishers.Count(upstream: upstream)
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs.count, 1)
//      XCTAssertEqual(subscriber.inputs.first, 2)
//      XCTAssertEqual(subscriber.values[1].time, configuration.subscribed + 3)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 3))
//   }
//
//   func test_failure_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .input("b")),
//         (3, .completion(.failure(.empty)))
//      ])
//      let publisher = Publishers.Count(upstream: upstream)
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertTrue(subscriber.inputs.isEmpty)
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 3))
//   }
//}
