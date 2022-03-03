//
//  SwiftUIView.swift
//  
//
//  Created by Peter Schorn on 2/28/22.
//

import SwiftUI

struct AnnulusSectorView: View, Animatable {
    
    @EnvironmentObject var configuration: PieChartConfiguration

    var startAngle: Angle
    var centralAngle: Angle
    var innerRadius: CGFloat
    var outerDiameterScale: CGFloat
    
    let slice: PieSliceConfiguration

    var animatableData: AnimatablePair<
        AnimatablePair<Double, Double>,
        AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                AnimatablePair(
                    self.startAngle.radians,
                    self.centralAngle.radians
                ),
                AnimatablePair(
                    self.innerRadius,
                    self.outerDiameterScale
                )
            )
        }
        set {
//            print("AnnulusSectorView.animatableData:setter")
            self.startAngle = .radians(newValue.first.first)
            self.centralAngle = .radians(newValue.first.second)
            self.innerRadius = newValue.second.first
            self.outerDiameterScale = newValue.second.second
        }
    }

    var body: some View {
        AnnulusSector(
            startAngle: startAngle,
            delta: centralAngle,
            innerRadius: innerRadius
        )
        .scaleOuterDiameter(
            by: outerDiameterScale
//                    by: debugOuterDiameterScale
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
        .fill(slice.shapeFill)
        .if(configuration.highlightBehavior == .tap) { view in
            view.onTapGesture(perform: didTap)
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
    
}
