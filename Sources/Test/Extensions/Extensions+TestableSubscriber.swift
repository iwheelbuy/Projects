import EntwineTest

public extension EntwineTest.TestableSubscriber {

   var values: [TestValue<Input, Failure>] {
      return recordedOutput
         .map({ values -> TestValue<Input, Failure> in
            let signal = values.1
            let time = values.0
            return TestValue(signal: signal, time: time)
         })
   }

   var inputs: [Input] {
      return values.compactMap({ $0.input })
   }

   func completed(time: VirtualTime? = nil) -> Bool {
      guard let value = values.last else {
         return false
      }
      if let time = time, time != value.time {
         return false
      }
      return value.signal.isCompletion
   }

   func failed(time: VirtualTime? = nil) -> Bool {
      guard let value = values.last else {
         return false
      }
      if let time = time, time != value.time {
         return false
      }
      return value.signal.isFailure
   }

   func subscribed(time: VirtualTime? = nil) -> Bool {
      guard let value = values.first else {
         return false
      }
      if let time = time, time != value.time {
         return false
      }
      return value.signal.isSubscription
   }
}

public extension EntwineTest.TestableSubscriber where Failure: Equatable {

   func failed(failure: Failure, time: VirtualTime? = nil) -> Bool {
      guard let value = values.last else {
         return false
      }
      if let time = time, time != value.time {
         return false
      }
      return value.signal.failure == failure
   }
}
