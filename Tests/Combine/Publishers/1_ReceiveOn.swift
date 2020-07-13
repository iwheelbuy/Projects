import DependenciesTest
/*

 */
final class ReceiveOn: XCTestCase {

   func test_common_behavior() {
      var cancellables = Set<AnyCancellable>()
      let group = DispatchGroup()
      group.enter()
      group.enter()
      let scheduler0 = DispatchQueue.test(name: "a")
      let scheduler1 = DispatchQueue.test(name: "b")
      let upstream = PassthroughSubject<Int, Never>()
      let publisher0 = Publishers.ReceiveOn(upstream: upstream, scheduler: scheduler0, options: nil)
      let publisher1 = Publishers.ReceiveOn(upstream: publisher0, scheduler: scheduler1, options: nil)
      publisher1
         .handleEvents(receiveSubscription: { _ in
            print("~~>0", Thread.current.name)
            print(scheduler0.label)
            print(scheduler1.label)
            XCTAssertFalse(scheduler0.isCurrent)
            XCTAssertFalse(scheduler1.isCurrent)
         }, receiveOutput: { _ in
            print("~~>1", Thread.current.name)
            XCTAssertTrue(scheduler1.isCurrent)
            group.leave()
         })
         .sink(receiveValue: { _ in })
         .store(in: &cancellables)
      upstream
         .handleEvents(receiveSubscription: { _ in
            print("~~>2", Thread.current.name)
            XCTAssertFalse(scheduler0.isCurrent)
            XCTAssertFalse(scheduler1.isCurrent)
         }, receiveOutput: { _ in
            print("~~>3", Thread.current.name)
            XCTAssertFalse(scheduler0.isCurrent)
            XCTAssertFalse(scheduler1.isCurrent)
            group.leave()
         })
         .sink(receiveValue: { _ in })
         .store(in: &cancellables)
      upstream.send(0)
      group.wait()
   }
}
