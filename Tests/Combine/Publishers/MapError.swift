//import DependenciesTest
///*
// Применяется трансформация к ошибке.
// */
//final class MapError: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
//         (1, .completion(.failure(.empty)))
//      ])
//      let publisher = Publishers.MapError(upstream: upstream, { error -> TestError in
//         return TestError.thrown
//      })
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.failed(failure: .thrown, time: configuration.subscribed + 1))
//   }
//}
