import SwiftUI

#if os(macOS)
    import IOKit.pwr_mgt
    import OSLog

    /// Each playing surface owns its assertion, so closing one window cannot
    /// let the display sleep while another is still playing.
    @MainActor
    final class PlayerDisplaySleepAssertion {
        private var assertionID: IOPMAssertionID = 0

        func setActive(_ active: Bool) {
            if active {
                guard assertionID == 0 else { return }
                let result = IOPMAssertionCreateWithName(
                    kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                    IOPMAssertionLevel(kIOPMAssertionLevelOn),
                    "Lume video playback" as CFString,
                    &assertionID
                )
                if result != kIOReturnSuccess {
                    assertionID = 0
                    Logger(subsystem: "com.bilipp.lume", category: "Playback")
                        .error("Could not prevent display sleep: \(result, privacy: .public)")
                }
            } else if assertionID != 0 {
                IOPMAssertionRelease(assertionID)
                assertionID = 0
            }
        }

        deinit {
            if assertionID != 0 { IOPMAssertionRelease(assertionID) }
        }
    }

    private struct PlayerDisplaySleepModifier: ViewModifier {
        let isPlaying: Bool
        @State private var assertion = PlayerDisplaySleepAssertion()

        func body(content: Content) -> some View {
            content
                .onAppear { assertion.setActive(isPlaying) }
                .onChange(of: isPlaying) { _, playing in assertion.setActive(playing) }
                .onDisappear { assertion.setActive(false) }
        }
    }
#endif

extension View {
    /// Applied at each engine surface so pause, failure and teardown release it.
    /// Fullscreen transitions and switching focus do not stop video playback.
    func playerPreventsDisplaySleep(isPlaying: Bool) -> some View {
        #if os(macOS)
            modifier(PlayerDisplaySleepModifier(isPlaying: isPlaying))
        #else
            self
        #endif
    }
}
