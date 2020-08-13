import DependenciesTest
/*
 Все значения из upstream передаются в Subject, который будет создан при первой
 подписке на Multicast. Все, кто подписался, будут получать значения из Subject.
 Создается ровно один Subject для всех подписчиков.
 */
final class Multicast: XCTestCase {

   func test_multicase_create_subject_called_only_once_for_multiple_subscribtions() {
      var cancellables: Set<AnyCancellable> = Set()
      let group = DispatchGroup()
      let subject = PassthroughSubject<Int, Never>()
      var counter = 0
      let lock = NSLock()
      let createSubject: () -> CurrentValueSubject<Int, Never> = {
         lock.lock()
         defer {
            lock.unlock()
         }
         counter += 1
         return CurrentValueSubject<Int, Never>(0)
      }
      let multicast = Publishers.Multicast(upstream: subject, createSubject: createSubject)
      for _ in 0 ... 2 {
         group.enter()
         multicast
            .sink(receiveValue: { _ in
               group.leave()
            })
            .store(in: &cancellables)
      }
      subject.send(1)
      group.wait()
      XCTAssertEqual(counter, 1)
   }
}
