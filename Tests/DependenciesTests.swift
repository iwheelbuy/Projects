import Entwine
import EntwineTest
import XCTest
@testable import Dependencies

final class DependenciesTests: XCTestCase {

   func testExample() {
      let scheduler = TestScheduler()
      let publisher: TestablePublisher<String, Never> = scheduler.createAbsoluteTestablePublisher([
         (201, .input("yippee")),
         (301, .input("ki")),
         (401, .input("yay"))
      ])
      let expectedOutput: TestSequence<String, Never> = [
         (200, .subscription),
         (201, .input("yippee")),
         (301, .input("ki")),
         (401, .input("yay")),
      ]
      let subscriber = scheduler.start(create: { publisher })
      XCTAssert(expectedOutput == subscriber.recordedOutput)
   }

   static var allTests = [
      ("testExample", testExample),
   ]
}

