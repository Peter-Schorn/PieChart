import SwiftUI

struct PieChartView<Center: View>: View {

    @ObservedObject var configuration: PieChartConfiguration

    let center: () -> Center

    init(
        configuration: PieChartConfiguration,
        @ViewBuilder center: @escaping () -> Center
    ) {
//        print("PieChartView.init")
        self.configuration = configuration
        self.center = center
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                center()
                    .frame(
                        maxWidth: innerDiameter(geometry),
                        maxHeight: innerDiameter(geometry)
                    )
                    .clipShape(Circle())
                
                ForEach(configuration.slices.indices, id: \.self) { index in
                    PieSliceView(
                        index: index
                    )
                }
                
//                Rectangle()
//                    .fill(.green.opacity(0.5))
//                    .frame(width: 2, height: geometry.size.height)
//
//                Rectangle()
//                    .fill(.green.opacity(0.5))
//                    .frame(width: geometry.size.width, height: 2)

//                Rectangle()
//                    .scale(configuration.scaleMultiplier)
//                    .stroke(.green.opacity(0.5), lineWidth: 2)
                
            }
            .if(configuration.highlightBehavior == .mouseHover) { view in
                view.handleMouseEvents(
                    viewAccessor: { view in
                        self.configuration.mouseEventHandlerView = view
                    },
                    mouseMoved: configuration.mouseMoved(event:view:),
                    mouseExited: configuration.mouseExited(event:view:)
                )
            }
            

        }
        .aspectRatio(1, contentMode: .fit)
        .border(Color.green, width: 2)
        .environmentObject(configuration)

    }
    
    func innerDiameter(_ geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .local)
        let minDimension = min(frame.width, frame.height)
        return minDimension * self.configuration.scaledInnerRadius
    }

}
