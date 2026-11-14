#if os(macOS)
    import SwiftUI

    struct PlayerPinButton: View {
        var onResetHideTimer: () -> Void
        @State private var router = MacPlayerWindowRouter.shared

        var body: some View {
            let title: LocalizedStringKey = router.isFloating ? "Stop Floating on Top" : "Float on Top"
            Button {
                router.toggleFloating()
                onResetHideTimer()
            } label: {
                Image(systemName: router.isFloating ? "pin.fill" : "pin")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                    .glassEffectCompat(.regularInteractive, in: Circle())
            }
            .buttonStyle(.plain)
            .help(title)
            .accessibilityLabel(title)
            .accessibilityValue(router.isFloating ? "On" : "Off")
        }
    }
#endif
