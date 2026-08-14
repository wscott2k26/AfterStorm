import Foundation
import XCTest

final class VisualLuxuryTests: XCTestCase {
    func testPremiumButtonUsesAdaptiveVisualStateAndGlassDepth() throws {
        let button = try source("AfterStormApp/Design/PremiumButtonStyle.swift")

        XCTAssertTrue(button.contains("afterStormVisualState"))
        XCTAssertTrue(button.contains("ultraThinMaterial"))
        XCTAssertTrue(button.contains("LinearGradient"))
        XCTAssertTrue(button.contains("accentPrimary"))
        XCTAssertTrue(button.contains("configuration.isPressed"))
        XCTAssertFalse(button.contains("AfterStormTheme.afterglowGradient"), "Premium button must not be a static gold gradient.")
    }

    func testOnboardingUsesAdaptiveStormAndGlassWithoutNestedHorizontalScroll() throws {
        let life = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")
        let choice = try source("AfterStormApp/Onboarding/AvatarChoiceView.swift")
        let studio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")
        let preview = try source("AfterStormApp/Onboarding/AvatarPreviewView.swift")

        XCTAssertTrue(life.contains("AdaptiveStormBackground"))
        XCTAssertTrue(life.contains("adaptiveGlass"))
        XCTAssertTrue(choice.contains("adaptiveGlass"))
        XCTAssertTrue(studio.contains("AdaptiveStormBackground"))
        XCTAssertTrue(studio.contains("adaptiveGlass"))
        XCTAssertFalse(studio.contains("ScrollView(.horizontal"))
        XCTAssertTrue(preview.contains("afterStormVisualState"))
        XCTAssertTrue(preview.contains("RadialGradient"))
    }

    private var repositoryRoot: URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
