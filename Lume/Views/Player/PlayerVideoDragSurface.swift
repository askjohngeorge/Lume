#if os(macOS)
    import AppKit
    import SwiftUI

    /// Sits behind the player controls, so only uncovered video starts a drag.
    struct PlayerVideoDragSurface: NSViewRepresentable {
        var onClick: () -> Void

        func makeNSView(context _: Context) -> PlayerVideoDragView {
            let view = PlayerVideoDragView()
            view.onClick = onClick
            return view
        }

        func updateNSView(_ view: PlayerVideoDragView, context _: Context) {
            view.onClick = onClick
        }
    }

    final class PlayerVideoDragView: NSView {
        var onClick: (() -> Void)?
        private var mouseDownEvent: NSEvent?
        private var didDrag = false

        override var mouseDownCanMoveWindow: Bool {
            false
        }

        override func acceptsFirstMouse(for _: NSEvent?) -> Bool {
            true
        }

        override func mouseDown(with event: NSEvent) {
            mouseDownEvent = event
            didDrag = false
        }

        override func mouseDragged(with event: NSEvent) {
            guard let start = mouseDownEvent, !didDrag else { return }
            let distance = hypot(event.locationInWindow.x - start.locationInWindow.x,
                                 event.locationInWindow.y - start.locationInWindow.y)
            guard distance >= 4 else { return }
            didDrag = true
            guard let window, !window.styleMask.contains(.fullScreen) else { return }
            window.performDrag(with: start)
        }

        override func mouseUp(with _: NSEvent) {
            if mouseDownEvent != nil, !didDrag { onClick?() }
            mouseDownEvent = nil
        }
    }
#endif
