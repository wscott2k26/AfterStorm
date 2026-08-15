import Foundation
import XCTest

final class QuestInteractionPolishTests: XCTestCase {
    func testPremiumPressStyleIsReduceMotionAwareAndTactile() throws {
        let interaction = try source("AfterStormApp/Design/PremiumInteractionStyle.swift")

        for token in [
            "struct PremiumPressButtonStyle: ButtonStyle",
            "accessibilityReduceMotion",
            "configuration.isPressed",
            "scaleEffect",
            "brightness",
            "AfterStormTheme.quickSpring"
        ] {
            XCTAssertTrue(interaction.contains(token), "Missing premium press interaction token: \(token)")
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
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
