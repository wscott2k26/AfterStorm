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

    func testLifeAreaSelectionKeepsGlassAndAddsTactilePressFeedback() throws {
        let life = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")

        for token in [
            ".buttonStyle(PremiumPressButtonStyle(pressedScale: 0.975, pressedBrightness: -0.014))",
            ".transition(.scale.combined(with: .opacity))",
            ".disabled(selection.isEmpty)",
            ".hybridGlassTile(cornerRadius: 22, selected: selected)"
        ] {
            XCTAssertTrue(life.contains(token), "Missing Life Area interaction token: \(token)")
        }
    }

    func testQuestModeAndCompletionUsePremiumStateFeedback() throws {
        let mode = try source("AfterStormApp/Quest/QuestModeView.swift")
        let complete = try source("AfterStormApp/Quest/QuestCompleteView.swift")
        let haptics = try source("AfterStormApp/Services/HapticsService.swift")

        for token in [
            "static func timerFinished()",
            "guard ExperiencePreferences.shared.hapticsEnabled else { return }"
        ] {
            XCTAssertTrue(haptics.contains(token), "Missing timer haptic token: \(token)")
        }

        for token in [
            ".buttonStyle(HybridGlassChipStyle(selected: isPaused))",
            ".onChange(of: remainingSeconds)",
            "HapticsService.timerFinished()"
        ] {
            XCTAssertTrue(mode.contains(token), "Missing Quest Mode interaction token: \(token)")
        }

        XCTAssertTrue(
            complete.contains(".buttonStyle(PremiumPressButtonStyle(pressedScale: 0.985, pressedBrightness: -0.012))")
        )
        XCTAssertTrue(complete.contains("guard !reduceMotion else { return }"))
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
