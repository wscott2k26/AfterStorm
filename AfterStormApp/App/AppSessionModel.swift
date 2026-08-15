import AfterStormCore
import Foundation
import Observation

@MainActor
@Observable
final class AppSessionModel {
    private let session: AfterStormSession
    private let questEngine: any QuestEngine
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
        questEngine = engine
        self.contextComposer = contextComposer
        syncFromCore()
    }

    var insights: ProgressInsights {
        ProgressInsights(history: completionHistory, nodes: restorationNodes)
    }

    var restorationFraction: Double {
        let restored = restorationNodes.reduce(0) { $0 + $1.stage }
        let total = max(24, restorationNodes.reduce(0) { $0 + $1.maxStage })
        guard total > 0 else { return 0 }
        return min(1, Double(restored) / Double(total))
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
            let areas = selectedAreas
            let quests = try await questEngine.suggestions(for: areas, count: 3)
            session.replaceSuggestions(quests)
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
            HapticsService.collectibleUnlock()
        }
        persist()
        return activeQuest
    }

    func clearActiveQuest() { activeQuest = nil }

    #if DEBUG
    func seedAcceptanceState(completed: Bool) {
        let areas: Set<LifeArea> = [.home, .focus, .work]
        let quests = [
            Quest(
                id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!,
                title: "Reset one small surface",
                instruction: "Clear one desk, counter, or table for five focused minutes.",
                lifeArea: .home,
                estimatedMinutes: 5,
                sparkReward: 15,
                restorationNodeID: "east-lights"
            ),
            Quest(
                id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002")!,
                title: "Close one open loop",
                instruction: "Finish one small work task you can complete without switching projects.",
                lifeArea: .work,
                estimatedMinutes: 10,
                sparkReward: 20,
                restorationNodeID: "workshop"
            ),
            Quest(
                id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003")!,
                title: "Protect ten minutes",
                instruction: "Silence distractions and stay with one thing until the timer ends.",
                lifeArea: .focus,
                estimatedMinutes: 10,
                sparkReward: 20,
                restorationNodeID: "power-station"
            )
        ]

        let cleanSession = AfterStormSession(engine: LocalQuestEngine())
        cleanSession.configure(areas: areas, avatarKind: .stormling, avatarStyle: .default)
        cleanSession.replaceSuggestions(quests)
        if completed {
            cleanSession.complete(quests[0], at: Date(timeIntervalSince1970: 1_786_464_000))
        }

        session.restore(cleanSession.snapshot())
        session.replaceSuggestions(quests)
        selectedAreas = areas
        avatarKind = .stormling
        avatarStyle = .default
        activeQuest = quests[0]
        lastCompletedQuest = completed ? quests[0] : nil
        hasCompletedOnboarding = completed
        isLoadingQuests = false
        errorMessage = nil
        syncFromCore()
    }
    #endif

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
