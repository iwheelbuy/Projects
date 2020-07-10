import DependenciesTest
/*
 Непосредственно перед успешным завершением публикует последнее значение,
 которое находится в возрастающем порядке к предыдущему результату сравения или
 к первому опубликованному значению из upstream. Если при сравнении будет
 выбрашена ошибка, то паблишер завершится с этой ошибкой.
 */
final class TryComparison: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (1, .input("b")),
         (2, .completion(.finished))
      ])
      let publisher = Publishers.TryComparison(upstream: upstream, areInIncreasingOrder: { $0 > $1 })
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 1)
      XCTAssertEqual(subscriber.inputs.first, "b")
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 2))
   }

   func test_failure_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .completion(.failure(.empty)))
      ])
      let publisher = Publishers.TryComparison(upstream: upstream, areInIncreasingOrder: { _, _ in true })
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 2))
   }

   func test_throwing_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (1, .input("b")),
         (2, .completion(.finished))
      ])
      let publisher = Publishers.TryComparison(
         upstream: upstream,
         areInIncreasingOrder: { _, _ in throw TestError.thrown }
      )
      let subscriber = scheduler.start(configuration: configuration, create: {
         return publisher
            .mapError({ error -> TestError in
               if let error = error as? TestError {
                  return error
               } else {
                  return TestError.undefined
               }
            })
      })
      XCTAssertTrue(subscriber.inputs.isEmpty)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(failure: .thrown, time: configuration.subscribed + 1))
   }
}
