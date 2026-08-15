import XCTest
@testable import AfterStormCore

final class LocalQuestEngineTests: XCTestCase {
    func testSuggestionsRespectSelectedLifeAreasAndReturnThreeQuests() async throws {
        let engine = LocalQuestEngine(seed: 7)
        let quests = try await engine.suggestions(for: [.home, .focus], count: 3)

        XCTAssertEqual(quests.count, 3)
        XCTAssertTrue(quests.allSatisfy { [.home, .focus].contains($0.lifeArea) })
        XCTAssertTrue(quests.allSatisfy { $0.sparkReward > 0 })
    }

    func testConsecutiveRequestsRotateQuestSuggestions() async throws {
        let engine = LocalQuestEngine(seed: 3)

        let first = try await engine.suggestions(for: [.home, .focus], count: 3)
        let second = try await engine.suggestions(for: [.home, .focus], count: 3)

        XCTAssertNotEqual(first.map(\.title), second.map(\.title))
    }

}

extension LocalQuestEngineTests {
    func testEveryLifeAreaOffersATwentyMinuteQuest() async throws {
        let engine = LocalQuestEngine(seed: 0)
        let quests = try await engine.suggestions(for: Set(LifeArea.allCases), count: 100)
        for area in LifeArea.allCases {
            XCTAssertTrue(quests.contains { $0.lifeArea == area && $0.estimatedMinutes >= 20 }, "Missing 20+ minute quest for \(area.rawValue)")
        }
    }
}
