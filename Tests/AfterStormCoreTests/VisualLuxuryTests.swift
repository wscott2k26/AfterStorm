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
