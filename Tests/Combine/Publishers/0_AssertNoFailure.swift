import DependenciesTest
/*
 Если upstream заканчиваетя ошибкой, то срабатывает Swift.asserfationFailure()
 */
final class AssertNoFailure: XCTestCase {

   func test_common_behavior() {
      let storage = TestStorage()
      let events: [TestEvent<Int>] = [
         .failure(.default, at: 0)
      ]
      let upstream = storage.publisher(events: events)
      let publisher = Publishers.AssertNoFailure(upstream: upstream)
      let exception = catchBadInstruction {
         storage.test(publisher)
      }
      XCTAssertNotNil(exception)
   }
}
