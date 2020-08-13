//import DependenciesTest
///*
//
// */
//final class Buffer: XCTestCase {
//
//   func test_common_behavior() {
//      let exp = XCTestExpectation()
//      var cancellables: Set<AnyCancellable> = Set()
//      let scheduler = DispatchQueue.test(name: "a")
//      let subject = PassthroughSubject<Int, Never>()
//      let publisher = Publishers.Buffer(
//         upstream: subject,
//         size: 5,
//         prefetch: .keepFull,
//         whenFull: .dropOldest
//      )
//      let shared = Publishers.MakeConnectable(upstream: publisher).share()
//      scheduler.asyncAfter(deadline: .now() + 0.1) {
//         shared
//            .handleEvents(receiveSubscription: { _ in
//               print("nice")
//            })
//            .sink(receiveValue: { value in
//               print("~>", value)
//            })
//            .store(in: &cancellables)
//      }
//      shared
//         .handleEvents(receiveSubscription: { _ in
//            print("good")
//         })
//         .sink(receiveValue: { value in
//            print("<~", value)
//         })
//         .store(in: &cancellables)
//      scheduler.asyncAfter(deadline: .now() + 0.05) {
//         for value in 0 ... 5 {
//            subject.send(value)
//         }
//      }
//      wait(for: [exp], timeout: 1)
////      publisher.
////      let handler = TestHandler()
////      let limit = 100
////      let size = 5
////      let values = Array(0 ..< limit)
////      let events: [TestEvent<Int>] = values
////         .map({ TestEvent(case: .value($0), time: $0) })
////         .appending({ _ in TestEvent<Int>.success(at: limit) })
////      let upstream = handler.publisher(events: events)
////      let publisher = Publishers.Buffer(
////         upstream: upstream,
////         size: size,
////         prefetch: .byRequest,
////         whenFull: .dropNewest
////      )
////      let asdf = Publishers.MakeConnectable(upstream: publisher).autoconnect()
////      let completion = asdf.success(at: limit)
////      let results = handler.test(asdf, completion: completion)
////      XCTAssertEqual(results.values, [9, 10])
////      XCTAssertEqual(results.times, [0, 1])
//   }
//}
