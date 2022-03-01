import Foundation
import SwiftUI

/// The configuration for each slice of the pie chart.
public struct PieSliceConfiguration {

    /// Must be unique among all pie slices in the pie chart.
    public let title: String

    public var fill: AnyShapeStyle
    
    /// The numerical quantity represented by this slice of the pie chart.
    public var amount: CGFloat

    public var label: AnyView
    
    public init<Label: View, Fill: ShapeStyle>(
        title: String,
        fill: Fill,
        amount: CGFloat,
        @ViewBuilder label: () -> Label
    ) {
        self.title = title
        self.fill = AnyShapeStyle(fill)
        self.amount = amount
        self.label = AnyView(label())
    }
    
    public init<Fill: ShapeStyle>(
        title: String,
        fill: Fill,
        amount: CGFloat
    ) {
        self.init(
            title: title,
            fill: fill,
            amount: amount,
            label: { Text(title) }
        )
    }

}

extension PieSliceConfiguration: Identifiable {
    
    public var id: String {
        self.title
    }

}
