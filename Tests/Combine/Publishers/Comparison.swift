import DependenciesTest
/*
 Непосредственно перед успешным завершением публикует последнее значение,
 которое находится в возрастающем порядке к предыдущему результату сравения или
 к первому опубликованному значению из upstream.
 */
final class Comparison: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .completion(.finished))
      ])
      let publisher = Publishers.Comparison.max(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 1)
      XCTAssertEqual(subscriber.inputs.first, "a")
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 2))
   }

   func test_failure_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .completion(.failure(.empty)))
      ])
      let publisher = Publishers.Comparison.max(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 2))
   }

   func test_max_behavior() {
      let upstream: TestablePublisher<Int, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input(1)),
         (1, .input(2)),
         (1, .input(3)),
         (1, .input(2)),
         (1, .input(3)),
         (1, .input(4)),
         (1, .input(1)),
         (1, .input(2)),
         (2, .completion(.finished))
      ])
      let publisher = Publishers.Comparison.max(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 1)
      XCTAssertEqual(subscriber.inputs.first, 4)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 2))
   }

   func test_min_behavior() {
      let upstream: TestablePublisher<Int, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input(1)),
         (1, .input(2)),
         (1, .input(3)),
         (1, .input(2)),
         (1, .input(3)),
         (1, .input(4)),
         (1, .input(1)),
         (2, .completion(.finished))
      ])
      let publisher = Publishers.Comparison.min(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 1)
      XCTAssertEqual(subscriber.inputs.first, 1)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 2))
   }
}
