import DependenciesTest
/*
 Этот оператор влияет на то, на каком потоке произойдет подписка самого первого
 в цепочке upstream потока. Учитывается только самый первый в цепочке
 SubscribeOn, остальные игнорируются.
 */
final class SubscribeOn: XCTestCase {

   func test_common_behavior() {
      var cancellables = Set<AnyCancellable>()
      let group = DispatchGroup()
      group.enter()
      group.enter()
      let scheduler0 = DispatchQueue.test(name: "a")
      let scheduler1 = DispatchQueue.test(name: "b")
      let upstream = PassthroughSubject<Int, Never>()
      let publisher0 = Publishers.SubscribeOn(upstream: upstream, scheduler: scheduler0, options: nil)
      let publisher1 = Publishers.SubscribeOn(upstream: publisher0, scheduler: scheduler1, options: nil)
      publisher0
         .handleEvents(receiveSubscription: { _ in
            XCTAssertTrue(scheduler0.isCurrent)
         }, receiveOutput: { _ in
            XCTAssertFalse(scheduler0.isCurrent)
            XCTAssertFalse(scheduler1.isCurrent)
            group.leave()
         })
         .subscribe()
         .store(in: &cancellables)
      publisher1
         .handleEvents(receiveSubscription: { _ in
            XCTAssertTrue(scheduler0.isCurrent)
         }, receiveOutput: { _ in
            XCTAssertFalse(scheduler0.isCurrent)
            XCTAssertFalse(scheduler1.isCurrent)
            group.leave()
         })
         .subscribe()
         .store(in: &cancellables)
      DispatchQueue.test(name: "c").asyncAfter(deadline: .now() + 0.1) {
         upstream.send(0)
      }
      group.wait()
   }
}
