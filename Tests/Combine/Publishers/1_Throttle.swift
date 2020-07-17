import DependenciesTest
/*
 1. Публикуется первое значение.
 2. Если с предыдущего опубликованного значения прошло interval или больше
 времени, то следующее значение будет сразу опубликовано.
 3. Если с предыдущего опубликованного значения прошло меньше interval, то
 таймер окна включится в момент публикации нового значения и закончится через
 interval. В этом окне берется последнее значение (latest=true) или случайное
 значение (latest=false)
 */
final class Throttle: XCTestCase {

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
}
