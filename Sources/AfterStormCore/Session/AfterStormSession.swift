import Foundation

public final class AfterStormSession {
    public private(set) var selectedAreas: Set<LifeArea> = []
    public private(set) var avatarKind: AvatarKind?
    public private(set) var avatarStyle: AvatarStyle = .default
    public private(set) var suggestions: [Quest] = []
    public private(set) var progress = PlayerProgress()
    public private(set) var restorationNodes: [RestorationNode]
    public private(set) var completionHistory: [QuestCompletionRecord] = []

    private let engine: any QuestEngine
    private var completedQuestIDs: Set<UUID> = []

    public init(engine: any QuestEngine) {
        self.engine = engine
        self.restorationNodes = Self.initialRestorationNodes
    }

    public func configure(areas: Set<LifeArea>, avatarKind: AvatarKind, avatarStyle: AvatarStyle = .default) {
        selectedAreas = areas
        self.avatarKind = avatarKind
        self.avatarStyle = avatarStyle
    }

    public func updateAvatarStyle(_ style: AvatarStyle) {
        avatarStyle = style
    }

    public func updateSelectedAreas(_ areas: Set<LifeArea>) {
        selectedAreas = areas
    }

    public func refreshSuggestions(count: Int = 3) async throws {
        suggestions = try await engine.suggestions(for: selectedAreas, count: count)
    }

    public func replaceSuggestions(_ quests: [Quest]) {
        suggestions = quests
    }

    public func complete(_ quest: Quest, at completedAt: Date = Date()) {
        guard completedQuestIDs.insert(quest.id).inserted else { return }
        WorldProgression.complete(quest: quest, progress: &progress, nodes: &restorationNodes)
        completionHistory.append(QuestCompletionRecord(quest: quest, completedAt: completedAt))
    }

    public func snapshot() -> SessionSnapshot {
        SessionSnapshot(
            selectedAreas: selectedAreas,
            avatarKind: avatarKind,
            avatarStyle: avatarStyle,
            progress: progress,
            restorationNodes: restorationNodes,
            completedQuestIDs: completedQuestIDs,
            completionHistory: completionHistory
        )
    }

    public func restore(_ snapshot: SessionSnapshot) {
        selectedAreas = snapshot.selectedAreas
        avatarKind = snapshot.avatarKind
        avatarStyle = snapshot.avatarStyle
        progress = snapshot.progress
        restorationNodes = snapshot.restorationNodes
        completedQuestIDs = snapshot.completedQuestIDs
        completionHistory = snapshot.completionHistory
        suggestions = []
    }

    public func makeEasier(_ quest: Quest) -> Quest {
        let easierMinutes = max(1, quest.estimatedMinutes / 2)
        let easierReward = max(5, Int(Double(quest.sparkReward) * 0.75))
        return Quest(
            id: quest.id,
            title: quest.title,
            instruction: "Make it smaller: \(quest.instruction)",
            lifeArea: quest.lifeArea,
            estimatedMinutes: easierMinutes,
            sparkReward: easierReward,
            restorationNodeID: quest.restorationNodeID
        )
    }

    private static let initialRestorationNodes: [RestorationNode] = [
        .init(id: "east-lights", title: "East Street Lights", maxStage: 3),
        .init(id: "maple-home", title: "Maple House", maxStage: 3),
        .init(id: "corner-store", title: "Corner Store", maxStage: 3),
        .init(id: "workshop", title: "Workshop", maxStage: 3),
        .init(id: "bridge", title: "Bridge", maxStage: 3),
        .init(id: "power-station", title: "Power Station", maxStage: 3),
        .init(id: "main-street", title: "Main Street", maxStage: 3),
        .init(id: "park", title: "Park", maxStage: 3)
    ]
}
