import AfterStormCore
import SwiftUI

struct QuestDetailView: View {
    let quest: Quest
    let onStart: () -> Void
    let onSwap: () -> Void

    private var restorationTarget: String {
        switch quest.restorationNodeID {
        case "east-lights": "East Street Lights"
        case "maple-home": "Maple House"
        case "corner-store": "Corner Store"
        case "workshop": "Workshop"
        case "bridge": "Bridge"
        case "power-station": "Power Station"
        case "main-street": "Main Street"
        case "park": "Park"
        default: "The Block"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer()
            Image(systemName: "bolt.fill")
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(AfterStormTheme.spark)
                .accessibilityHidden(true)
            Text(quest.title).font(.system(size: 40, weight: .black, design: .rounded))
            Text(quest.instruction).font(.title3).foregroundStyle(.white.opacity(0.75))

            VStack(spacing: 12) {
                HStack {
                    Label("\(quest.estimatedMinutes) min", systemImage: "clock.fill")
                    Spacer()
                    Label("+\(quest.sparkReward) Sparks", systemImage: "sparkles")
                }
                Divider().overlay(.white.opacity(0.08))
                HStack {
                    Label("Restores", systemImage: "hammer.fill").foregroundStyle(.secondary)
                    Spacer()
                    Text(restorationTarget).fontWeight(.semibold)
                }
            }
            .font(.subheadline.weight(.semibold))
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

            Spacer()
            Button("Start Quest") {
                HapticsService.questAccepted()
                onStart()
            }
            .buttonStyle(PremiumButtonStyle())

            Button("Swap Quest") {
                HapticsService.tap()
                onSwap()
            }
            .buttonStyle(PremiumButtonStyle(prominent: false))
        }
        .padding(24)
    }
}
