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

   func getRanges(interval: Int, values: [Int]) -> [ArraySlice<Int>] {
      if values.isEmpty {
         return []
      }
      let values = values.sorted()
      var ranges: [ArraySlice<Int>] = [[values[0]]]
      var time = values[0]
      while true {
         let times = values
            .prefix(while: { $0 <= time + interval })
            .drop(while: { $0 <= time })
         if times.isNotEmpty {
            if times.first == time + interval {
               ranges.append([times.first!])
               time = times.first!
            } else {
               let range = values
                  .prefix(while: { $0 <= times.first! + interval })
                  .drop(while: { $0 < times.first! })
               ranges.append(range)
               time = times.first! + interval
            }
         } else if let next = values.first(where: { $0 > time }) {
            ranges.append([next])
            time = next
         } else {
            break
         }
      }
      return ranges
   }

   func getResults(interval: Int, latest: Bool, values: [Int]) -> [TestResult<Int>] {
      let handler = TestHandler()
      let completionTime = values.max()! + interval + 1
      let events: [TestEvent<Int>] = values
         .map({ TestEvent(case: .value($0), time: $0) })
         .appending(.success(at: completionTime))
      let upstream = handler.publisher(events: events)
      let publisher = Publishers.Throttle(
         upstream: upstream,
         interval: VirtualTimeInterval(interval),
         scheduler: handler.scheduler,
         latest: latest
      )
      let completion = publisher.success(at: completionTime)
      return handler.test(publisher, completion: completion)
   }

   func test_random_behavior() {
      DispatchQueue.concurrentPerform(iterations: 10000) { _ in
         let values = Array(0 ... 20)
            .map({ _ in Int(1 + arc4random_uniform(40)) })
            .sorted()
         let interval = 1 + Int(arc4random()) % values.max()! * 2
         let ranges = getRanges(interval: interval, values: values)
         let latest = arc4random() % 2 == 0
         let results = getResults(interval: interval, latest: latest, values: values)
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
