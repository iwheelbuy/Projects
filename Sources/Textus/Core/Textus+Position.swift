import UIKit

public extension Textus {
    /// Расположение текста в контейнере
    public enum Position: Hashable {
        /// Текст расположен на *значение* точек вверх от нижней базовой линии
        case bottom(CGFloat)
        /// Текст расположен на *значение* точек вверх от центра строки
        case center(CGFloat)
        /// Текст расположен на *значение* точек вверх от верхней базовой линии
        case top(CGFloat)
    }
}
