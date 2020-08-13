import Foundation

extension NSRange {

    var last: Int {
        return location + length - 1
    }

    var next: Int {
        return location + length
    }
}
