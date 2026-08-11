import AfterStormCore
import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var flow = AppFlow()
    @State private var model = AppSessionModel()
    @State private var persistenceLoaded = false
    @State private var introFinishedWhileLoading = false
    @State private var showingScan = false
    @State private var showingTell = false

    var body: some View {
        ZStack {
            AfterStormTheme.worldGradient.ignoresSafeArea()
            content.transition(.opacity.combined(with: .scale(scale: 0.985)))
        }
        .animation(AfterStormTheme.premiumSpring, value: flow.phase)
        .task {
            guard !persistenceLoaded else { return }
            persistenceLoaded = true
            model.attachPersistence(PersistenceService(context: modelContext))
            model.restoreIfAvailable()
            if introFinishedWhileLoading {
                flow.advance(to: model.hasCompletedOnboarding ? .main : .stormReveal)
            }
        }
        .sheet(isPresented: $showingScan) {
            ScanMyWorldView(model: model) { quests in
                model.replaceSuggestions(quests)
                showingScan = false
                flow.advance(to: .firstQuest)
            }
        }
        .sheet(isPresented: $showingTell) {
            TellAfterStormView(model: model) { quests in
                model.replaceSuggestions(quests)
                showingTell = false
                flow.advance(to: .firstQuest)
            }
        }
        .alert("AfterStorm", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "Something interrupted the weather.")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch flow.phase {
        case .studioIntro:
            StudioIntroView {
                if persistenceLoaded {
                    flow.advance(to: model.hasCompletedOnboarding ? .main : .stormReveal)
                } else {
                    introFinishedWhileLoading = true
                }
            }
        case .stormReveal:
            StormRevealView { flow.advance(to: .personalization) }
        case .personalization:
            LifeAreaSelectionView(selectedAreas: model.selectedAreas) { areas in
                model.setAreas(areas); flow.advance(to: .avatar)
            }
        case .avatar:
            AvatarChoiceView(selectedKind: model.avatarKind) { kind in
                model.setAvatarKind(kind); flow.advance(to: .avatarStudio)
            }
        case .avatarStudio:
            AvatarStudioView(kind: model.avatarKind ?? .stormling, initialStyle: model.avatarStyle) { style in
                model.setAvatarStyle(style)
                Task { await model.prepareFirstQuests(); flow.advance(to: .firstQuest) }
            }
        case .firstQuest:
            FirstQuestView(model: model) { quest in model.start(quest); flow.advance(to: .questDetail) }
        case .questDetail:
            if let quest = model.activeQuest {
                QuestDetailView(quest: quest, onStart: { flow.advance(to: .questMode) }, onSwap: {
                    Task { await model.refreshSuggestions(); model.clearActiveQuest(); flow.advance(to: .firstQuest) }
                })
            }
        case .questMode:
            if let quest = model.activeQuest {
                QuestModeView(quest: quest, onEasier: model.makeActiveQuestEasier, onDone: { flow.advance(to: .questComplete) })
            }
        case .questComplete:
            if let quest = model.activeQuest {
                QuestCompleteView(quest: quest) { _ = model.completeActiveQuest(); flow.advance(to: .restorationReveal) }
            }
        case .restorationReveal:
            if let quest = model.lastCompletedQuest {
                RestorationRevealView(quest: quest, nodes: model.restorationNodes) {
                    model.clearActiveQuest(); flow.advance(to: .main)
                }
            }
        case .main:
            MainTabView(
                model: model,
                onGiveQuest: { Task { await model.refreshSuggestions(); flow.advance(to: .firstQuest) } },
                onSelectQuest: { quest in model.start(quest); flow.advance(to: .questDetail) },
                onScan: { showingScan = true },
                onTell: { showingTell = true }
            )
        }
    }
}
