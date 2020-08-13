import UIKit

public extension Textus {

   public enum Load: Hashable {

      case other(AnyHashable)
      case part
      case url(URL)

      public var url: URL? {
         switch self {
         case .url(let url):
            return url
         default:
            return nil
         }
      }

      public init?(_ url: URL?) {
         guard let url = url else {
            return nil
         }
         self = .url(url)
      }
   }
}

