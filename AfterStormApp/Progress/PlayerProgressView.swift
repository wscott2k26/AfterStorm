import AfterStormCore
import SwiftUI

struct PlayerProgressView: View {
    let model: AppSessionModel

    private var weekCompletions: Int {
        let calendar = Calendar.current
        let startToday = calendar.startOfDay(for: .now)
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: startToday) else { return 0 }
        return model.completionHistory.filter { $0.completedAt >= weekStart }.count
    }

    private var categoryCounts: [(LifeArea, Int)] {
        let grouped = Dictionary(grouping: model.completionHistory, by: \.lifeArea)
        return grouped.map { ($0.key, $0.value.count) }.sorted { lhs, rhs in
            lhs.1 == rhs.1 ? lhs.0.rawValue < rhs.0.rawValue : lhs.1 > rhs.1
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Things You Restored").font(.title2.bold())

            HStack(spacing: 10) {
                metric("This Week", "\(weekCompletions)", "calendar")
                metric("All Time", "\(model.insights.totalQuests)", "checkmark.circle.fill")
                metric("Sparks", "\(model.progress.sparks)", "sparkles")
            }

            HStack(spacing: 10) {
                metric("Areas", "\(model.insights.fullyRestoredAreas)", "house.and.flag.fill")
                metric("Stages", "\(model.insights.totalRestoredStages)", "hammer.fill")
            }

            if !categoryCounts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quest lanes").font(.subheadline.bold())
                    ForEach(categoryCounts.prefix(4), id: \.0) { area, count in
                        HStack {
                            Label(area.displayName, systemImage: area.symbolName)
                            Spacer()
                            Text("\(count)").font(.subheadline.bold()).foregroundStyle(AfterStormTheme.spark)
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.top, 2)
            }

            if let area = model.insights.favoriteLifeArea {
                Label("Most restored lane: \(area.displayName)", systemImage: area.symbolName)
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            if let minutes = model.insights.favoriteQuestMinutes {
                Label("Your sweet spot: about \(minutes) minutes", systemImage: "clock.fill")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            Text(model.completionHistory.isEmpty ? "Your first small win starts the story." : "Welcome back. The storm waited for you.")
                .font(.footnote.weight(.semibold)).foregroundStyle(AfterStormTheme.afterglow)
        }
        .padding(17)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private func metric(_ title: String, _ value: String, _ symbol: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: symbol).foregroundStyle(AfterStormTheme.spark)
            Text(value).font(.title3.bold())
            Text(title).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value)")
    }
}
