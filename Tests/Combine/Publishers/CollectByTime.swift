import DependenciesTest
/*
 Если за временной интервал массив успевает заполниться до требуемого размера,
 то он публикуется в момент получения последнего элемента. После публикации
 массив очищается и процедура повторяется. Если массив к окончанию временного
 интервала окажется не пустым, то он опубликуется в момент окончания временного
 интервала.
 */
final class CollectByTime: TestCase {

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
      let microseconds: Int

      var expected: [ArraySlice<Int>] {
         return Array(0 ... values.max()! / _interval)
            .map({ value -> ClosedRange<Int> in
               return value * _interval ... (value + 1) * _interval
            })
            .flatMap({ range -> [ArraySlice<Int>] in
               let size = count
               return values
                  .filter({ range.contains($0) })
                  .slices(size: size)
            })
            .filter({ $0.isNotEmpty })
      }

      init(microseconds: Int = 15) {
         self.microseconds = microseconds
      }

      var interval: DispatchQueue.SchedulerTimeType.Stride {
         return .microseconds(_interval * microseconds)
      }

      func deadline(_ value: Int? = nil) -> DispatchTime {
         if let value = value {
            let delay = TimeInterval(value * microseconds) / 1000000
            return DispatchTime.now() + delay
         } else {
            let delay = TimeInterval((values.max()! + _interval + 1) * microseconds) / 1000000
            return DispatchTime.now() + delay
         }
      }
   }

   func test_common_behavior() {
      DispatchQueue.concurrentPerform(iterations: 100) { _ in
         var equal = false
         for microseconds in [666, 1111, 3333, 7777] where equal == false {
            let input = Input(microseconds: microseconds)
            let group = DispatchGroup()
            group.enter()
            let upstream = PassthroughSubject<Int, Never>()
            let strategy = Publishers.TimeGroupingStrategy<DispatchQueue>
               .byTimeOrCount(DispatchQueue.global(qos: .userInteractive), input.interval, input.count)
            let publisher = Publishers.CollectByTime(
               upstream: upstream,
               strategy: strategy,
               options: nil
            )
            var emitted = [[Int]]()
            publisher
               .sink(receiveValue: { emitted.append($0) })
               .store(in: &cancellables)
            for value in input.values {
               let deadline = input.deadline(value)
               DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: deadline) {
                  upstream.send(value)
               }
            }
            let deadline = input.deadline()
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: deadline) {
               group.leave()
            }
            group.wait()
            let expected = input.expected.map({ Array($0) })
            equal = emitted == expected
            if equal == false {
               print("~>", microseconds)
            }
         }
         XCTAssertTrue(equal)
      }
   }
}
