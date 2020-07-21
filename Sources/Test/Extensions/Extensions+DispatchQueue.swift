import XCTest

public extension DispatchQueue {

   static func test(concurrent: Bool = true, name: String, qos: DispatchQoS = .userInteractive, file: String = #file, line: Int = #line) -> DispatchQueue {
      return DispatchQueue(
         label: "\(#line)~\(#file)~name~\(name)",
         qos: qos,
         attributes: concurrent ? .concurrent : []
      )
   }

   var isCurrent: Bool {
      let components = label.components(separatedBy: "~name~")
      guard components.count == 2, let name = components.last else {
         return false
      }
      return Thread.current.label.contains("~name~\(name)")
   }
}
