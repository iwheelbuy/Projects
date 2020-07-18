import Combine
import Entwine
import EntwineTest
import XCTest

public class TestHandler {

   public var cancellables: Set<AnyCancellable> = Set()
   private let configuration: TestScheduler.Configuration
   public let scheduler = TestScheduler(initialClock: -3)

   public init() {
      var configuration = TestScheduler.Configuration.default
      configuration.created = -1
      configuration.subscribed = 0
      configuration.cancelled = 1000
      self.configuration = configuration
   }

   public func publisher<V>(absolute: Bool = true, events: [TestEvent<V>]) -> AnyPublisher<V, TestError> {
      let elements = events
         .map({ event -> (VirtualTime, Entwine.Signal<V, TestError>) in
            let signal: Entwine.Signal<V, TestError>
            switch event.case {
            case .success:
               signal = .completion(.finished)
            case .failure(let error):
               signal = .completion(.failure(error))
            case .subscription:
               signal = .subscription
            case .value(let value):
               signal = .input(value)
            }
            let time = VirtualTime(event.time)
            return (time, signal)
         })
      let sequence = TestSequence<V, TestError>(elements)
      switch absolute {
      case false:
         return scheduler.createRelativeTestablePublisher(sequence).eraseToAnyPublisher()
      case true:
         return scheduler.createAbsoluteTestablePublisher(sequence).eraseToAnyPublisher()
      }
   }
   @discardableResult
   public func test<P, V>(_ publisher: P, completion: TestEvent<V>? = nil) -> [TestResult<V>] where P: Publisher, P.Output == V {
      let subscriber = scheduler
         .start(configuration: configuration, create: {
            return publisher
               .mapError({ error -> TestError in
                  if let error = error as? TestError {
                     return error
                  } else {
                     return TestError.undefined
                  }
               })
         })
      let events: [TestEvent<V>] = subscriber.events
      XCTAssertTrue(events.first?.case.isSubscription ?? false)
      if let completion = completion {
         XCTAssertEqual(events.last, completion)
      }
      let results = events
         .dropLast()
         .dropFirst()
         .compactMap({ event -> TestResult<V>? in
            guard let value = event.case.value else {
               return nil
            }
            let time = event.time
            return TestResult<V>(time: time, value: value)
         })
      return results
   }
}
