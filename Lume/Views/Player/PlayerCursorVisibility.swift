#if os(macOS)
    import AppKit
    import SwiftUI

    /// Only the active fullscreen player may hide the pointer. AppKit restores
    /// it on mouse movement; every way of leaving playback clears our request.
    @MainActor
    final class PlayerCursorVisibilityController {
        private weak var window: NSWindow?
        private var controlsVisible = true
        private var pointerInside = false
        private var isTransitioning = false
        private var isPresentingSheet = false
        private var hasHiddenCursor = false
        private var observers: [NSObjectProtocol] = []
        private let setHidden: @MainActor (Bool) -> Void
        private let isAppActive: @MainActor () -> Bool

        init(
            setHidden: @escaping @MainActor (Bool) -> Void = { NSCursor.setHiddenUntilMouseMoves($0) },
            isAppActive: @escaping @MainActor () -> Bool = { NSApp.isActive }
        ) {
            self.setHidden = setHidden
            self.isAppActive = isAppActive
        }

        func bind(_ window: NSWindow?) {
            guard self.window !== window else { return }
            stop()
            self.window = window
            guard let window else { return }
            let center = NotificationCenter.default
            for name in [NSWindow.willEnterFullScreenNotification, NSWindow.willExitFullScreenNotification] {
                observers.append(center.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.isTransitioning = true
                        self?.restoreCursor()
                    }
                })
            }
            for name in [NSWindow.didEnterFullScreenNotification, NSWindow.didExitFullScreenNotification] {
                observers.append(center.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated {
                        self?.isTransitioning = false
                        self?.refresh()
                    }
                })
            }
            for name in [NSWindow.didBecomeKeyNotification, NSWindow.didResignKeyNotification] {
                observers.append(center.addObserver(forName: name, object: window, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated { self?.refresh() }
                })
            }
            observers.append(center.addObserver(forName: NSWindow.willBeginSheetNotification, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.isPresentingSheet = true
                    self?.restoreCursor()
                }
            })
            observers.append(center.addObserver(forName: NSWindow.didEndSheetNotification, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.isPresentingSheet = false
                    self?.refresh()
                }
            })
            observers.append(center.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.stop() }
            })
            for name in [NSApplication.didBecomeActiveNotification, NSApplication.didResignActiveNotification] {
                observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated { self?.refresh() }
                })
            }
            refresh()
        }

        func update(controlsVisible: Bool, pointerInside: Bool) {
            self.controlsVisible = controlsVisible
            self.pointerInside = pointerInside
            refresh()
        }

        private func refresh() {
            let shouldHide = !controlsVisible && pointerInside && !isTransitioning && !isPresentingSheet && isAppActive()
                && window?.isKeyWindow == true && window?.styleMask.contains(.fullScreen) == true
                && window?.attachedSheet == nil
            if shouldHide {
                guard !hasHiddenCursor else { return }
                hasHiddenCursor = true
                setHidden(true)
            } else {
                restoreCursor()
            }
        }

        private func restoreCursor() {
            guard hasHiddenCursor else { return }
            hasHiddenCursor = false
            setHidden(false)
        }

        func stop() {
            restoreCursor()
            observers.forEach(NotificationCenter.default.removeObserver)
            observers = []
            window = nil
            isTransitioning = false
            isPresentingSheet = false
        }
    }

    /// Resolves the real containing window, including detach and reattachment.
    struct PlayerCursorVisibility: NSViewRepresentable {
        let controlsVisible: Bool
        let pointerInside: Bool

        func makeNSView(context _: Context) -> PlayerCursorWindowView {
            PlayerCursorWindowView()
        }

        func updateNSView(_ view: PlayerCursorWindowView, context _: Context) {
            view.controller.update(controlsVisible: controlsVisible, pointerInside: pointerInside)
        }

        static func dismantleNSView(_ view: PlayerCursorWindowView, coordinator _: ()) {
            view.controller.stop()
        }
    }

    final class PlayerCursorWindowView: NSView {
        let controller = PlayerCursorVisibilityController()

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            controller.bind(window)
        }

        override func hitTest(_: NSPoint) -> NSView? {
            nil
        }
    }
#endif
