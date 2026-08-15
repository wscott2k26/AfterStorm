public struct Collectible: Identifiable, Equatable, Codable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case outfit, accessory, decoration, plant, light, sign, pet, weather
    }

    public let id: String
    public let title: String
    public let kind: Kind
    public let detail: String
    public let requiredQuestCount: Int
    public let requiredSparks: Int

    public init(id: String, title: String, kind: Kind, detail: String, requiredQuestCount: Int, requiredSparks: Int) {
        self.id = id
        self.title = title
        self.kind = kind
        self.detail = detail
        self.requiredQuestCount = max(0, requiredQuestCount)
        self.requiredSparks = max(0, requiredSparks)
    }
}

public enum CollectibleCatalog {
    public static let launch: [Collectible] = [
        .init(id: "afterglow-lamp", title: "Afterglow Lamp", kind: .light, detail: "A warm porch lamp made from storm glass.", requiredQuestCount: 1, requiredSparks: 15),
        .init(id: "storm-beanie", title: "Storm Beanie", kind: .accessory, detail: "A soft knit cap with a tiny lightning stitch.", requiredQuestCount: 3, requiredSparks: 45),
        .init(id: "harbor-fern", title: "Harbor Fern", kind: .plant, detail: "A rain-loving fern for a restored stoop.", requiredQuestCount: 4, requiredSparks: 65),
        .init(id: "raincoat", title: "Restorer Raincoat", kind: .outfit, detail: "Built for small wins in bad weather.", requiredQuestCount: 5, requiredSparks: 80),
        .init(id: "park-bench", title: "Sunbreak Bench", kind: .decoration, detail: "A polished bench for The Block's park.", requiredQuestCount: 6, requiredSparks: 100),
        .init(id: "main-street-sign", title: "AfterStorm Street Sign", kind: .sign, detail: "A hand-painted sign marking the road back to daylight.", requiredQuestCount: 7, requiredSparks: 120),
        .init(id: "puddle-pup", title: "Puddle Pup", kind: .pet, detail: "A tiny companion that loves restored sidewalks.", requiredQuestCount: 10, requiredSparks: 180),
        .init(id: "golden-hour", title: "Golden Hour", kind: .weather, detail: "A warm after-storm sky treatment.", requiredQuestCount: 15, requiredSparks: 300)
    ]

    public static func unlocked(completedQuestCount: Int, sparks: Int) -> [Collectible] {
        launch.filter { completedQuestCount >= $0.requiredQuestCount && sparks >= $0.requiredSparks }
    }
}
