import Foundation
import SwiftUI

extension CGRect {
    
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
    func croppedToSquare() -> CGRect {
        
        if self.width == self.height {
            return self
        }
        
        else {
            let smallestDimension = min(self.width, self.height)
            
            return CGRect(
                x: self.minX + (self.width - smallestDimension) / 2,
                y: self.minY + (self.height - smallestDimension) / 2,
                width: smallestDimension,
                height: smallestDimension
            )
        }
    }
    
}

extension View {
    
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
    
    @ViewBuilder func `if`<TrueContent: View>(
        _ condition: Bool,
        then trueContent: (Self) -> TrueContent
    ) -> some View {
        if condition {
            trueContent(self)
        } else {
            self
        }
    }

    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueContent: (Self) -> TrueContent,
        else falseContent: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueContent(self)
        } else {
            falseContent(self)
        }
    }
    
    @ViewBuilder func ifLet<T, Content: View>(
        _ t: T?, _ content: (Self, T) -> Content
    ) -> some View {
        if let t = t {
            content(self, t)
        }
        else {
            self
        }
    }

}

extension CGFloat.NativeType {
    
    var wholePercent: String {
        self.formatted(.percent.precision(.fractionLength(0)))
    }

}

extension NumberFormatter {
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

}

extension NSEvent.EventType: CustomStringConvertible {
    
    public var description: String {
        switch self {
            case .leftMouseDown:
                return "leftMouseDown"
            case .leftMouseUp:
                return "leftMouseUp"
            case .rightMouseDown:
                return "rightMouseDown"
            case .rightMouseUp:
                return "rightMouseUp"
            case .mouseMoved:
                return "mouseMoved"
            case .leftMouseDragged:
                return "leftMouseDragged"
            case .rightMouseDragged:
                return "rightMouseDragged"
            case .mouseEntered:
                return "mouseEntered"
            case .mouseExited:
                return "mouseExited"
            default:
                return "other"
        }
    }

}

extension Collection {
    
    subscript(safe index: Index) -> Element? {
        if self.indices.contains(index) {
            return self[index]
        }
        return nil
    }

}
