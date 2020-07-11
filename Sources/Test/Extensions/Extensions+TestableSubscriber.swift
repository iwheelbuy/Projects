import EntwineTest

public extension EntwineTest.TestableSubscriber where Failure: Equatable, Input: Equatable {

   var events: [TestEvent<Input>] {
      return recordedOutput
         .map({ (time, signal) -> TestEvent<Input> in
            switch signal {
            case .completion(let completion):
               switch completion {
               case .failure(let failure):
                  if let failure = failure as? TestError {
                     return TestEvent(case: .failure(failure), time: time)
                  } else {
                     return TestEvent(case: .failure(.undefined), time: time)
                  }
               case .finished:
                  return TestEvent(case: .success, time: time)
               }
            case .input(let value):
               return TestEvent(case: .value(value), time: time)
            case .subscription:
               return TestEvent(case: .subscription, time: time)
            }
         })
   }
}
