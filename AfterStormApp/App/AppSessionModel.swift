import AfterStormCore
import Observation

@MainActor
@Observable
final class AppSessionModel {
    private let session: AfterStormSession
    private let contextComposer: any ContextQuestComposing
    private var persistenceService: PersistenceService?

    var selectedAreas: Set<LifeArea> = []
    var avatarKind: AvatarKind?
    var avatarStyle: AvatarStyle = .default
    var suggestions: [Quest] = []
    var activeQuest: Quest?
    var lastCompletedQuest: Quest?
    var progress = PlayerProgress()
    var restorationNodes: [RestorationNode] = []
    var completionHistory: [QuestCompletionRecord] = []
    var isLoadingQuests = false
    var errorMessage: String?
    var hasCompletedOnboarding = false

    init(
        engine: any QuestEngine = LocalQuestEngine(),
        contextComposer: any ContextQuestComposing = LocalContextQuestComposer()
    ) {
        session = AfterStormSession(engine: engine)
        self.contextComposer = contextComposer
        syncFromCore()
    }

    var insights: ProgressInsights {
        ProgressInsights(history: completionHistory, nodes: restorationNodes)
    }

    var unlockedCollectibles: [Collectible] {
        CollectibleCatalog.unlocked(completedQuestCount: progress.completedQuestCount, sparks: progress.sparks)
    }

    var unlockedResidents: [Resident] {
        ResidentCatalog.unlocked(completedQuestCount: progress.completedQuestCount)
    }

    func attachPersistence(_ service: PersistenceService) {
        persistenceService = service
    }

    func restoreIfAvailable() {
        guard let persistenceService else { return }
        do {
            guard let state = try persistenceService.load() else { return }
            session.restore(state.snapshot)
            selectedAreas = state.snapshot.selectedAreas
            avatarKind = state.snapshot.avatarKind
            avatarStyle = state.snapshot.avatarStyle
            hasCompletedOnboarding = state.hasCompletedOnboarding
            syncFromCore()
        } catch {
            errorMessage = "Your saved restoration data couldn’t be reopened. AfterStorm left it untouched instead of overwriting it."
        }
    }

    func setAreas(_ areas: Set<LifeArea>) {
        selectedAreas = areas
        if hasCompletedOnboarding {
            session.updateSelectedAreas(areas)
            persist()
        }
    }
    func setAvatarKind(_ kind: AvatarKind) { avatarKind = kind }

    func setAvatarStyle(_ style: AvatarStyle) {
        avatarStyle = style
        session.updateAvatarStyle(style)
        persist()
    }

    func prepareFirstQuests() async {
        guard let avatarKind, !selectedAreas.isEmpty else { return }
        session.configure(areas: selectedAreas, avatarKind: avatarKind, avatarStyle: avatarStyle)
        persist()
        await refreshSuggestions()
    }

    func refreshSuggestions() async {
        isLoadingQuests = true
        errorMessage = nil
        defer { isLoadingQuests = false }
        do {
            try await session.refreshSuggestions()
            syncFromCore()
        } catch {
            errorMessage = "The storm got noisy. Try those quests again."
        }
    }

    func generateContextualSuggestions(_ context: QuestContext) async {
        isLoadingQuests = true
        errorMessage = nil
        defer { isLoadingQuests = false }
        do {
            let quests = try await contextComposer.suggestions(for: context, selectedAreas: selectedAreas, count: 3)
            session.replaceSuggestions(quests)
            syncFromCore()
        } catch {
            errorMessage = "I couldn't shape that into a quest yet. Try a shorter description."
        }
    }

    func replaceSuggestions(_ quests: [Quest]) {
        session.replaceSuggestions(quests)
        syncFromCore()
    }

    func start(_ quest: Quest) { activeQuest = quest }

    func makeActiveQuestEasier() {
        guard let activeQuest else { return }
        self.activeQuest = session.makeEasier(activeQuest)
    }

    @discardableResult
    func completeActiveQuest() -> Quest? {
        guard let activeQuest else { return nil }
        let unlockCountBefore = unlockedCollectibles.count
        session.complete(activeQuest)
        lastCompletedQuest = activeQuest
        hasCompletedOnboarding = true
        syncFromCore()
        if unlockedCollectibles.count > unlockCountBefore {
            AudioService.shared.playUnlock()
            HapticsService.unlock()
        }
        persist()
        return activeQuest
    }

    func clearActiveQuest() { activeQuest = nil }

    private func persist() {
        guard let persistenceService else { return }
        do {
            try persistenceService.save(snapshot: session.snapshot(), hasCompletedOnboarding: hasCompletedOnboarding)
        } catch {
            errorMessage = "AfterStorm couldn’t save that change yet. Your current screen is still safe; try again before closing the app."
        }
    }

    private func syncFromCore() {
        suggestions = session.suggestions
        progress = session.progress
        restorationNodes = session.restorationNodes
        completionHistory = session.completionHistory
        avatarStyle = session.avatarStyle
    }
}
