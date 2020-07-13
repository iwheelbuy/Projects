import XCTest

public extension Thread {

   var label: String {
      return String(cString: __dispatch_queue_get_label(nil), encoding: .utf8) ?? ""
   }
}
