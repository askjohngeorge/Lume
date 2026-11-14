#if os(macOS)
    import SwiftUI

    /// Shares the native player window's state and action with the F shortcut.
    struct PlayerFullScreenButton: View {
        var onResetHideTimer: () -> Void
        @State private var router = MacPlayerWindowRouter.shared

        var body: some View {
            let title: LocalizedStringKey = router.isFullScreen ? "Exit Full Screen" : "Enter Full Screen"
            Button {
                router.toggleFullScreen()
                onResetHideTimer()
            } label: {
                Image(systemName: router.isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(title)
            .accessibilityLabel(title)
        }
    }
#endif
