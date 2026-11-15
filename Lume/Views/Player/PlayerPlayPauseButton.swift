#if os(macOS)
    import SwiftUI

    /// Compact transport control for the Mac player's bottom controls group.
    struct PlayerPlayPauseButton: View {
        let isPlaying: Bool
        var onTogglePlay: () -> Void
        var onResetHideTimer: () -> Void

        var body: some View {
            let title: LocalizedStringKey = isPlaying ? "Pause" : "Play"
            Button {
                onTogglePlay()
                onResetHideTimer()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
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
