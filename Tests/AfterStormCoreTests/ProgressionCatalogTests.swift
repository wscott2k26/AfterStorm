import XCTest
@testable import AfterStormCore

final class ProgressionCatalogTests: XCTestCase {
    func testCompletionHistoryRecordsEachQuestOnceAndBuildsInsights() {
        let session = AfterStormSession(engine: LocalQuestEngine(seed: 1))
        let home = Quest(title: "Clear one surface", instruction: "Reset it.", lifeArea: .home, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "east-lights")
        let focus = Quest(title: "Five-minute focus", instruction: "Focus.", lifeArea: .focus, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "power-station")
        let date = Date(timeIntervalSince1970: 1_800_000_000)

        session.complete(home, at: date)
        session.complete(home, at: date.addingTimeInterval(60))
        session.complete(focus, at: date.addingTimeInterval(120))

        XCTAssertEqual(session.completionHistory.count, 2)
        XCTAssertEqual(session.completionHistory.first?.completedAt, date)
        XCTAssertEqual(ProgressInsights(history: session.completionHistory, nodes: session.restorationNodes).totalQuests, 2)
        XCTAssertEqual(ProgressInsights(history: session.completionHistory, nodes: session.restorationNodes).favoriteQuestMinutes, 5)
    }

    func testCatalogUnlocksAreDeterministicFromProgress() {
        let locked = CollectibleCatalog.unlocked(completedQuestCount: 0, sparks: 0)
        let progressed = CollectibleCatalog.unlocked(completedQuestCount: 6, sparks: 120)
        let residents = ResidentCatalog.unlocked(completedQuestCount: 6)

        XCTAssertTrue(locked.isEmpty)
        XCTAssertGreaterThanOrEqual(progressed.count, 2)
        XCTAssertGreaterThanOrEqual(residents.count, 2)
        XCTAssertEqual(progressed, CollectibleCatalog.unlocked(completedQuestCount: 6, sparks: 120))
    }

    func testAvatarStyleSurvivesSnapshotRestore() {
        let original = AfterStormSession(engine: LocalQuestEngine(seed: 3))
        let style = AvatarStyle(palette: .afterglow, outfit: .raincoat, accessory: .beanie)
        original.configure(areas: [.home], avatarKind: .stormling, avatarStyle: style)

        let restored = AfterStormSession(engine: LocalQuestEngine(seed: 3))
        restored.restore(original.snapshot())

        XCTAssertEqual(restored.avatarStyle, style)
    }
}

extension ProgressionCatalogTests {
    func testAvatarStyleDecodesLegacyPayloadWithPremiumDefaults() throws {
        let data = Data(#"{"palette":"afterglow","outfit":"raincoat","accessory":"beanie"}"#.utf8)

        let style = try JSONDecoder().decode(AvatarStyle.self, from: data)

        XCTAssertEqual(style.palette, .afterglow)
        XCTAssertEqual(style.outfit, .raincoat)
        XCTAssertEqual(style.accessory, .beanie)
        XCTAssertEqual(style.skinTone, .golden)
        XCTAssertEqual(style.hairStyle, .cropped)
        XCTAssertEqual(style.eyeStyle, .bright)
        XCTAssertEqual(style.stormlingBody, .smooth)
        XCTAssertEqual(style.headShape, .round)
    }
}

extension ProgressionCatalogTests {
    func testLaunchCollectibleCatalogCoversEveryV1RewardKind() {
        let kinds = Set(CollectibleCatalog.launch.map(\.kind))
        XCTAssertEqual(kinds, Set([.outfit, .accessory, .decoration, .plant, .light, .sign, .pet, .weather]))
    }
}
