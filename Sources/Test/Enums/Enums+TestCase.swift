import Foundation

public enum TestCase<V>: Equatable where V: Equatable {

   case failure(TestError)
   case subscription
   case success
   case value(V)

   public var failure: TestError? {
      switch self {
      case .failure(let failure):
         return failure
      default:
         return nil
      }
   }

   public var value: V? {
      switch self {
      case .value(let value):
         return value
      default:
         return nil
      }
   }

   public var isFailure: Bool {
      switch self {
      case .failure:
         return true
      default:
         return false
      }
   }

   public var isSubscription: Bool {
      switch self {
      case .subscription:
         return true
      default:
         return false
      }
   }

   public var isSuccess: Bool {
      switch self {
      case .success:
         return true
      default:
         return false
      }
   }

   public var isValue: Bool {
      switch self {
      case .value:
         return true
      default:
         return false
      }
   }
}
