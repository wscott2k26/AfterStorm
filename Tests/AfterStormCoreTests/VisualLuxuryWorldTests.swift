import Foundation
import XCTest

final class VisualLuxuryWorldTests: XCTestCase {
    func testWorldKeepsDioramaHeroAndUsesAdaptiveGlassLighting() throws {
        let home = try source("AfterStormApp/World/WorldHomeView.swift")
        let reveal = try source("AfterStormApp/World/RestorationRevealView.swift")
        XCTAssertTrue(home.contains("afterStormVisualState"))
        XCTAssertTrue(home.contains("adaptiveGlass"))
        XCTAssertTrue(home.contains("transaction.disablesAnimations"))
        XCTAssertFalse(home.contains(".environment(\\.accessibilityReduceMotion"))
        XCTAssertTrue(reveal.contains("afterStormVisualState"))
        XCTAssertTrue(reveal.contains("adaptiveGlass"))
        XCTAssertTrue(reveal.contains("majorRestoration"))
    }

    func testMeAndSettingsUseLuxurySystemWithoutRemovingControls() throws {
        let me = try source("AfterStormApp/Main/MeView.swift")
        let settings = try source("AfterStormApp/Settings/SettingsView.swift")
        XCTAssertTrue(me.contains("AdaptiveStormBackground"))
        XCTAssertTrue(me.contains("adaptiveGlass"))
        XCTAssertTrue(settings.contains("AdaptiveStormBackground"))
        XCTAssertTrue(settings.contains("Sound & Haptics"))
        XCTAssertTrue(settings.contains("Lightning & Flash"))
        XCTAssertTrue(settings.contains("Avatar Animation"))
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
