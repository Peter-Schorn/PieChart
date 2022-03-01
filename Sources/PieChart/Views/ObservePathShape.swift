import SwiftUI

struct ObservePathShape<S: Shape>: Shape {
    
    var shape: S
    let observePath: (Path) -> Void

    var animatableData: S.AnimatableData {
        get { self.shape.animatableData }
        set { self.shape.animatableData = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let path = self.shape.path(in: rect)
        self.observePath(path)
        return path
    }

}

extension Shape {
    
    func observePath(
        _ action: @escaping (Path) -> Void
    ) -> ObservePathShape<Self> {
        return ObservePathShape(shape: self, observePath: action)
    }

}
