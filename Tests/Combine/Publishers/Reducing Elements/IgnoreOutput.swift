import DependenciesTest
/*
 Игнорирует все значения из upstream.
 */
final class IgnoreOutput: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<String, Never> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .completion(.finished))
      ])
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 4))
   }

   func test_failure_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .completion(.failure(.empty)))
      ])
      let publisher = Publishers.IgnoreOutput(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 4))
   }
}
