import Foundation

public protocol ContextQuestComposing: Sendable {
    func suggestions(for context: QuestContext, selectedAreas: Set<LifeArea>, count: Int) async throws -> [Quest]
}

public actor LocalContextQuestComposer: ContextQuestComposing {
    private let engine: LocalQuestEngine

    public init(seed: Int = 0) {
        self.engine = LocalQuestEngine(seed: seed)
    }

    public func suggestions(for context: QuestContext, selectedAreas: Set<LifeArea>, count: Int) async throws -> [Quest] {
        guard count > 0 else { return [] }
        let allowed = selectedAreas.isEmpty ? Set(LifeArea.allCases) : selectedAreas
        let routed = routeAreas(from: context.text, allowed: allowed)
        let areas = routed.isEmpty ? allowed : routed
        let maxMinutes = resolveMinutes(context)

        var candidates = try await engine.suggestions(for: areas, count: max(count * 4, 12))
        if candidates.count < count, areas != allowed {
            let fallback = try await engine.suggestions(for: allowed, count: max(count * 4, 12))
            let existing = Set(candidates.map(\.title))
            candidates.append(contentsOf: fallback.filter { !existing.contains($0.title) })
        }

        let bounded = candidates.map { quest in
            guard let maxMinutes, quest.estimatedMinutes > maxMinutes else { return quest }
            let ratio = Double(maxMinutes) / Double(max(quest.estimatedMinutes, 1))
            return Quest(
                id: quest.id,
                title: quest.title,
                instruction: "Make it a \(maxMinutes)-minute version: \(quest.instruction)",
                lifeArea: quest.lifeArea,
                estimatedMinutes: maxMinutes,
                sparkReward: max(5, Int((Double(quest.sparkReward) * max(0.5, ratio)).rounded())),
                restorationNodeID: quest.restorationNodeID
            )
        }

        return Array(bounded.prefix(count))
    }

    private func resolveMinutes(_ context: QuestContext) -> Int? {
        if let preferred = context.preferredMinutes { return preferred }
        let lowered = context.text.lowercased()
        if lowered.contains("something easy") || lowered.contains("overwhelmed") || lowered.contains("quick") {
            return 5
        }
        let pattern = #"\b(\d{1,3})\s*(?:min|mins|minute|minutes)\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: lowered, range: NSRange(lowered.startIndex..., in: lowered)),
              let range = Range(match.range(at: 1), in: lowered),
              let value = Int(lowered[range]) else { return nil }
        return max(1, min(value, 120))
    }

    private func routeAreas(from text: String, allowed: Set<LifeArea>) -> Set<LifeArea> {
        let value = text.lowercased()
        var matches = Set<LifeArea>()

        let keywords: [(LifeArea, [String])] = [
            (.home, ["clean", "clutter", "room", "desk", "laundry", "kitchen", "counter", "shelf", "house"]),
            (.work, ["work", "email", "meeting", "project", "report", "coworker", "office"]),
            (.focus, ["focus", "procrast", "overwhelmed", "stuck", "avoiding", "distracted"]),
            (.digital, ["inbox", "screenshot", "notification", "files", "folder", "phone", "digital", "downloads"]),
            (.movement, ["walk", "stretch", "movement", "exercise", "move", "steps"]),
            (.learning, ["read", "study", "learn", "course", "lesson", "book", "practice"]),
            (.lifeAdmin, ["bill", "appointment", "errand", "schedule", "paperwork", "call", "renew", "admin"])
        ]

        for (area, words) in keywords where allowed.contains(area) {
            if words.contains(where: value.contains) { matches.insert(area) }
        }

        // Broad emotional context should not force the focus category if the person
        // has already narrowed their profile; it only narrows when focus is explicitly selected.
        if matches == [.focus], value.contains("overwhelmed"), allowed.count > 1 {
            return allowed
        }
        return matches
    }
}
