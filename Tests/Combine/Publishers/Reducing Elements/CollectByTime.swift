import Combine
import Entwine
import EntwineTest
import XCTest

final class CollectByTime: XCTestCase {

   func test_common_behavior() {
      let configuration = TestScheduler.Configuration.default
      let scheduler = TestScheduler()
      let upstream: TestablePublisher<String, Never> = scheduler.createRelativeTestablePublisher([
         (1, .input("a")),
         (2, .input("b")),
         (4, .input("c")),
         (5, .input("d")),
         (7, .input("e")),
         (8, .input("f")),
         (9, .completion(.finished))
      ])
      let window: VirtualTimeInterval = 2
      let strategy = Publishers.TimeGroupingStrategy<TestScheduler>
         .byTime(scheduler, window)
      let publisher = Publishers.CollectByTime(
         upstream: upstream,
         strategy: strategy,
         options: nil
      )
      let subscriber = scheduler.start(configuration: configuration, create: { publisher })
      let values = subscriber
         .recordedOutput
         .compactMap({ _, signal -> String? in
            switch signal {
            case .input(let array):
               return array.joined()
            default:
               return nil
            }
         })
//      XCTAssertEqual(values, ["ab", "cd", "ef"])
   }
}
