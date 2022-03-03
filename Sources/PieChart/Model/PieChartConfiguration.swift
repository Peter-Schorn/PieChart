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
//            print("didSet PieChartConfiguration.slices")
            self.slicesDidChange()
        }
    }
    
    public let linearAnimation = Animation.linear(duration: 2)

    @Published public var animationPercent: CGFloat = 0

    @Published public var highlightBehavior: HighlightBehavior


    /// The paths of all the pice slice shapes.
    @Published public internal(set) var paths:
            [PieSliceConfiguration.ID: Path] = [:]
    
    /// The currently highlighted slice.
    @Published public var highlightedSlice: PieSliceConfiguration.ID? = nil

    /// The inner radius of the pie chart as a proportion of the size of the
    /// frame.
    @Published public var innerRadius: CGFloat
    
    var scaledInnerRadius: CGFloat {
        self.innerRadius * self.outerDiameterScale
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
//    public private(set) var middleAngles: [Angle] = []
    public private(set) var centralAngles: [Angle] = []

    @Published public var debugOuterDiameterScale: CGFloat = 0.9

    /// The amount by which to scale the outer diameter of unhighlighted slices.
    let outerDiameterScale: CGFloat = 0.95
    
    var mouseEventHandlerView: MouseEventHandlerView.MoustEventHandlerNSView? = nil

    var cancellables: Set<AnyCancellable> = []

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
        self.debugStuff()
    }

    func slicesDidChange() {
        self.totalAmount = slices.reduce(0, { $0 + $1.amount })
        
        var startAngles: [Angle] = []
        var centralAngles: [Angle] = []

//        var partialAngleSum = Angle.zero
        var partialAngleSum = self.rotation

        for slice in slices {
            startAngles.append(partialAngleSum)
            let percent = slice.amount / totalAmount
            let centralAngle = Angle.radians(percent * 2 * Double.pi)
            centralAngles.append(centralAngle)
//            let middleAngle = partialAngleSum + centralAngle / 2
//            self.middleAngles.append(middleAngle)
            partialAngleSum += centralAngle
        }

//        withAnimation {
            self.startAngles = startAngles
            self.centralAngles = centralAngles
            self.updateHighlighedSlice()
//        }
        self.objectWillChange.send()

    }
    
    // MARK: Mouse Hover
    
    #if os(macOS)
    
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
        
        var highlightedSlice: PieSliceConfiguration.ID? = nil

        guard let nsView = self.mouseEventHandlerView else {
            return
        }

        // "Point-in-rectangle functions generally assume that the bottom edge
        // of a rectangle is outside of the rectangle boundaries"
        let frame = nsView.frame.insetBy(dx: -2, dy: -2)
        
        if nsView.isMousePoint(mouseLocation, in: frame) {
            for (id, path) in self.paths {
                if path.contains(mouseLocation) {
                    highlightedSlice = id
                    break
                }
                
            }
        }

        // @Published publishes a change every time the setter is called, even
        // if the new value is the same as the old value.
        if self.highlightedSlice != highlightedSlice {
//            print("change highlighted slice")
//            DispatchQueue.main.async {
                self.highlightedSlice = highlightedSlice
//            }
        }

    }

    /// Based on the current mouse location.
    func updateHighlighedSlice() {
        
        guard self.highlightBehavior == .mouseHover else {
            return
        }

        guard let location = self.mouseEventHandlerView?.mouseLocation else {
//            print("couldn't get current mouse location")
            return
        }
//        print("current mouse location: \(location)")
        self.updateHighlightedSlice(mouseLocation: location)
    }

    func didUpdateTrackingArea() {
        self.updateHighlighedSlice()
    }

    #endif  // #if os(macOS)
    
    func debugStuff() {
//        Timer.publish(every: 0.5, on: .main, in: .common)
//            .autoconnect()
//            .sink { date in
//                print("------------------------------------------")
//            }
//            .store(in: &self.cancellables)
    }

}
