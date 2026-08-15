public struct RestorationNode: Equatable, Codable, Sendable {
    public let id: String
    public let title: String
    public var stage: Int
    public let maxStage: Int

    public init(id: String, title: String, stage: Int = 0, maxStage: Int) {
        self.id = id
        self.title = title
        self.stage = min(max(stage, 0), maxStage)
        self.maxStage = max(maxStage, 1)
    }

    public var isFullyRestored: Bool { stage >= maxStage }
}
