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
      /// Время когда стоит закончить upstream
      func makeCompletionTime(interval: Int, values: [Int]) -> Int {
         return interval + values.max()!
      }
      /// События для публикации на базе исходные значений
      func makeEvents(completionTime: Int, values: [Int]) -> [TestEvent<Int>] {
         let events: [TestEvent<Int>] = values
            .map({ TestEvent(case: .value($0), time: $0) })
            .appending(.success(at: completionTime))
         return events
      }
      /// Интервал, которые учитывает исходные значения
      func makeInterval(values: [Int]) -> Int {
         return Int(Double(values.max()!) / Double(3 + arc4random_uniform(5)))
      }
      /// Предполагаемые интервалы на базе исходные значений
      func makeRanges(interval: Int, values: [Int]) -> [[Int]] {
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
         return ranges
      }
      /// Исходные значения. Каждое значение обозначает еще и время, когда его следует опубликовать
      func makeValues() -> [Int] {
         return Array(0 ... 50)
            .map({ _ in Int(1 + arc4random_uniform(100)) })
            .set
            .sorted()
      }

      DispatchQueue.concurrentPerform(iterations: 1000) { _ in
         let handler = TestHandler()
         let values = makeValues()
         let interval = makeInterval(values: values)
         let completionTime = makeCompletionTime(interval: interval, values: values)
         let ranges = makeRanges(interval: interval, values: values)
         let events = makeEvents(completionTime: completionTime, values: values)
         let latest = arc4random() % 2 == 0
         let upstream = handler.publisher(events: events)
         let publisher = Publishers.Throttle(
            upstream: upstream,
            interval: VirtualTimeInterval(interval),
            scheduler: handler.scheduler,
            latest: latest
         )
         let completion = publisher.success(at: completionTime)
         let results = handler.test(publisher, completion: completion)
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
