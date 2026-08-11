import Foundation

public struct Quest: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let instruction: String
    public let lifeArea: LifeArea
    public let estimatedMinutes: Int
    public let sparkReward: Int
    public let restorationNodeID: String

    public init(
        id: UUID = UUID(),
        title: String,
        instruction: String,
        lifeArea: LifeArea,
        estimatedMinutes: Int,
        sparkReward: Int,
        restorationNodeID: String
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.lifeArea = lifeArea
        self.estimatedMinutes = estimatedMinutes
        self.sparkReward = sparkReward
        self.restorationNodeID = restorationNodeID
    }
}
