import XCTest
@testable import AfterStormCore

final class ContextQuestComposerTests: XCTestCase {
    func testDigitalContextRoutesToDigitalAndRespectsFiveMinuteLimit() async throws {
        let composer = LocalContextQuestComposer(seed: 4)
        let context = QuestContext(text: "My inbox, screenshots, and notifications are a mess. I have 5 minutes.", source: .text)

        let quests = try await composer.suggestions(for: context, selectedAreas: Set(LifeArea.allCases), count: 3)

        XCTAssertEqual(quests.count, 3)
        XCTAssertTrue(quests.allSatisfy { $0.lifeArea == .digital })
        XCTAssertTrue(quests.allSatisfy { $0.estimatedMinutes <= 5 })
    }

    func testEasyContextKeepsUserSelectedAreasAndShrinksScope() async throws {
        let composer = LocalContextQuestComposer(seed: 2)
        let context = QuestContext(text: "I'm overwhelmed. Give me something easy.", source: .speech)

        let quests = try await composer.suggestions(for: context, selectedAreas: [.home, .focus], count: 3)

        XCTAssertEqual(quests.count, 3)
        XCTAssertTrue(quests.allSatisfy { [.home, .focus].contains($0.lifeArea) })
        XCTAssertTrue(quests.allSatisfy { $0.estimatedMinutes <= 5 })
        XCTAssertTrue(quests.allSatisfy { $0.sparkReward > 0 })
    }

    func testExplicitPreferredMinutesOverridesTextParsing() async throws {
        let composer = LocalContextQuestComposer(seed: 9)
        let context = QuestContext(text: "I can work on something for twenty minutes", preferredMinutes: 2, source: .text)

        let quests = try await composer.suggestions(for: context, selectedAreas: [.work], count: 3)

        XCTAssertTrue(quests.allSatisfy { $0.estimatedMinutes <= 2 })
    }
}
