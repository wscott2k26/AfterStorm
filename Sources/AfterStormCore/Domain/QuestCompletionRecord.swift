import Foundation

public struct QuestCompletionRecord: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let questID: UUID
    public let title: String
    public let lifeArea: LifeArea
    public let estimatedMinutes: Int
    public let sparkReward: Int
    public let restorationNodeID: String
    public let completedAt: Date

    public init(quest: Quest, completedAt: Date) {
        self.id = UUID()
        self.questID = quest.id
        self.title = quest.title
        self.lifeArea = quest.lifeArea
        self.estimatedMinutes = quest.estimatedMinutes
        self.sparkReward = quest.sparkReward
        self.restorationNodeID = quest.restorationNodeID
        self.completedAt = completedAt
    }
}
