import Entwine
import EntwineTest

public struct TestValue<Input, Failure> where Failure: Swift.Error {

   public let signal: Signal<Input, Failure>
   public let time: VirtualTime

   public var input: Input? {
      return signal.input
   }
}
