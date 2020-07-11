import Foundation

public protocol TestResultRepresentable {
   
   associatedtype V: Equatable

   var time: Int { get }
   var value: V { get }
}
