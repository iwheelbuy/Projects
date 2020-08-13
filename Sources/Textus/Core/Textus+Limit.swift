import UIKit

extension Textus {

    struct Limit: Hashable {

        let height: CGFloat
        let lines: Int

        init(height: CGFloat = Textus.Crop.height, lines: Int = Textus.Crop.lines) {
            self.height = height > 0 ? height : Textus.Crop.height
            self.lines = lines > 0 ? lines : Textus.Crop.lines
        }
    }
}
