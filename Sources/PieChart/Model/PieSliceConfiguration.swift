import Foundation
import SwiftUI

/// The configuration for each slice of the pie chart.
public struct PieSliceConfiguration: Identifiable {

    public enum Fill {
        case color(Color)
        case other(AnyShapeStyle)
    }

    public let id: UUID

    public var title: String

    public var fill: Fill
    
    public var shapeFill: AnyShapeStyle {
        switch self.fill {
            case .color(let color):
                return AnyShapeStyle(color)
            case .other(let other):
                return other
        }
    }
    
    /// The numerical quantity represented by this slice of the pie chart.
    public var amount: CGFloat

    public var label: AnyView
    
    public init<Label: View, Fill: ShapeStyle>(
        id: UUID = UUID(),
        title: String,
        fill: Fill,
        amount: CGFloat,
        @ViewBuilder label: () -> Label
    ) {
        
        self.id = id
        self.title = title
        if let color = fill as? Color {
            self.fill = .color(color)
        }
        else {
            self.fill = .other(AnyShapeStyle(fill))
        }
        self.amount = amount
        self.label = AnyView(label())
    }
    
    public init<Fill: ShapeStyle>(
        id: UUID = UUID(),
        title: String,
        fill: Fill,
        amount: CGFloat
    ) {
        self.init(
            id: id,
            title: title,
            fill: fill,
            amount: amount,
            label: { Text(title) }
        )
    }

}

//extension PieSliceConfiguration: Hashable {
//
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        switch (lhs.fill, rhs.fill) {
//            case (.color(let color), .color(let otherColor)):
//                if color != otherColor {
//                    return false
//                }
//            case (.color(_), .other(_)), (.other(_), .color(_)):
//                return false
//            case (.other(_), .other(_)):
//                break
//        }
//        
//        return lhs.id == rhs.id && lhs.title == rhs.title &&
//                lhs.amount == rhs.amount
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        if case .color(let color) = self.fill {
//            hasher.combine(color)
//        }
//        hasher.combine(self.id)
//        hasher.combine(self.title)
//        hasher.combine(self.amount)
//    }
//    
//}
