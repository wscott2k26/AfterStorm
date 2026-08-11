import AfterStormCore
import AppIntents
import SwiftUI
import WidgetKit

struct AfterStormWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct AfterStormWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AfterStormWidgetEntry {
        AfterStormWidgetEntry(date: .now, snapshot: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (AfterStormWidgetEntry) -> Void) {
        completion(AfterStormWidgetEntry(date: .now, snapshot: WidgetSnapshotStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AfterStormWidgetEntry>) -> Void) {
        let entry = AfterStormWidgetEntry(date: .now, snapshot: WidgetSnapshotStore.load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct AfterStormWidgetView: View {
    let entry: AfterStormWidgetEntry

    private var restoredFraction: Double {
        guard entry.snapshot.totalStages > 0 else { return 0 }
        return min(1, Double(entry.snapshot.restoredStages) / Double(entry.snapshot.totalStages))
    }

    private var weather: WorldWeatherState {
        WorldWeatherState(restoredStages: entry.snapshot.restoredStages, totalStages: entry.snapshot.totalStages)
    }

    private var weatherPresentation: (title: String, symbol: String) {
        switch weather {
        case .stormy: ("Stormy", "cloud.rain.fill")
        case .clearing: ("Clearing", "cloud.sun.fill")
        case .afterglow: ("Afterglow", "sun.max.fill")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("AFTERSTORM", systemImage: weatherPresentation.symbol).font(.caption.bold())
                Spacer()
                Label("\(entry.snapshot.sparks)", systemImage: "sparkles").font(.caption.bold())
            }
            Text(weatherPresentation.title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(entry.snapshot.completedQuestCount == 0 ? "Restore one small thing." : "\(entry.snapshot.completedQuestCount) real-world wins")
                .font(.headline)
            ProgressView(value: restoredFraction)
            Button(intent: GiveMeAQuestIntent()) {
                Label("Quick Quest", systemImage: "bolt.fill").font(.caption.bold())
            }
            .buttonStyle(.borderedProminent)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct AfterStormHomeWidget: Widget {
    let kind = "com.stormandme.afterstorm.widget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AfterStormWidgetProvider()) { entry in
            AfterStormWidgetView(entry: entry)
        }
        .configurationDisplayName("AfterStorm")
        .description("See your restoration progress and ask for a quick quest.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct AfterStormWidgetBundle: WidgetBundle {
    var body: some Widget { AfterStormHomeWidget() }
}
