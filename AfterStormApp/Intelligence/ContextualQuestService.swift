import AfterStormCore

actor ContextualQuestService {
    private let local = LocalContextQuestComposer()
    private let apple = AppleIntelligenceQuestService()

    func suggestions(for context: QuestContext, selectedAreas: Set<LifeArea>, count: Int = 3) async throws -> [Quest] {
        if #available(iOS 26.0, *) {
            if let intelligent = try? await apple.suggestions(for: context, selectedAreas: selectedAreas, count: count), intelligent.count == count {
                return intelligent
            }
        }
        return try await local.suggestions(for: context, selectedAreas: selectedAreas, count: count)
    }
}
