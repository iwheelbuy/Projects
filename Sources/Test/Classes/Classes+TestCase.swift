import Combine
import EntwineTest
import XCTest

open class TestCase: XCTestCase {

   private var _cancellables: Set<AnyCancellable>!
   public var cancellables: Set<AnyCancellable> {
      get {
         return _cancellables
      }
      set {
         _cancellables = newValue
      }
   }
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
      _cancellables = Set()
      _configuration = TestScheduler.Configuration.default
      _scheduler = TestScheduler()
   }
}
