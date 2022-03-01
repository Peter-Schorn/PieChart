import Foundation
import SwiftUI
import AppKit
import Combine

/// https://stackoverflow.com/a/61155272/12394554
struct MouseEventHandlerView: NSViewRepresentable {

    class MoustEventHandlerNSView: NSView {
        
        let mouseMoved: (NSEvent, NSView) -> Void
        let mouseExited: (NSEvent, NSView) -> Void
    
        init(
            mouseMoved: @escaping (NSEvent, NSView) -> Void,
            mouseExited: @escaping (NSEvent, NSView) -> Void
        ) {
            self.mouseMoved = mouseMoved
            self.mouseExited = mouseExited
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
            
//            self.wantsLayer = true
//            self.layer?.backgroundColor = CGColor.black

        }

    }

    let viewAccessor: (MouseEventHandlerView.MoustEventHandlerNSView) -> Void
    let mouseMoved: (NSEvent, NSView) -> Void
    let mouseExited: (NSEvent, NSView) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = MoustEventHandlerNSView(
            mouseMoved: self.mouseMoved,
            mouseExited: self.mouseExited
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
        mouseExited: @escaping (NSEvent, NSView) -> Void
    ) -> some View {
        
        let handler = MouseEventHandlerView(
            viewAccessor: viewAccessor,
            mouseMoved: mouseMoved,
            mouseExited: mouseExited
        )

        return self.background {
            handler
        }
    }

}
