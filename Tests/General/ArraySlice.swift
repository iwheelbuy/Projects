import DependenciesTest
/*
 
 */
final class ArraySlice: XCTestCase {

   func test_array_slice_operates_within_initial_array_indexes() {
      let array = ["a", "b", "c", "d", "e", "f", "g", "h"]
      let slice0 = array.suffix(from: 2)
      XCTAssertEqual(slice0, ["c", "d", "e", "f", "g", "h"])
      let slice1 = slice0.prefix(through: 6)
      XCTAssertEqual(slice1, ["c", "d", "e", "f", "g"])
      XCTAssertEqual(slice1.firstIndex(where: { $0 >= "e" }), 4)
   }
}
