import XCTest

public extension DispatchQueue {

   static func test(name: String, qos: DispatchQoS = .userInteractive, file: String = #file, line: Int = #line) -> DispatchQueue {
      return DispatchQueue(label: "\(#line)~\(#file)~name~\(name)", qos: qos, attributes: .concurrent)
   }

   var isCurrent: Bool {
      let name = label.components(separatedBy: "~name~").last!
      return Thread.current.name?.contains("~name~\(name)") ?? false
   }
}

public extension Thread {

   var name: String? {
      return String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
   }
}
