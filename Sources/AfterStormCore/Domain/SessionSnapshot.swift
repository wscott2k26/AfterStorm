import Foundation

public struct SessionSnapshot: Equatable, Codable, Sendable {
    public var selectedAreas: Set<LifeArea>
    public var avatarKind: AvatarKind?
    public var avatarStyle: AvatarStyle
    public var progress: PlayerProgress
    public var restorationNodes: [RestorationNode]
    public var completedQuestIDs: Set<UUID>
    public var completionHistory: [QuestCompletionRecord]

    public init(
        selectedAreas: Set<LifeArea>,
        avatarKind: AvatarKind?,
        avatarStyle: AvatarStyle = .default,
        progress: PlayerProgress,
        restorationNodes: [RestorationNode],
        completedQuestIDs: Set<UUID>,
        completionHistory: [QuestCompletionRecord] = []
    ) {
        self.selectedAreas = selectedAreas
        self.avatarKind = avatarKind
        self.avatarStyle = avatarStyle
        self.progress = progress
        self.restorationNodes = restorationNodes
        self.completedQuestIDs = completedQuestIDs
        self.completionHistory = completionHistory
    }

    private enum CodingKeys: String, CodingKey {
        case selectedAreas, avatarKind, avatarStyle, progress, restorationNodes, completedQuestIDs, completionHistory
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedAreas = try container.decode(Set<LifeArea>.self, forKey: .selectedAreas)
        avatarKind = try container.decodeIfPresent(AvatarKind.self, forKey: .avatarKind)
        avatarStyle = try container.decodeIfPresent(AvatarStyle.self, forKey: .avatarStyle) ?? .default
        progress = try container.decode(PlayerProgress.self, forKey: .progress)
        restorationNodes = try container.decode([RestorationNode].self, forKey: .restorationNodes)
        completedQuestIDs = try container.decodeIfPresent(Set<UUID>.self, forKey: .completedQuestIDs) ?? []
        completionHistory = try container.decodeIfPresent([QuestCompletionRecord].self, forKey: .completionHistory) ?? []
    }
}
