import Foundation

public extension Thread {

   static var isNonMainThread: Bool {
      return isMainThread == false
   }

   static var name: String? {
      return String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
   }
}
