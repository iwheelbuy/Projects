import DependenciesTest
/*
 Применяется трансформация к каждому новому значению из upstream и предыдущему
 результату трансформации. Каждое значение трансформации публикуется.
 */
final class TryScan: TestCase {

   func test_common_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .completion(.finished))
      ])
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, next -> String in
            return previous + next
         }
      )
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 3)
      XCTAssertEqual(subscriber.inputs, ["a", "ab", "abc"])
      for index in 1 ... 3 {
         let time = VirtualTime(index)
         XCTAssertEqual(subscriber.values[index].time, configuration.subscribed + time)
      }
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
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, next -> String in
            return previous + next
         }
      )
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      XCTAssertEqual(subscriber.inputs.count, 3)
      XCTAssertEqual(subscriber.inputs, ["a", "ab", "abc"])
      for index in 1 ... 3 {
         let time = VirtualTime(index)
         XCTAssertEqual(subscriber.values[index].time, configuration.subscribed + time)
      }
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(time: configuration.subscribed + 4))
   }

   func test_throwing_behavior() {
      let upstream: TestablePublisher<String, TestError> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (3, .input("c")),
         (4, .completion(.finished))
      ])
      let publisher = Publishers.TryScan(
         upstream: upstream,
         initialResult: "",
         nextPartialResult: { previous, next -> String in
            throw TestError.thrown
         }
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
      XCTAssertEqual(subscriber.inputs.count, 0)
      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
      XCTAssertTrue(subscriber.failed(failure: .thrown, time: configuration.subscribed + 1))
   }
}
