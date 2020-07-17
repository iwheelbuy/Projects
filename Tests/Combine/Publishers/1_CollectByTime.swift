import DependenciesTest
/*
 Если за временной интервал массив успевает заполниться до требуемого размера,
 то он публикуется в момент получения последнего элемента. После публикации
 массив очищается и процедура повторяется. Если массив к окончанию временного
 интервала окажется не пустым, то он опубликуется в момент окончания временного
 интервала.
 */
final class CollectByTime: XCTestCase {

   func testNice() {
      DispatchQueue.concurrentPerform(iterations: 1000) { _ in
         let storage = TestStorage()
         let values = Array(0 ... 50)
            .map({ _ in Int(1 + arc4random_uniform(100)) })
            .set
            .filter({ $0 % 2 != 0 })
            .sorted()
         let interval: Int = {
            let interval = Int(Double(values.max()!) / Double(5 + arc4random_uniform(5)))
            return interval % 2 == 0 ? interval : interval + 1
         }()
         var time = values[0]
         var ranges: [[Int]] = [[values[0]]]
         while true {
            let times = values.filter({ $0 > time && $0 <= time + interval })
            if times.isEmpty {
               if let next = values.first(where: { $0 > time }) {
                  ranges.append([next])
                  time = next
               } else {
                  break
               }
            } else {
               if times[0] == time + interval {
                  ranges.append([times[0]])
                  time = times[0]
               } else {
                  let range = values.filter({ $0 >= times[0] && $0 <= times[0] + interval })
                  ranges.append(range)
                  time = times[0] + interval
               }
            }
         }
         let max = values.max()!
         let events: [TestEvent<Int>] = values
            .map({ TestEvent(case: .value($0), time: $0) })
            .appending(.success(at: max + interval))
         let latest = arc4random() % 2 == 0
         let upstream = storage.publisher(events: events)
         let publisher = Publishers.Throttle(
            upstream: upstream,
            interval: VirtualTimeInterval(interval),
            scheduler: storage.scheduler,
            latest: latest
         )
         let completion = publisher.success(at: max + interval)
         storage.test(publisher, completion: completion) { results in
            ranges
               .enumerated()
               .forEach({ index, range in
                  if latest {
                     XCTAssertEqual(range.last, results.values[index])
                  } else {
                     XCTAssertTrue(range.contains(results.values[index]))
                  }
               })
         }
      }
   }

   func test_common_behavior() {
      DispatchQueue.concurrentPerform(iterations: 1000) { _ in
         let storage = TestStorage()
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
         let upstream = storage.publisher(events: events)
         let strategy = Publishers.TimeGroupingStrategy<TestScheduler>
            .byTimeOrCount(storage.scheduler, VirtualTimeInterval(interval), count)
         let publisher = Publishers.CollectByTime(
            upstream: upstream,
            strategy: strategy,
            options: nil
         )
         let completion = publisher.success(at: max)
         storage.test(publisher, completion: completion) { results in
            XCTAssertEqual(results.values, expected)
         }
      }
   }
}
