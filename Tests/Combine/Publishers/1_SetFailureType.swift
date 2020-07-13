import DependenciesTest
/*
 У паблишера с типом ошибки Never меняет тип ошибки на любой другой Swift.Error
 */
final class SetFailureType: XCTestCase {

   func test_common_behavior() {
      let upstream = PassthroughSubject<Int, Never>()
      let publisher = Publishers.SetFailureType<PassthroughSubject<Int, Never>, TestError>(upstream: upstream)
      XCTAssertFalse(type(of: publisher).Failure == Swift.Error.self)
      XCTAssertTrue(type(of: publisher).Failure == TestError.self)
   }
}
