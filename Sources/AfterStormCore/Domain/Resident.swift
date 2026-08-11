public struct Resident: Identifiable, Equatable, Codable, Sendable {
    public enum Kind: String, Codable, Sendable { case stormling, human, animal }

    public let id: String
    public let name: String
    public let kind: Kind
    public let personality: String
    public let story: String
    public let home: String
    public let requiredQuestCount: Int

    public init(id: String, name: String, kind: Kind, personality: String, story: String, home: String, requiredQuestCount: Int) {
        self.id = id
        self.name = name
        self.kind = kind
        self.personality = personality
        self.story = story
        self.home = home
        self.requiredQuestCount = max(0, requiredQuestCount)
    }
}

public enum ResidentCatalog {
    public static let launch: [Resident] = [
        .init(id: "nova", name: "Nova", kind: .stormling, personality: "Bright, curious, quietly brave", story: "Nova kept one porch light glowing through the storm.", home: "Maple House", requiredQuestCount: 1),
        .init(id: "pip", name: "Pip", kind: .animal, personality: "Loyal puddle inspector", story: "Pip appears wherever a sidewalk gets repaired.", home: "Main Street", requiredQuestCount: 3),
        .init(id: "mara", name: "Mara", kind: .human, personality: "Builder and neighborhood fixer", story: "Mara reopens the workshop one careful repair at a time.", home: "Workshop", requiredQuestCount: 5),
        .init(id: "rumble", name: "Rumble", kind: .stormling, personality: "Big heart, tiny patience", story: "Rumble pretends not to care when the park flowers return.", home: "Park", requiredQuestCount: 8),
        .init(id: "miso", name: "Miso", kind: .animal, personality: "Professional napper", story: "Miso claims the warmest restored windowsill in The Block.", home: "Corner Store", requiredQuestCount: 12)
    ]

    public static func unlocked(completedQuestCount: Int) -> [Resident] {
        launch.filter { completedQuestCount >= $0.requiredQuestCount }
    }
}
