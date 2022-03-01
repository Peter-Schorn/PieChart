import Foundation
import SwiftUI
import AppKit
import Combine

/// https://stackoverflow.com/a/61155272/12394554
struct MouseEventHandlerView: NSViewRepresentable {

    class MoustEventHandlerNSView: NSView {
        
        let mouseMoved: (NSEvent, NSView) -> Void
        let mouseExited: (NSEvent, NSView) -> Void
        let didUpdateTrackingArea: () -> Void
    
        init(
            mouseMoved: @escaping (NSEvent, NSView) -> Void,
            mouseExited: @escaping (NSEvent, NSView) -> Void,
            didUpdateTrackingArea: @escaping () -> Void
        ) {
            self.mouseMoved = mouseMoved
            self.mouseExited = mouseExited
            self.didUpdateTrackingArea = didUpdateTrackingArea
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // SwiftUI uses a flipped coordinate system
        override var isFlipped: Bool { true }

        var mouseLocation: CGPoint? {
            guard let windowLocation =
                    self.window?.mouseLocationOutsideOfEventStream else {
                return nil
            }
            let location = self.convert(windowLocation, from: nil)
            return location
        }
        
        override func mouseEntered(with event: NSEvent) {
            self.mouseMoved(event, self)
        }

        override func mouseMoved(with event: NSEvent) {
            self.mouseMoved(event, self)
        }

        override func mouseExited(with event: NSEvent) {
            self.mouseExited(event, self)
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            self.updateTrackingAreas()
        }
        
        override func updateTrackingAreas() {
            
//            print("updateTrackingAreas")

            super.updateTrackingAreas()
            
            for trackingArea in self.trackingAreas {
                self.removeTrackingArea(trackingArea)
            }
            
            let trackingArea = NSTrackingArea(
                rect: self.bounds,
                options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited],
                owner: self
            )
            self.addTrackingArea(trackingArea)
            self.didUpdateTrackingArea()
            
        }

    }

    let viewAccessor: (MouseEventHandlerView.MoustEventHandlerNSView) -> Void
    let mouseMoved: (NSEvent, NSView) -> Void
    let mouseExited: (NSEvent, NSView) -> Void

    /// Indicates the geometry of the view probably changed.
    let didUpdateTrackingArea: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = MoustEventHandlerNSView(
            mouseMoved: self.mouseMoved,
            mouseExited: self.mouseExited,
            didUpdateTrackingArea: didUpdateTrackingArea
            
        )
        self.viewAccessor(view)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        
    }
    
}

extension View {
    
    func handleMouseEvents(
        viewAccessor: @escaping (MouseEventHandlerView.MoustEventHandlerNSView) -> Void,
        mouseMoved: @escaping (NSEvent, NSView) -> Void,
        mouseExited: @escaping (NSEvent, NSView) -> Void,
        didUpdateTrackingArea: @escaping () -> Void
    ) -> some View {
        
        let handler = MouseEventHandlerView(
            viewAccessor: viewAccessor,
            mouseMoved: mouseMoved,
            mouseExited: mouseExited,
            didUpdateTrackingArea: didUpdateTrackingArea
        )

        return self.background {
            handler
        }
    }

}


func systemUptime() -> TimeInterval {
    var currentTime = time_t()
    var bootTime    = timeval()
    var mib         = [CTL_KERN, KERN_BOOTTIME]
    // NOTE: Use strideof(), NOT sizeof() to account for data structure
    // alignment (padding)
    // http://stackoverflow.com/a/27640066
    // https://devforums.apple.com/message/1086617#1086617
    var size = MemoryLayout<timeval>.stride
    let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)
    if result != 0 {
    #if DEBUG
        print("ERROR - \(#file):\(#function) - errno = \(result)")
    #endif
        return 0
    }
    // Since we don't need anything more than second level accuracy, we use
    // time() rather than say gettimeofday(), or something else. uptime
    // command does the same
    time(&currentTime)
    let uptime = currentTime - bootTime.tv_sec
    
    return TimeInterval(uptime)
}
