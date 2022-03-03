//
//  PieSliceView.swift
//  PieChart
//
//  Created by Peter Schorn on 2/24/22.
//

import SwiftUI

struct PieSliceView: View {

    @EnvironmentObject var configuration: PieChartConfiguration

    @State private var isHighlighted = false

    // transition
    @State private var animationPercent: CGFloat = 0

//    var animationPercent: CGFloat {
//        get {
//            self.configuration.animationPercent
//        }
//        nonmutating set {
//            self.configuration.animationPercent = newValue
//        }
//    }

    let linearAnimation = Animation.linear(duration: 2)

    let slice: PieSliceConfiguration
    let startAngle: Angle
    let centralAngle: Angle

    init(
        slice: PieSliceConfiguration,
        startAngle: Angle,
        centralAngle: Angle
    ) {
        self.slice = slice
        self.startAngle = startAngle
        self.centralAngle = centralAngle
    }

    var outerDiameterScale: CGFloat {
        self.isHighlighted ? 1 : self.configuration.outerDiameterScale
    }

    // MARK: Reversed

    var reversedStartAngle: Angle {
        let result = self.startAngle + self.centralAngle
//        print("start angle: \(result.degrees)")
        return result
    }
    
    var reversedCentralAngle: Angle {
        -self.centralAngle
    }
    
    // MARK: Animated

    var animatedStartAngle: Angle {
//        let startDelta = self.centralAngle / 2
//
//        return self.startAngle + startDelta - startDelta * self.animationPercent
        return self.reversedStartAngle
//        self.startAngle
    }
    
    var animatedCentralAngle: Angle {
        self.reversedCentralAngle * self.animationPercent
    }

    var body: some View {
//        let _ = Self._printChanges()
        GeometryReader { geometry in
            ZStack {
                AnnulusSector(
                    startAngle: animatedStartAngle,
                    delta: animatedCentralAngle,
                    innerRadius: configuration.scaledInnerRadius
                )
                .scaleOuterDiameter(
                    by: outerDiameterScale
                )
                .observePath { path in

                    var paths = self.configuration.paths
                    paths[slice.id] = path

                    // @Published publishes a change every time the
                    // setter is called, even if the new value is the
                    // same as the old value.
                    if paths != self.configuration.paths {
//                        DispatchQueue.main.async {
                            self.configuration.paths = paths
                            
                            // even if the mouse hasn't moved, the path may
                            // have, which might change which path the mouse
                            // is inside of
                            self.configuration.updateHighlighedSlice()
//                        }
                    }

                }
                .fill(slice.shapeFill)
                .if(configuration.highlightBehavior == .tap) { view in
                    view.onTapGesture(perform: didTap)
                }
                .onAppear {
                    withAnimation(self.linearAnimation) {
                        self.animationPercent = 1
                    }
                }
            
                slice.label
                    .modifier(radialOffset(geometry))
                
            }
        }
        .onChange(of: configuration.highlightedSlice) { highlightedSlice in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isHighlighted = highlightedSlice == self.slice.id
            }
        }
        .transition(.identity)
        .id(slice.id)
    }
    
    func didTap() {
        let id = self.slice.id
//        print("tapped \(title)")
        
        if self.configuration.highlightedSlice == id {
            self.configuration.highlightedSlice = nil
        }
        else {
            self.configuration.highlightedSlice = id
        }
    }
    
    func radialOffset(_ geometry: GeometryProxy) -> RadialOffsetEffect {
        
        let frame = geometry.frame(in: .local)
            
        // the frame is always square
        let length = frame.width * self.configuration.outerDiameterScale

        let endAngle = self.animatedStartAngle + self.animatedCentralAngle
        let middleAngle = (endAngle + self.animatedStartAngle) / 2
        
        let outerRadius = length / 2
        
        let innerRadius = (outerRadius * self.configuration.scaledInnerRadius) /
                self.configuration.outerDiameterScale
        
        let middleRadius = (innerRadius + outerRadius) / 2
        
        return RadialOffsetEffect(
            radius: middleRadius,
            angle: middleAngle
        )

    }
    
}

struct PieSliceModifier: ViewModifier {
    
    let annulusSector: AnnulusSector
    let fill: AnyShapeStyle

    let percent: CGFloat
    
    func body(content: Content) -> some View {
        let delta = self.annulusSector.delta * percent
        AnnulusSector(
            startAngle: self.annulusSector.startAngle,
            delta: delta,
            innerRadius: self.annulusSector.innerRadius
        )
        .fill(self.fill)
    }

}

extension AnyTransition {
    
    static func pieSlice(
        _ shape: AnnulusSector,
        fill: AnyShapeStyle
    ) -> Self {
        Self.modifier(
            active: PieSliceModifier(
                annulusSector: shape,
                fill: fill,
                percent: 0
            ),
            identity: PieSliceModifier(
                annulusSector: shape,
                fill: fill,
                percent: 1
            )
        )
    }

}
