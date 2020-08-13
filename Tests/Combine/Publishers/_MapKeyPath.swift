//import DependenciesTest
///*
//
// */
//final class MapKeyPath: XCTestCase {
//
//   public var cancellables: Set<AnyCancellable> = Set()
//
//   func test_common_behavior() {
//
//      let handler = TestHandler()
//      let events: [TestEvent<String>] = [
//         .value("a", at: 0),
//         .value("b", at: 1),
//         .success(at: 2)
//      ]
//      let upstream = handler.publisher(absolute: true, events: events)
//      let connectable = Publishers.MakeConnectable(upstream: upstream)
//      connectable.
////      let autoconnect = Publishers.Autoconnect(upstream: connectable)
////      let results0 = handler.test(connectable)
////      let results1 = handler.test(autoconnect)
////      print(results1)
//      let exp = XCTestExpectation()
////      let handler = TestHandler()
////      Timer
////         .publish(every: 1, on: .main, in: .default)
//////         .autoconnect()
////         .sink { date in
////            print ("Date now: \(date)")
////         }
////         .store(in: &cancellables)
//      wait(for: [exp], timeout: 1)
////      let events: [TestEvent<String>] = [
////         .value("a", at: 0),
////         .value("b", at: 1),
////         .success(at: 2)
////      ]
////      let upstream = handler.publisher(events: events)
////      let publisher = Publishers.Autoconnect(upstream: upstream)
////      let completion = publisher.success(at: max)
////      let results = handler.test(publisher, completion: completion)
////      XCTAssertEqual(results.values, [true])
////      XCTAssertEqual(results.times, [max])
//   }
//}
