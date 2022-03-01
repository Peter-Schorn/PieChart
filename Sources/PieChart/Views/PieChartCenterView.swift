import SwiftUI

struct PieChartCenterView: View {
    
    @ObservedObject var configuration: PieChartConfiguration

    var highlightedSlice: PieSliceConfiguration? {
        if let title = self.configuration.highlightedSlice {
            return self.configuration.slices.first(
                where: { $0.title == title }
            )
        }
        return nil
    }

    var title: String {
        if let title = self.configuration.highlightedSlice {
            return title
        }
        return "Total"
    }

    var amount: CGFloat {
        if let highlightedSlice = self.highlightedSlice {
            return highlightedSlice.amount
        }
        return self.configuration.totalAmount
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .bold()
                .foregroundColor(.secondary)
            Text(amount, format: .number.precision(.fractionLength(2)))
        }
        .font(.title)
    }

}
