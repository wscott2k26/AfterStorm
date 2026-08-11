import AfterStormCore
import SwiftUI

struct FirstQuestView: View {
    let model: AppSessionModel
    let onSelect: (Quest) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Let’s restore something.")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("Three small wins. Pick the one that feels easiest to start.")
                    .foregroundStyle(.secondary)

                if model.isLoadingQuests {
                    ProgressView("Reading the weather…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                } else {
                    ForEach(model.suggestions) { quest in
                        Button { HapticsService.tap(); onSelect(quest) } label: {
                            QuestCard(quest: quest)
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let message = model.errorMessage {
                    Text(message).font(.footnote).foregroundStyle(.orange)
                }

                Button {
                    HapticsService.tap()
                    Task { await model.refreshSuggestions() }
                } label: {
                    Label("Give Me a Quest", systemImage: "bolt.circle.fill")
                }
                .buttonStyle(PremiumButtonStyle(prominent: false))
            }
            .padding(22)
        }
    }
}

private struct QuestCard: View {
    let quest: Quest
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(AfterStormTheme.spark.opacity(0.16)).frame(width: 58, height: 58)
                Image(systemName: "bolt.fill").foregroundStyle(AfterStormTheme.spark)
            }
            VStack(alignment: .leading, spacing: 7) {
                Text(quest.title).font(.headline)
                HStack(spacing: 10) {
                    Label("\(quest.estimatedMinutes) min", systemImage: "clock")
                    Label("\(quest.sparkReward)", systemImage: "sparkles")
                }.font(.caption).foregroundStyle(.secondary)
                Text(quest.instruction).font(.subheadline).foregroundStyle(.white.opacity(0.72)).lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(17)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.10), lineWidth: 1) }
    }
}
