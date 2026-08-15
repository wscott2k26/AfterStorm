public protocol QuestEngine: Sendable {
    func suggestions(for areas: Set<LifeArea>, count: Int) async throws -> [Quest]
}
