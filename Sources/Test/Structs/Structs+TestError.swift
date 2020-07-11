import Foundation

public enum TestError: Error, Hashable {

   case custom(AnyHashable)
   case `default`
   case thrown
   case undefined
}
