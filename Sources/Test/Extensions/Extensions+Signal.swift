import Entwine

public extension Entwine.Signal {

   var failure: Failure? {
      switch self {
      case .completion(let completion):
         switch completion {
         case .failure(let failure):
            return failure
         default:
            return nil
         }
      default:
         return nil
      }
   }

   var input: Input? {
      switch self {
      case .input(let input):
         return input
      default:
         return nil
      }
   }
   
   var isFailure: Bool {
      switch self {
      case .completion(let completion):
         switch completion {
         case .failure:
            return true
         default:
            return false
         }
      default:
         return false
      }
   }

   var isFinished: Bool {
      switch self {
      case .completion(let completion):
         switch completion {
         case .finished:
            return true
         default:
            return false
         }
      default:
         return false
      }
   }

   var isInput: Bool {
      switch self {
      case .input:
         return true
      default:
         return false
      }
   }

   var isSubscription: Bool {
      switch self {
      case .subscription:
         return true
      default:
         return false
      }
   }
}
