import DependenciesTest
/*
 Если за временной интервал массив успевает заполниться до требуемого размера,
 то он публикуется в момент получения последнего элемента. После публикации
 массив очищается и процедура повторяется. Если массив к окончанию временного
 интервала окажется не пустым, то он опубликуется в момент окончания временного
 интервала.
 */
final class CollectByTime: XCTestCase {

   func test_common_behavior() {
      DispatchQueue.concurrentPerform(iterations: 1000) { _ in
         let handler = TestHandler()
         let values = Array(0 ... 50)
            .map({ _ in Int(1 + arc4random_uniform(100)) })
            .set
            .filter({ $0 % 2 != 0 })
            .sorted()
         let interval: Int = {
            let interval = Int(Double(values.max()!) / Double(5 + arc4random_uniform(5)))
            return interval % 2 == 0 ? interval : interval + 1
         }()
         let count = Int(2 + arc4random_uniform(4))
         let expected = Array(0 ... values.max()! / interval)
            .map({ value -> ClosedRange<Int> in
               return value * interval ... (value + 1) * interval
            })
            .flatMap({ range -> [[Int]] in
               return values
                  .filter({ range.contains($0) })
                  .slices(size: count)
                  .map({ Array($0) })
            })
            .filter({ $0.isNotEmpty })
         let max = values.max()!
         let events: [TestEvent<Int>] = values
            .map({ TestEvent(case: .value($0), time: $0) })
            .appending(.success(at: max))
         let upstream = handler.publisher(events: events)
         let strategy = Publishers.TimeGroupingStrategy<TestScheduler>
            .byTimeOrCount(handler.scheduler, VirtualTimeInterval(interval), count)
         let publisher = Publishers.CollectByTime(
            upstream: upstream,
            strategy: strategy,
            options: nil
         )
         let completion = publisher.success(at: max)
         let results = handler.test(publisher, completion: completion)
         XCTAssertEqual(results.values, expected)
      }
   }
}
