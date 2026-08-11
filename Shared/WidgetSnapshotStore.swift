import Foundation

struct WidgetSnapshot: Codable, Equatable, Sendable {
    var sparks: Int
    var completedQuestCount: Int
    var restoredStages: Int
    var totalStages: Int
    var selectedAreas: [String]
    var updatedAt: Date

    static let empty = WidgetSnapshot(sparks: 0, completedQuestCount: 0, restoredStages: 0, totalStages: 24, selectedAreas: [], updatedAt: .now)
}

enum WidgetSnapshotStore {
    static let suiteName = "group.com.stormandme.afterstorm"
    private static let key = "afterstorm.widget.snapshot.v1"

    static func load() -> WidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: key),
              let value = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else { return .empty }
        return value
    }

    static func save(_ value: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: suiteName), let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
