import Foundation
import SwiftUI

public struct PieSliceModifier: ViewModifier {
    
    public let startAngle: Angle
    public let centralAngle: Angle
    public let innerRadius: CGFloat
    public let outerDiameterScale: CGFloat

    public let percent: CGFloat
    
    public init(
        startAngle: Angle,
        centralAngle: Angle,
        innerRadius: CGFloat,
        outerDiameterScale: CGFloat,
        percent: CGFloat
    ) {
        self.startAngle = startAngle
        self.centralAngle = centralAngle
        self.innerRadius = innerRadius
        self.outerDiameterScale = outerDiameterScale
        self.percent = percent
    }

    var animatedStartAngle: Angle {
//        let startDelta = self.centralAngle / 2
//        return self.startAngle + startDelta - startDelta * self.percent
        return self.startAngle
    }
    
    var animatedCentralAngle: Angle {
        self.centralAngle * self.percent
    }
    
    public func body(content: Content) -> some View {
        content.clipShape(
            AnnulusSector(
                startAngle: animatedStartAngle,
                delta: animatedCentralAngle,
                innerRadius: innerRadius
            )
            .scaleOuterDiameter(by: outerDiameterScale)
        )
    }

}

public struct PieSliceScaleEffect: ViewModifier {
    
    let startAngle: Angle
    let centralAngle: Angle
    let innerRadius: CGFloat
    let outerDiameterScale: CGFloat
    
    let scale: CGFloat

    public func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: sectorCenter())
    }

    func sectorCenter() -> UnitPoint {
        
        let endAngle = self.startAngle + self.centralAngle
        let middleAngle = (self.startAngle + endAngle) / 2
        
        let innerRadius = self.innerRadius / 2
        let outerRadius = self.outerDiameterScale / 2
        
        let middleRadius = (innerRadius + outerRadius) / 2

        return UnitPoint(
            x: 0.5 + cos(middleAngle.radians) * middleRadius,
            y: 0.5 + sin(middleAngle.radians) * middleRadius
        )

    }

}

public extension AnyTransition {

    static func pieSlice(
        startAngle: Angle,
        centralAngle: Angle,
        innerRadius: CGFloat,
        outerDiameterScale: CGFloat
    ) -> Self {
        Self.modifier(
            active: PieSliceModifier(
                startAngle: startAngle,
                centralAngle: centralAngle,
                innerRadius: innerRadius,
                outerDiameterScale: outerDiameterScale,
                percent: 0
            ),
            identity: PieSliceModifier(
                startAngle: startAngle,
                centralAngle: centralAngle,
                innerRadius: innerRadius,
                outerDiameterScale: outerDiameterScale,
                percent: 1
            )
        )
    }
    
    static func pieSliceScaleEffect(
        startAngle: Angle,
        centralAngle: Angle,
        innerRadius: CGFloat,
        outerDiameterScale: CGFloat
    ) -> Self {
        Self.modifier(
            active: PieSliceScaleEffect(
                startAngle: startAngle,
                centralAngle: centralAngle,
                innerRadius: innerRadius,
                outerDiameterScale: outerDiameterScale,
                scale: 0
            ),
            identity: PieSliceScaleEffect(
                startAngle: startAngle,
                centralAngle: centralAngle,
                innerRadius: innerRadius,
                outerDiameterScale: outerDiameterScale,
                scale: 1
            )
        )
    }

}
