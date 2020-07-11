//import DependenciesTest
///*
// У паблишера с типом ошибки Never меняет тип ошибки на любой другой Swift.Error
// */
//final class SetFailureType: TestCase {
//
//   func test_common_behavior() {
//      let upstream: TestablePublisher<String, Never> = scheduler.createRelativeTestablePublisher([
//         (1, .input("a")),
//         (2, .completion(.finished))
//      ])
//      let publisher = Publishers.SetFailureType<TestablePublisher<String, Never>, TestError>(upstream: upstream)
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      let asdf: Any = type(of: subscriber).Failure
//      XCTAssert(asdf is TestError.Type)
//      XCTAssertEqual(subscriber.inputs.joined(), "a")
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed + 2))
//   }
//}
