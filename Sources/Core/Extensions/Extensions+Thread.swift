import Foundation

public extension Thread {

   static var isNonMainThread: Bool {
      return isMainThread == false
   }
}
