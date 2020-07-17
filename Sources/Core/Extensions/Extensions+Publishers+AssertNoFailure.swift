import Combine

public extension Publishers.AssertNoFailure {

   init(message: String = "iWheelBuy", upstream: Upstream, file: StaticString = #file, line: UInt = #line) {
      self = Publishers.AssertNoFailure(upstream: upstream, prefix: message, file: file, line: line)
   }
}
