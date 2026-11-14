import Foundation
@testable import Lume
import Testing

@Suite("Player full screen localization")
struct PlayerFullScreenLocalizationTests {
    @Test func `both full screen actions are translated in every shipping locale`() throws {
        let catalog = try StringCatalog.localizable()
        for key in ["Enter Full Screen", "Exit Full Screen"] {
            expectTranslatedEverywhere(key, in: catalog)
        }
    }
}
