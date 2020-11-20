import DependenciesTest
/*
 
 */
final class ArraySlice: XCTestCase {

   func test_array_slice_operates_within_initial_array_indexes() {
      let array = ["0", "1", "2", "3", "4", "5", "6", "7"]
      XCTAssertEqual(
         array.suffix(from: 2),
         ["2", "3", "4", "5", "6", "7"]
      )
      XCTAssertEqual(
         array.suffix(from: 2).prefix(through: 6),
         ["2", "3", "4", "5", "6"]
      )
      XCTAssertEqual(
         array.suffix(from: 2).prefix(upTo: 6),
         ["2", "3", "4", "5"]
      )
      XCTAssertEqual(
         array.suffix(from: 2).prefix(through: 6).firstIndex(where: { $0 >= "4" }),
         4
      )
   }
}
