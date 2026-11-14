import Foundation
import IOKit.pwr_mgt

@main
struct DisplaySleepTests {
    @MainActor
    static func main() {
        func count() -> Int {
            var assertions: Unmanaged<CFDictionary>?
            precondition(IOPMCopyAssertionsByProcess(&assertions) == kIOReturnSuccess)
            let processes = assertions!.takeRetainedValue() as NSDictionary
            let own = processes[NSNumber(value: ProcessInfo.processInfo.processIdentifier)] as? [[String: Any]] ?? []
            return own.count(where: {
                ($0[kIOPMAssertionNameKey] as? String) == "Lume video playback"
                    && ($0[kIOPMAssertionTypeKey] as? String) == "PreventUserIdleDisplaySleep"
                    && ($0[kIOPMAssertionLevelKey] as? Int) == kIOPMAssertionLevelOn
            })
        }
        func expect(_ wanted: Int, _ message: String) {
            guard count() == wanted else {
                fputs("FAIL: \(message); expected \(wanted), got \(count())\n", stderr)
                exit(1)
            }
            print("PASS: \(message)")
        }
        expect(0, "no assertion before playback")
        var first: PlayerDisplaySleepAssertion? = PlayerDisplaySleepAssertion()
        first!.setActive(false)
        expect(0, "paused initial surface holds nothing")
        first!.setActive(true)
        expect(1, "playback acquires a real OS display assertion")
        first!.setActive(true)
        expect(1, "repeated playback updates do not leak assertions")
        let second = PlayerDisplaySleepAssertion()
        second.setActive(true)
        expect(2, "two playing windows hold independent assertions")
        first!.setActive(false)
        expect(1, "pausing one window leaves the other protected")
        first!.setActive(false)
        expect(1, "repeated pause is harmless")
        first!.setActive(true)
        expect(2, "resume acquires a fresh assertion")
        first = nil
        expect(1, "owner deinitialization releases its assertion")
        second.setActive(false)
        expect(0, "last playback ending releases all owned assertions")
    }
}
