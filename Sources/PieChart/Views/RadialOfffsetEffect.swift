import Foundation
import SwiftUI

/**
 Offsets a view along a circle with a specified radius and angle.

 Specifically designed in order to support animation of the offset
 around this circle.
 */
struct RadialOffsetEffect: GeometryEffect {

    var radius: CGFloat
    
    var angle: Angle
    
    var offset: CGVector {
        CGVector(
            dx: cos(angle.radians) * radius,
            dy: sin(angle.radians) * radius
        )
    }

    var animatableData: AnimatablePair<CGFloat, Double> {
        get {
            return AnimatablePair(self.radius, self.angle.radians)
        }
        set {
            self.radius = newValue.first
            self.angle = .radians(newValue.second)
        }
    }
    

    func effectValue(size: CGSize) -> ProjectionTransform {
//        print("effectValue")
        let offset = self.offset
        let transform = CGAffineTransform(
            translationX: offset.dx,
            y: offset.dy
        )
        return ProjectionTransform(transform)
    }
 
}
