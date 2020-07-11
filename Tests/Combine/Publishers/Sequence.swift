//import DependenciesTest
///*
// Публикует массив в момент подписания и сразу успешно завершается.
// */
//final class Sequence: TestCase {
//
//   func test_common_behavior() {
//      let sequence = Array(0 ... 1 + arc4random() % 10).map({ _ in arc4random() })
//      let publisher = Publishers.Sequence<[UInt32], TestError>(sequence: sequence)
//      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
//      XCTAssertEqual(subscriber.inputs, sequence)
//      subscriber.values.forEach({ value in
//         XCTAssertEqual(value.time, configuration.subscribed)
//      })
//      XCTAssertTrue(subscriber.subscribed(time: configuration.subscribed))
//      XCTAssertTrue(subscriber.completed(time: configuration.subscribed))
//   }
//}
//
