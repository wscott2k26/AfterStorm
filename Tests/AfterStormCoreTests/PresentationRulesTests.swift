import XCTest
@testable import AfterStormCore

final class PresentationRulesTests: XCTestCase {
    func testTwentyPlusTimeFilterMatchesOnlyLongQuests() {
        XCTAssertFalse(QuestTimeFilter.twentyPlus.matches(minutes: 10))
        XCTAssertTrue(QuestTimeFilter.twentyPlus.matches(minutes: 20))
        XCTAssertTrue(QuestTimeFilter.twentyPlus.matches(minutes: 45))
    }

    func testUpperBoundTimeFiltersRemainInclusive() {
        XCTAssertTrue(QuestTimeFilter.upTo5.matches(minutes: 5))
        XCTAssertFalse(QuestTimeFilter.upTo5.matches(minutes: 6))
        XCTAssertTrue(QuestTimeFilter.any.matches(minutes: 90))
    }

    func testWorldWeatherMovesFromStormyToClearingToAfterglow() {
        XCTAssertEqual(WorldWeatherState(restoredStages: 0, totalStages: 24), .stormy)
        XCTAssertEqual(WorldWeatherState(restoredStages: 8, totalStages: 24), .clearing)
        XCTAssertEqual(WorldWeatherState(restoredStages: 20, totalStages: 24), .afterglow)
    }

    func testRestorationReactionChangesAsTheBlockComesBackToLife() {
        XCTAssertEqual(RestorationReaction(restoredStages: 2).speaker, "Nova")
        XCTAssertEqual(RestorationReaction(restoredStages: 23).speaker, "Mara")
        XCTAssertTrue(RestorationReaction(restoredStages: 23).message.contains("horizon"))
    }
}
