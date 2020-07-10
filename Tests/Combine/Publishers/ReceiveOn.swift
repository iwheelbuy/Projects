import DependenciesTest
/*
 Если за временной интервал массив успевает заполниться до требуемого размера,
 то он публикуется в момент получения последнего элемента. После публикации
 массив очищается и процедура повторяется. Если массив к окончанию временного
 интервала окажется не пустым, то он опубликуется в момент окончания временного
 интервала.
 */
final class ReceiveOn: XCTestCase {

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
            let cancel = publisher.sink(receiveValue: { emitted.append($0) })
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
