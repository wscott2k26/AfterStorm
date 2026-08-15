import AfterStormCore
import SwiftUI

struct FirstQuestView: View {
    let model: AppSessionModel
    let onSelect: (Quest) -> Void

    var body: some View {
        ZStack {
            AdaptiveStormBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Let’s restore something.")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        Text("Three small wins. Pick the one that feels easiest to start.")
                            .foregroundStyle(.white.opacity(0.76))
                    }
                    .shadow(color: .black.opacity(0.34), radius: 9, y: 3)

                    if model.isLoadingQuests {
                        ProgressView("Reading the weather…")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .adaptiveGlassSurface(cornerRadius: 24, prominence: .standard)
                    } else {
                        ForEach(model.suggestions) { quest in
                            Button {
                                HapticsService.tap()
                                onSelect(quest)
                            } label: {
                                QuestCard(quest: quest)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let message = model.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .padding(12)
                            .adaptiveGlassSurface(cornerRadius: 16, prominence: .subtle)
                    }

                    Button {
                        HapticsService.tap()
                        Task { await model.refreshSuggestions() }
                    } label: {
                        Label("Give Me a Quest", systemImage: "bolt.circle.fill")
                    }
                    .buttonStyle(PremiumButtonStyle(prominent: true))
                }
                .padding(22)
            }
        }
    }
}

private struct QuestCard: View {
    @Environment(\.afterStormVisualState) private var visualState
    let quest: Quest

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.fill")
                .font(.title3.bold())
                .foregroundStyle(visualState.accentPrimary)
                .shadow(color: visualState.accentPrimary.opacity(0.42), radius: 8)
                .frame(width: 58, height: 58)
                .hybridGlassIconWell(cornerRadius: 18)

            VStack(alignment: .leading, spacing: 7) {
                Text(quest.title)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.98))
                HStack(spacing: 10) {
                    Label("\(quest.estimatedMinutes) min", systemImage: "clock")
                    Label("\(quest.sparkReward)", systemImage: "sparkles")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.74))
                Text(quest.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.80))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(visualState.accentSecondary.opacity(0.88))
        }
        .padding(17)
        .adaptiveGlassSurface(cornerRadius: 24, prominence: .standard)
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(visualState.accentPrimary.opacity(0.18), lineWidth: 0.8)
        }
    }
}
