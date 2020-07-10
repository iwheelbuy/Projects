import DependenciesTest
/*
 Если за временной интервал массив успевает заполниться до требуемого размера,
 то он публикуется в момент получения последнего элемента. После публикации
 массив очищается и процедура повторяется. Если массив к окончанию временного
 интервала окажется не пустым, то он опубликуется в момент окончания временного
 интервала.
 */
final class CollectByTime: XCTestCase {

   private class Input {

      private lazy var _interval: Int = {
         let interval = Int(Double(values.max()!) / Double(5 + arc4random_uniform(5)))
         return interval % 2 == 0 ? interval : interval + 1
      }()
      private(set) lazy var values: [Int] = {
         let array = Array(0 ... 50).map({ _ in Int(1 + arc4random_uniform(100)) })
         return Set(array).filter({ $0 % 2 != 0 }).sorted()
      }()
      let count = Int(2 + arc4random_uniform(4))
      let multiplier: Int

      var expected: [[Int]] {
         return Array(0 ... values.max()! / _interval)
            .map({ value -> ClosedRange<Int> in
               return value * _interval ... (value + 1) * _interval
            })
            .flatMap({ range -> [[Int]] in
               return values
                  .filter({ range.contains($0) })
                  .split(count: count)
            })
      }

      init(multiplier: Int = 10) {
         self.multiplier = multiplier
      }

      var interval: DispatchQueue.SchedulerTimeType.Stride {
         return .milliseconds(_interval * multiplier)
      }

      func deadline(_ value: Int? = nil) -> DispatchTime {
         if let value = value {
            let delay = TimeInterval(value * multiplier) / 1000
            return DispatchTime.now() + delay
         } else {
            let delay = TimeInterval((values.max()! + _interval + 1) * multiplier) / 1000
            return DispatchTime.now() + delay
         }
      }
   }

   func test_asdf() {
      DispatchQueue.concurrentPerform(iterations: 100) { _ in
         let input = Input()
         let group = DispatchGroup()
         group.enter()
         let upstream = PassthroughSubject<Int, Never>()
         let strategy = Publishers.TimeGroupingStrategy<DispatchQueue>
            .byTimeOrCount(DispatchQueue.global(), input.interval, input.count)
         let publisher = Publishers.CollectByTime(
            upstream: upstream,
            strategy: strategy,
            options: nil
         )
         var emitted = [[Int]]()
         let cancel = publisher.sink(receiveValue: { emitted.append($0) })
         for value in input.values {
            let deadline = input.deadline(value)
            DispatchQueue.global().asyncAfter(deadline: deadline) {
               upstream.send(value)
            }
         }
         let deadline = input.deadline()
         DispatchQueue.global().asyncAfter(deadline: deadline) {
            group.leave()
         }
         group.wait()
         XCTAssertEqual(input.expected, emitted)
      }
   }
}
