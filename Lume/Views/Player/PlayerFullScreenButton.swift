#if os(macOS)
    import AppKit
    import SwiftUI

    /// Resolves the button's own window rather than whichever window has focus.
    @Observable
    @MainActor
    final class PlayerFullScreenControl {
        private(set) weak var window: NSWindow?
        private(set) var isFullScreen = false

        func bind(_ window: NSWindow) {
            self.window = window
            refresh()
        }

        func refresh() {
            isFullScreen = window?.styleMask.contains(.fullScreen) == true
        }

        func toggle() {
            window?.toggleFullScreen(nil)
        }
    }

    struct PlayerFullScreenButton: View {
        var onResetHideTimer: () -> Void
        @State private var control = PlayerFullScreenControl()

        var body: some View {
            let title: LocalizedStringKey = control.isFullScreen ? "Exit Full Screen" : "Enter Full Screen"
            Button {
                control.toggle()
                onResetHideTimer()
            } label: {
                Image(systemName: control.isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(title)
            .accessibilityLabel(title)
            .background(PlayerWindowAccessor { control.bind($0) })
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { note in
                if note.object as? NSWindow === control.window { control.refresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { note in
                if note.object as? NSWindow === control.window { control.refresh() }
            }
        }
    }
#endif
