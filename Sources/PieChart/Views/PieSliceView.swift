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

    let animation = Animation.easeInOut(duration: 0.2)

    let index: Int

    var slice: PieSliceConfiguration {
        self.configuration.slices[index]
    }
    
    var startAngle: Angle {
        self.configuration.startAngles[index]
    }
    var centralAngle: Angle {
        self.configuration.centralAngles[index]
    }

    init(
        index: Int
    ) {
        self.index = index
    }

    var body: some View {
//        let _ = Self._printChanges()
        GeometryReader { geometry in
            ZStack {
                AnnulusSector(
                    startAngle: startAngle,
                    delta: centralAngle,
                    innerRadius: configuration.scaledInnerRadius
                )
                .scaleOuterDiameter(
                    by: isHighlighted ? 1 : configuration.scaleMultiplier
                )
                .observePath { path in
                    
                    var paths = self.configuration.paths
                    paths[slice.id] = path

                    // @Published publishes a change every time the setter is
                    // called, even if the new value is the same as the old
                    // value.
                    if paths != self.configuration.paths {
                        self.configuration.paths = paths
                        
                        // even if the mouse hasn't moved, the path may have,
                        // which might change which path the mouse is inside of
                        self.configuration.updateHighlighedSlice()
                    }

                }
                .fill(slice.fill)
                .if(configuration.highlightBehavior == .tap) { view in
                    view.onTapGesture(perform: didTap)
                }

                slice.label
                    .modifier(
                        radialOffset(geometry)
                    )
                
            }
        }
        .onChange(of: configuration.highlightedSlice) { highlightedSlice in
            withAnimation(self.animation) {
                self.isHighlighted = highlightedSlice == self.slice.id
            }
        }
        
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
        var length = frame.width

        if !isHighlighted {
            length *= self.configuration.scaleMultiplier
        }

        let endAngle = self.startAngle + self.centralAngle
        let middleAngle = (endAngle + self.startAngle) / 2
        
        let outerRadius = length / 2
        
        var innerRadius = outerRadius * self.configuration.scaledInnerRadius
        
        if !isHighlighted {
            innerRadius /= self.configuration.scaleMultiplier
        }
        
        let middleRadius = (innerRadius + outerRadius) / 2
        
        return RadialOffsetEffect(
            radius: middleRadius,
            angle: middleAngle
        )

    }
    
}
