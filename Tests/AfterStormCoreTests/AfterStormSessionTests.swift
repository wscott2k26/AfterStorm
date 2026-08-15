import XCTest
@testable import AfterStormCore

final class AfterStormSessionTests: XCTestCase {
    func testFirstRunCanConfigureReceiveQuestAndRestoreWorld() async throws {
        let session = AfterStormSession(engine: LocalQuestEngine(seed: 1))
        session.configure(areas: [.home, .focus], avatarKind: .stormling)
        try await session.refreshSuggestions()

        XCTAssertEqual(session.suggestions.count, 3)
        let quest = try XCTUnwrap(session.suggestions.first)
        session.complete(quest)

        XCTAssertGreaterThan(session.progress.sparks, 0)
        XCTAssertEqual(session.progress.completedQuestCount, 1)
        XCTAssertTrue(session.restorationNodes.contains { $0.stage > 0 })
    }

    func testMakeEasierReducesDurationAndKeepsRewardPositive() {
        let session = AfterStormSession(engine: LocalQuestEngine(seed: 1))
        let quest = Quest(
            title: "Finish the smallest piece",
            instruction: "Close one small part.",
            lifeArea: .focus,
            estimatedMinutes: 10,
            sparkReward: 20,
            restorationNodeID: "workshop"
        )

        let easier = session.makeEasier(quest)

        XCTAssertLessThan(easier.estimatedMinutes, quest.estimatedMinutes)
        XCTAssertGreaterThan(easier.sparkReward, 0)
        XCTAssertEqual(easier.restorationNodeID, quest.restorationNodeID)
    }

    func testCompletingSameQuestTwiceOnlyAwardsOnce() {
        let session = AfterStormSession(engine: LocalQuestEngine(seed: 1))
        let quest = Quest(
            title: "Clear one surface",
            instruction: "Reset one surface.",
            lifeArea: .home,
            estimatedMinutes: 5,
            sparkReward: 15,
            restorationNodeID: "east-lights"
        )

        session.complete(quest)
        session.complete(quest)

        XCTAssertEqual(session.progress.sparks, 15)
        XCTAssertEqual(session.progress.completedQuestCount, 1)
        XCTAssertEqual(session.restorationNodes.first(where: { $0.id == "east-lights" })?.stage, 1)
    }


    func testSnapshotRestoresProgressAndCompletedQuestIdentity() {
        let original = AfterStormSession(engine: LocalQuestEngine(seed: 2))
        original.configure(areas: [.home, .learning], avatarKind: .human)
        let quest = Quest(
            title: "Read for five",
            instruction: "Read for five minutes.",
            lifeArea: .learning,
            estimatedMinutes: 5,
            sparkReward: 15,
            restorationNodeID: "corner-store"
        )
        original.complete(quest)

        let snapshot = original.snapshot()
        let restored = AfterStormSession(engine: LocalQuestEngine(seed: 2))
        restored.restore(snapshot)
        restored.complete(quest)

        XCTAssertEqual(restored.selectedAreas, [.home, .learning])
        XCTAssertEqual(restored.avatarKind, .human)
        XCTAssertEqual(restored.progress.sparks, 15)
        XCTAssertEqual(restored.progress.completedQuestCount, 1)
        XCTAssertEqual(restored.restorationNodes.first(where: { $0.id == "corner-store" })?.stage, 1)
    }

}

extension AfterStormSessionTests {
    func testUpdatingSelectedAreasChangesFutureSnapshotWithoutResettingProgress() async throws {
        let session = AfterStormSession(engine: LocalQuestEngine())
        session.configure(areas: [.home], avatarKind: .stormling)
        try await session.refreshSuggestions(count: 1)
        let quest = try XCTUnwrap(session.suggestions.first)
        session.complete(quest)
        let sparksBefore = session.progress.sparks

        session.updateSelectedAreas([.work, .learning, .movement])

        XCTAssertEqual(session.selectedAreas, [.work, .learning, .movement])
        XCTAssertEqual(session.snapshot().selectedAreas, [.work, .learning, .movement])
        XCTAssertEqual(session.progress.sparks, sparksBefore)
        XCTAssertEqual(session.progress.completedQuestCount, 1)
    }
}
