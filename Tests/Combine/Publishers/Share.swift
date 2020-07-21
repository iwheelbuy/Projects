import DependenciesTest
/*
 Все подписчики будут получать один и тот же upstream вместо копий. Является
 классом, а не структурой (в отличие от большинства паблишеров)
 */
final class Share: XCTestCase {

   func test_common_behavior() {
      var cancellables: Set<AnyCancellable> = Set()
      let group = DispatchGroup()
      let subject = PassthroughSubject<Void, Never>()
      var counter = 0
      let lock = NSLock()
      var values = [0, 0, 0]
      let upstream = subject
         .map({ _ -> Int in
            lock.lock()
            defer {
               lock.unlock()
            }
            counter += 1
            return counter
         })
         .eraseToAnyPublisher()
      let shared = Publishers.Share(upstream: upstream).eraseToAnyPublisher()
      for index in 0 ... 2 {
         let publisher = index == 0 ? upstream : shared
         group.enter()
         publisher
            .sink(receiveValue: { value in
               lock.lock()
               defer {
                  lock.unlock()
                  group.leave()
               }
               values[index] = value
            })
            .store(in: &cancellables)
      }
      subject.send()
      group.wait()
      XCTAssertNotEqual(values[0], values[1])
      XCTAssertEqual(values[1], values[2])
   }
}
