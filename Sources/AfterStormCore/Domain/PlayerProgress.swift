public struct PlayerProgress: Equatable, Codable, Sendable {
    public var sparks: Int
    public var completedQuestCount: Int

    public init(sparks: Int = 0, completedQuestCount: Int = 0) {
        self.sparks = max(0, sparks)
        self.completedQuestCount = max(0, completedQuestCount)
    }
}
