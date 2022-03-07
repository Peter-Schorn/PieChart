import SwiftUI

/**
 The region between two concentric arcs with the same start and end angles.
 
 https://math.stackexchange.com/q/3028602/825630
 */
public struct AnnulusSector: InsettableShape {
    
    /// The start angle on a unit circle of the arcs that define this shape.
    var startAngle: Angle

    /**
     The central angle of the sector.

     If positive, then the arc will be spanned clockwise fxrom `startAngle`.
     If negative, then the arc will be spanned counterclockwise from
     `startAngle`.
     */
    var delta: Angle
    
    /**
     The inner radius of the shape.

     A relative value in the interval `[0, 1)`. Multiplied by half the length
     of the smallest dimension of the frame.
     */
    var innerRadius: CGFloat

    var inset: CGFloat = 0

    var outerDiameterScale: CGFloat = 1

    public var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        AnimatablePair<
            CGFloat,
            AnimatablePair<CGFloat, CGFloat>
        >
    > {
        get {
            AnimatablePair(
                AnimatablePair(
                    self.innerRadius,
                    self.outerDiameterScale
                ),
                AnimatablePair(
                    self.startAngle.radians,
                    AnimatablePair(
                        self.delta.radians,
                        self.inset
                    )
                )
            )
        }
        set {
            self.innerRadius = newValue.first.first
            self.outerDiameterScale = newValue.first.second
            self.startAngle = .radians(newValue.second.first)
            self.delta = .radians(newValue.second.second.first)
            self.inset = newValue.second.second.second
        }
    }

    public init(
        startAngle: Angle,
        delta: Angle,
        innerRadius: CGFloat
    ) {
        self.startAngle = startAngle
        self.delta = delta
        self.innerRadius = innerRadius
    }

    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.inset += amount
        return shape
    }

    public func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: self.inset, dy: self.inset)
        let squareRect = insetRect.croppedToSquare()
        return self.pathInRectCore(squareRect)
    }
    
    /**
     Returns a new version of this shape with the outer diameter scaled by the
     given amount.
     
     The inner arc of this shape will remain in the same position, which means
     the thickness (the difference between the inner and outer radius) of the
     shape will change.
     
     The bounding frame will not change.
     
     - Parameter amount: The amount to scale the outer diameter by relative to
           the size of the frame.
     */
    public func scaleOuterDiameter(by amount: CGFloat) -> AnnulusSector {
        var copy = self
        // ensure this method can be applied multiple times with the expected
        // result
        copy.outerDiameterScale *= amount
        return copy
    }
    
    /// The rect is already inset and cropped to a square.
    func pathInRectCore(_ rect: CGRect) -> Path {
        
//        print("pathInRectCore")

        var path = Path()
        
        if self.delta == .zero {
            return path
        }

        let outerDiameter = rect.width
        let scaledOuterDiameter = outerDiameter * self.outerDiameterScale

        let outerRadius = outerDiameter / 2
        let scaledOuterRadius = scaledOuterDiameter / 2
        
        let innerRadius = outerRadius * self.innerRadius

        if innerRadius == scaledOuterRadius {
            return path
        }

        let endAngle = self.startAngle + delta

        // from inner start point to inner end point
        path.addRelativeArc(
            center: rect.center,
            radius: innerRadius,
            startAngle: self.startAngle,
            delta: self.delta
        )
        
        let outerEndpoint = CGPoint(
            x: rect.midX + cos(endAngle.radians) * scaledOuterRadius,
            y: rect.midY + sin(endAngle.radians) * scaledOuterRadius
        )
        
        path.addLine(to: outerEndpoint)
        
        // from outer end point to outer start point
        path.addRelativeArc(
            center: rect.center,
            radius: scaledOuterRadius,
            startAngle: endAngle,
            delta: -self.delta
        )
        
        path.closeSubpath()

        return path

    }

}

struct AnnulusSector_Previews: PreviewProvider {

    static let scale: CGFloat = 1.5

    static var previews: some View {
        GeometryReader { geometry in
            ZStack {
                
                AnnulusSector(
                    startAngle: .degrees(-30),
                    delta: .degrees(270),
                    innerRadius: 0.5
                )
                .fill(Color.red.opacity(0.5))
                
//                AnnulusSector(
//                    startAngle: .degrees(-45),
//                    delta: .degrees(270),
//                    innerRadius: 0.5
//                )
//                .scaleOuterDiameter(by: scale)
//                .fill(Color.blue.opacity(0.5))

                Rectangle()
                    .fill(Color.green.opacity(0.25))
                    .frame(
                        width: 2,
                        height: geometry.size.height
                    )
                Rectangle()
                    .fill(Color.green.opacity(0.25))
                    .frame(
                        width: geometry.size.width,
                        height: 2
                    )
                
            }
        }
        .frame(width: 300, height: 300)
        .padding(2)
        .border(Color.green, width: 2)
        .padding(100)
        .background()
        .preferredColorScheme(.light)

    }
}
