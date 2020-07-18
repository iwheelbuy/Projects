import DependenciesTest
/*
 В момент подписания публикуются все элементы массива в том порядке, в каком
 они находятся в массиве. После чего сразу происходит успешное завершение.
 */
final class Sequence: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let publisher = Publishers.Sequence<[Int], TestError>(sequence: [0, 1, 2])
      let results = handler.test(publisher)
      XCTAssertEqual(results.values, [0, 1, 2])
   }
}
