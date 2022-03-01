import Foundation
import SwiftUI
import Combine

public class PieChartConfiguration: ObservableObject {
    
    public enum HighlightBehavior {
        #if os(macOS)
        /// Highlight a slice when the mouse hovers over it.
        case mouseHover
        #endif
        
        /// Toggle the highlighted state of a slice when it is tapped.
        case tap
    }

    public var slices: [PieSliceConfiguration] = [] {
        didSet {
            self.slicesDidChange()
        }
    }

    @Published var highlightBehavior: HighlightBehavior


    /// The paths of all the pice slice shapes.
    @Published public internal(set) var paths:
            [PieSliceConfiguration.ID: Path] = [:]
    
    /// The currently highlighted slice.
    @Published public var highlightedSlice: String? = nil

    /// The inner radius of the pie chart as a proportion of the size of the
    /// frame.
    @Published public var innerRadius: CGFloat
    
    var scaledInnerRadius: CGFloat {
        self.innerRadius * self.scaleMultiplier
    }

    /// The rotation of the entire pie chart.
    @Published public var rotation: Angle {
        didSet {
            self.slicesDidChange()
        }
    }

    /// The sum of the amount of all of the slices.
    public private(set) var totalAmount: CGFloat = 0

    public private(set) var startAngles: [Angle] = []
    public private(set) var centralAngles: [Angle] = []

    /// The amount by which to scale unhighlighted slices.
    let scaleMultiplier: CGFloat = 0.95
    
    var mouseEventHandlerView: MouseEventHandlerView.MoustEventHandlerNSView? = nil

    public init(
        highlightBehavior: HighlightBehavior? = nil,
        innerRadius: CGFloat = 0.5,
        rotation: Angle = .zero,
        _ slices: [PieSliceConfiguration] = []
    ) {
        if let highlightBehavior = highlightBehavior {
            self.highlightBehavior = highlightBehavior
        }
        else {
            #if os(macOS)
            self.highlightBehavior = .mouseHover
            #else
            self.highlightBehavior = .tap
            #endif
        }
        self.innerRadius = innerRadius
        self.rotation = rotation
        self.slices = slices
        self.slicesDidChange()

    }

    func slicesDidChange() {
        self.totalAmount = slices.reduce(0, { $0 + $1.amount })
        self.startAngles = []
        self.centralAngles = []
    
//        var partialAngleSum = Angle.zero
        var partialAngleSum = self.rotation

        for slice in slices {
            self.startAngles.append(partialAngleSum)
            let percent = slice.amount / totalAmount
            let centralAngle = Angle.radians(percent * 2 * Double.pi)
            self.centralAngles.append(centralAngle)
            partialAngleSum += centralAngle
        }
        self.updateHighlighedSlice()
        self.objectWillChange.send()
    }
    
    func mouseExited(event: NSEvent, view: NSView) {
        guard self.highlightBehavior == .mouseHover else {
            return
        }
        if self.highlightedSlice != nil {
            self.highlightedSlice = nil
        }
    }
    
    func mouseMoved(event: NSEvent, view: NSView) {

        guard self.highlightBehavior == .mouseHover else {
            return
        }

        let location = view.convert(event.locationInWindow, from: nil)
        self.updateHighlightedSlice(mouseLocation: location)

    }
    
    func updateHighlightedSlice(
        mouseLocation: CGPoint
    ) {
        
        var highlightedSlice: String? = nil

        for (id, path) in self.paths {
            if path.contains(mouseLocation) {
                highlightedSlice = id
                break
            }
            
        }

        // @Published publishes a change every time the setter is called, even
        // if the new value is the same as the old value.
        if self.highlightedSlice != highlightedSlice {
//            print("change highlighted slice")
            self.highlightedSlice = highlightedSlice
        }

    }

    /// Based on the current mouse location.
    func updateHighlighedSlice() {
        guard let location = self.mouseEventHandlerView?.mouseLocation else {
//            print("couldn't get current mouse location")
            return
        }
//        print("current mouse location: \(location)")
        self.updateHighlightedSlice(mouseLocation: location)
    }

}
