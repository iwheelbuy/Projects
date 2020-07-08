import DependenciesTest
/*
 Если исходный upstream заканчивается ошибкой, то паблишер возвращает новый
 upstream. Подписка на новый upstream происходит в момент окончания ошибкой
 исходного upstream.
 */
final class Catch: TestCase {

   func test_common_behavior() {
      let upstream0: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .completion(.failure(.empty)))
      ])
      let upstream1: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (2, .input("a")),
         (3, .completion(.finished))
      ])
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.joined(), "a")
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 1 + 3))
   }

   func test_failure_behavior() {
      let upstream0: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .completion(.failure(.empty)))
      ])
      let upstream1: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (3, .completion(.failure(.thrown)))
      ])
      let publisher = Publishers.Catch(upstream: upstream0, handler: { _ in upstream1 })
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(failure: .thrown, time: configuration.subscribed + 1 + 3))
   }
}

