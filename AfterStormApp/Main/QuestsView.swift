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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    timeFilters
                    areaFilters

                    if model.isLoadingQuests {
                        ProgressView("Reading the weather…")
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
                    .buttonStyle(PremiumButtonStyle())
                }
                .padding(20)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
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
            Text("Pick a useful win, not an impossible day.")
                .foregroundStyle(.secondary)
        }
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
        }
        .accessibilityLabel("Quest duration filters")
    }

    private func filterButton(_ title: String, value: QuestTimeFilter) -> some View {
        Button(title) { withAnimation(AfterStormTheme.quickSpring) { timeFilter = value } }
            .buttonStyle(.bordered)
            .tint(timeFilter == value ? AfterStormTheme.spark : .secondary)
            .accessibilityAddTraits(timeFilter == value ? .isSelected : [])
    }

    private var areaFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button("All") { selectedArea = nil }
                    .buttonStyle(.bordered)
                    .tint(selectedArea == nil ? AfterStormTheme.rainBlue : .secondary)
                    .accessibilityAddTraits(selectedArea == nil ? .isSelected : [])
                ForEach(model.selectedAreas.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { area in
                    Button { selectedArea = area } label: { Label(area.displayName, systemImage: area.symbolName) }
                        .buttonStyle(.bordered)
                        .tint(selectedArea == area ? AfterStormTheme.rainBlue : .secondary)
                        .accessibilityAddTraits(selectedArea == area ? .isSelected : [])
                }
            }
        }
        .accessibilityLabel("Life area filters")
    }

    @ViewBuilder
    private func questSection(_ title: String, quests: [Quest]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
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
    let quest: Quest
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: quest.lifeArea.symbolName)
                .font(.title3.bold())
                .frame(width: 48, height: 48)
                .background(AfterStormTheme.rainBlue.opacity(0.18), in: RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .leading, spacing: 5) {
                Text(quest.title).font(.headline)
                Text(quest.instruction).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                HStack {
                    Label("\(quest.estimatedMinutes) min", systemImage: "clock")
                    Label("\(quest.sparkReward)", systemImage: "sparkles")
                }
                .font(.caption.bold()).foregroundStyle(AfterStormTheme.spark)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.10)) }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens quest details")
    }
}
