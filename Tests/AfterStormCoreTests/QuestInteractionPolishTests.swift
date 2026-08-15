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

    func testQuestsDiscoveryUsesConsistentTactileFeedback() throws {
        let quests = try source("AfterStormApp/Main/QuestsView.swift")

        for token in [
            "@Environment(\\.accessibilityReduceMotion) private var reduceMotion",
            ".buttonStyle(PremiumPressButtonStyle())",
            "HapticsService.tap(); withAnimation(AfterStormTheme.quickSpring) { timeFilter = value }",
            "HapticsService.tap(); withAnimation(AfterStormTheme.quickSpring) { selectedArea = nil }",
            "HapticsService.tap(); withAnimation(AfterStormTheme.quickSpring) { selectedArea = area }",
            ".animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: model.isLoadingQuests)"
        ] {
            XCTAssertTrue(quests.contains(token), "Missing Quests interaction token: \(token)")
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
