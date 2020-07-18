import DependenciesTest
/*
 Если upstream заканчиваетя ошибкой, то срабатывает Swift.asserfationFailure()
 */
final class AssertNoFailure: XCTestCase {

   func test_common_behavior() {
      let handler = TestHandler()
      let events: [TestEvent<Int>] = [
         .failure(.default, at: 0)
      ]
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.AssertNoFailure(upstream: upstream)
      let exception = catchBadInstruction {
         handler.test(publisher)
      }
      XCTAssertNotNil(exception)
   }
}
