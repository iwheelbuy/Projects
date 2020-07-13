import Combine

public extension Publisher {

   func subscribe() -> AnyCancellable {
      return sink(receiveCompletion: { _ in }, receiveValue: { _ in })
   }
}
