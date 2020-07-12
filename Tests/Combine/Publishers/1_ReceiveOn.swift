import DependenciesTest
/*

 */
final class ReceiveOn: XCTestCase {

   func test_common_behavior() {
      var cancellables = Set<AnyCancellable>()
      let group = DispatchGroup()
      group.enter()
      group.enter()
      var counter = 0
      let scheduler0 = DispatchQueue(label: "scheduler0", qos: .userInteractive, attributes: .concurrent)
      let scheduler1 = DispatchQueue(label: "scheduler1", qos: .userInteractive, attributes: .concurrent)
      let upstream = PassthroughSubject<Int, Never>()
      let publisher0 = Publishers.ReceiveOn(upstream: upstream, scheduler: scheduler0, options: nil)
      let publisher1 = Publishers.ReceiveOn(upstream: publisher0, scheduler: scheduler1, options: nil)
      publisher1
         .handleEvents(receiveSubscription: { _ in
            XCTAssertNotEqual(Thread.name, "scheduler0")
            XCTAssertNotEqual(Thread.name, "scheduler1")
         }, receiveOutput: { _ in
            XCTAssertEqual(Thread.name, "scheduler1")
            counter += 1
            group.leave()
         })
         .sink(receiveValue: { _ in })
         .store(in: &cancellables)
      upstream
         .handleEvents(receiveSubscription: { _ in
            XCTAssertNotEqual(Thread.name, "scheduler0")
            XCTAssertNotEqual(Thread.name, "scheduler1")
         }, receiveOutput: { _ in
            XCTAssertNotEqual(Thread.name, "scheduler0")
            XCTAssertNotEqual(Thread.name, "scheduler1")
            counter += 1
            group.leave()
         })
         .sink(receiveValue: { _ in })
         .store(in: &cancellables)
      upstream.send(0)
      group.wait()
      XCTAssertEqual(counter, 2)
   }
}
