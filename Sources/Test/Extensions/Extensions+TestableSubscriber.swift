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

   var isCompleted: Bool {
      return values.last?.signal.isCompletion ?? false
   }

   var isSubscribed: Bool {
      return values.first?.signal.isSubscription ?? false
   }
}
