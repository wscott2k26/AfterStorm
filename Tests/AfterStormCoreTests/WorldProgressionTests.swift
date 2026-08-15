import XCTest
@testable import AfterStormCore

final class WorldProgressionTests: XCTestCase {
    func testCompletingQuestAwardsSparksAndAdvancesTargetNode() {
        var progress = PlayerProgress()
        var nodes = [RestorationNode(id: "east-lights", title: "East Street Lights", stage: 0, maxStage: 3)]
        let quest = Quest(
            title: "Clear one surface",
            instruction: "Reset one surface.",
            lifeArea: .home,
            estimatedMinutes: 5,
            sparkReward: 15,
            restorationNodeID: "east-lights"
        )

        WorldProgression.complete(quest: quest, progress: &progress, nodes: &nodes)

        XCTAssertEqual(progress.sparks, 15)
        XCTAssertEqual(progress.completedQuestCount, 1)
        XCTAssertEqual(nodes[0].stage, 1)
    }

    func testCompletingQuestDoesNotChangeUnrelatedOrDecreaseRestoredNodes() {
        var progress = PlayerProgress(sparks: 5, completedQuestCount: 1)
        var nodes = [
            RestorationNode(id: "east-lights", title: "East Street Lights", stage: 3, maxStage: 3),
            RestorationNode(id: "park", title: "Park", stage: 1, maxStage: 3)
        ]
        let quest = Quest(
            title: "Clear one surface",
            instruction: "Reset one surface.",
            lifeArea: .home,
            estimatedMinutes: 5,
            sparkReward: 15,
            restorationNodeID: "east-lights"
        )

        WorldProgression.complete(quest: quest, progress: &progress, nodes: &nodes)

        XCTAssertEqual(nodes[0].stage, 3)
        XCTAssertEqual(nodes[1].stage, 1)
        XCTAssertEqual(progress.sparks, 20)
        XCTAssertEqual(progress.completedQuestCount, 2)
    }
}
