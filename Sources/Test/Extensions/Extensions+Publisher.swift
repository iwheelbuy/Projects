import Combine

public extension Publisher where Output: Equatable {

   func failure(_ failure: TestError, at time: Int) -> TestEvent<Output> {
      return TestEvent<Output>(case: .failure(failure), time: time)
   }

   func success(at time: Int) -> TestEvent<Output> {
      return TestEvent<Output>(case: .success, time: time)
   }
}
