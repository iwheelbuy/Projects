import EntwineTest
import XCTest

open class TestCase: XCTestCase {

   private var _configuration: TestScheduler.Configuration!
   public var configuration: TestScheduler.Configuration {
      get {
         return _configuration
      }
      set {
         _configuration = newValue
      }
   }
   private var _scheduler: TestScheduler!
   public var scheduler: TestScheduler {
      get {
         return _scheduler
      }
      set {
         _scheduler = newValue
      }
   }

   open override func setUp() {
      _configuration = TestScheduler.Configuration.default
      _scheduler = TestScheduler()
   }
}
