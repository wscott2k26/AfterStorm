import AfterStormCore
import SwiftUI

struct QuestsView: View {
    @Bindable var model: AppSessionModel
    let onSelect: (Quest) -> Void
    let onGiveQuest: () -> Void

    @State private var selectedArea: LifeArea?
    @State private var timeFilter: QuestTimeFilter = .any

    private var filtered: [Quest] {
        model.suggestions.filter { quest in
            let matchesArea = selectedArea.map { quest.lifeArea == $0 } ?? true
            return matchesArea && timeFilter.matches(minutes: quest.estimatedMinutes)
        }
    }

    private var continueQuest: Quest? {
        guard let recentArea = model.completionHistory.last?.lifeArea else { return nil }
        return filtered.first(where: { $0.lifeArea == recentArea })
    }

    private var remainingQuests: [Quest] {
        guard let continueQuest else { return filtered }
        return filtered.filter { $0.id != continueQuest.id }
    }

    private var quickWins: [Quest] { remainingQuests.filter { $0.estimatedMinutes <= 5 } }
    private var suggested: [Quest] { remainingQuests.filter { $0.estimatedMinutes > 5 } }

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveStormBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        timeFilters
                        areaFilters

                        if model.isLoadingQuests {
                            ProgressView("Reading the weather…")
                                .tint(.white)
                                .foregroundStyle(.white.opacity(0.86))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 50)
                        } else if filtered.isEmpty {
                            ContentUnavailableView(
                                "No quests in this pocket",
                                systemImage: "cloud.sun",
                                description: Text("Change a filter or ask AfterStorm for a fresh set.")
                            )
                        } else {
                            if let continueQuest {
                                questSection("Continue Something", quests: [continueQuest])
                            }
                            if !quickWins.isEmpty {
                                questSection("Quick Wins", quests: quickWins)
                            }
                            if !suggested.isEmpty {
                                questSection("Suggested for You", quests: suggested)
                            }
                        }

                        Button {
                            HapticsService.tap()
                            onGiveQuest()
                        } label: {
                            Label("Give Me a Quest", systemImage: "bolt.fill")
                        }
                        .buttonStyle(PremiumButtonStyle(prominent: true))
                        .padding(.top, 2)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Quests")
            .task {
                if model.suggestions.isEmpty { await model.refreshSuggestions() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Small enough to start.")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Pick a useful win, not an impossible day.")
                .foregroundStyle(.white.opacity(0.68))
        }
        .shadow(color: .black.opacity(0.24), radius: 8, y: 3)
    }

    private var timeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterButton("Any", value: .any)
                filterButton("2 min", value: .upTo2)
                filterButton("5 min", value: .upTo5)
                filterButton("10 min", value: .upTo10)
                filterButton("20+ min", value: .twentyPlus)
            }
            .padding(.vertical, 3)
        }
        .accessibilityLabel("Quest duration filters")
    }

    private func filterButton(_ title: String, value: QuestTimeFilter) -> some View {
        Button(title) { withAnimation(AfterStormTheme.quickSpring) { timeFilter = value } }
            .buttonStyle(HybridGlassChipStyle(selected: timeFilter == value))
            .accessibilityAddTraits(timeFilter == value ? .isSelected : [])
    }

    private var areaFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button("All") { selectedArea = nil }
                    .buttonStyle(HybridGlassChipStyle(selected: selectedArea == nil))
                    .accessibilityAddTraits(selectedArea == nil ? .isSelected : [])
                ForEach(model.selectedAreas.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { area in
                    Button { selectedArea = area } label: {
                        Label(area.displayName, systemImage: area.symbolName)
                    }
                    .buttonStyle(HybridGlassChipStyle(selected: selectedArea == area))
                    .accessibilityAddTraits(selectedArea == area ? .isSelected : [])
                }
            }
            .padding(.vertical, 3)
        }
        .accessibilityLabel("Life area filters")
    }

    @ViewBuilder
    private func questSection(_ title: String, quests: [Quest]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.90))
                .shadow(color: .black.opacity(0.22), radius: 6, y: 2)
            ForEach(quests) { quest in
                Button { HapticsService.tap(); onSelect(quest) } label: {
                    QuestDiscoveryCard(quest: quest)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct QuestDiscoveryCard: View {
    @Environment(\.afterStormVisualState) private var visualState

    let quest: Quest

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: quest.lifeArea.symbolName)
                .font(.title3.bold())
                .foregroundStyle(.white.opacity(0.94))
                .frame(width: 48, height: 48)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(visualState.accentPrimary.opacity(0.16))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.46),
                                            visualState.accentPrimary.opacity(0.36),
                                            visualState.accentSecondary.opacity(0.10),
                                            .white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.8
                                )
                        }
                        .shadow(color: visualState.accentPrimary.opacity(0.16), radius: 8, y: 3)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(quest.title)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.97))

                Text(quest.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(quest.estimatedMinutes) min", systemImage: "clock")
                    Label("\(quest.sparkReward)", systemImage: "sparkles")
                }
                .font(.caption.bold())
                .foregroundStyle(AfterStormTheme.spark)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.48))
        }
        .padding(16)
        .adaptiveGlass(cornerRadius: 22, prominence: .standard)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens quest details")
    }
}
