public struct ProgressInsights: Equatable, Sendable {
    public let totalQuests: Int
    public let totalSparksEarned: Int
    public let totalRestoredStages: Int
    public let fullyRestoredAreas: Int
    public let favoriteLifeArea: LifeArea?
    public let favoriteQuestMinutes: Int?

    public init(history: [QuestCompletionRecord], nodes: [RestorationNode]) {
        totalQuests = history.count
        totalSparksEarned = history.reduce(0) { $0 + $1.sparkReward }
        totalRestoredStages = nodes.reduce(0) { $0 + $1.stage }
        fullyRestoredAreas = nodes.filter(\.isFullyRestored).count

        let areaCounts = Dictionary(grouping: history, by: \.lifeArea).mapValues(\.count)
        favoriteLifeArea = areaCounts
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key.rawValue < rhs.key.rawValue : lhs.value > rhs.value }
            .first?.key

        let minuteCounts = Dictionary(grouping: history, by: \.estimatedMinutes).mapValues(\.count)
        favoriteQuestMinutes = minuteCounts
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value }
            .first?.key
    }
}
