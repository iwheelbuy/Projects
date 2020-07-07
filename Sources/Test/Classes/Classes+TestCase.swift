import EntwineTest
import XCTest

open class TestCase: XCTestCase {

   public var configuration = TestScheduler.Configuration.default
   public var scheduler = TestScheduler()

   open override func setUp() {
      scheduler = TestScheduler()
   }
}
