import SwiftUI

public struct PieChartView<Center: View>: View {

    @ObservedObject var configuration: PieChartConfiguration

    let center: () -> Center

    public init(
        configuration: PieChartConfiguration,
        @ViewBuilder center: @escaping () -> Center
    ) {
//        print("PieChartView.init")
        self.configuration = configuration
        self.center = center
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                center()
                    .frame(
                        maxWidth: innerDiameter(geometry),
                        maxHeight: innerDiameter(geometry)
                    )
                    .clipShape(Circle())
                    .position(geometry.frame(in: .local).center)
                
                ForEach(configuration.slices) { slice in
                    if let index = configuration.slices.firstIndex(
                        where: { $0.id == slice.id }
                    ) {
                        PieSliceView(
                            slice: slice,
                            startAngle: configuration.startAngles[index],
                            centralAngle: configuration.centralAngles[index]
                        )
                    }
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
            #if os(macOS)
            .if(configuration.highlightBehavior == .mouseHover) { view in
                view.handleMouseEvents(
                    nsViewAccessor: { view in
                        self.configuration.mouseEventHandlerView = view
                    },
                    mouseMoved: configuration.mouseMoved(event:view:),
                    mouseExited: configuration.mouseExited(event:view:),
                    didUpdateTrackingArea: configuration.didUpdateTrackingArea
                )
            }
            #endif
            

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

public extension PieChartView where Center == EmptyView {
    
    init(
        configuration: PieChartConfiguration
    ) {
        self.configuration = configuration
        self.center = EmptyView.init
    }

}
