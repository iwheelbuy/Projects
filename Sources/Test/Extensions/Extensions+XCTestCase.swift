import XCTest

public extension XCTestCase {

   private static let timer: [Int] = {
      var set = Set<Int>()
      while set.count < 100 {
         let time = Int(100 + arc4random_uniform(4900))
         set.insert(time)
      }
      return set.sorted()
   }()

   var timer: [Int] {
      return Self.timer
   }
}
