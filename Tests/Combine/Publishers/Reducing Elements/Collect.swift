import DependenciesTest
/*
 Публикует весь массив собранных данных в момент завершения upstream. Если
 upstream завершится ошибкой, то ничего опубликовано не будет.
 */
final class Collect: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<String, Never> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .completion(.finished))
      ])
      let publisher = Publishers.Collect(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.map({ $0.joined() }), ["abc"])
      XCTAssertEqual(subscriber.values[1].time, configuration.subscribed + 4)
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
      let publisher = Publishers.Collect(upstream: upstream)
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 4))
   }
}
