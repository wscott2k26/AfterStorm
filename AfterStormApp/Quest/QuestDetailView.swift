import AfterStormCore
import SwiftUI

struct QuestDetailView: View {
    @Environment(\.afterStormVisualState) private var visualState
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
        ZStack {
            AdaptiveStormBackground()

            VStack(alignment: .leading, spacing: 22) {
                Spacer()

                ZStack {
                    RadialGradient(
                        colors: [visualState.accentPrimary.opacity(0.36), .clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 54
                    )
                    .frame(width: 104, height: 104)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(visualState.accentPrimary)
                        .shadow(color: visualState.accentPrimary.opacity(0.52), radius: 12)
                }
                .accessibilityHidden(true)

                Text(quest.title)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .shadow(color: .black.opacity(0.36), radius: 10, y: 3)
                Text(quest.instruction)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.78))

                VStack(spacing: 12) {
                    HStack {
                        Label("\(quest.estimatedMinutes) min", systemImage: "clock.fill")
                        Spacer()
                        Label("+\(quest.sparkReward) Sparks", systemImage: "sparkles")
                            .foregroundStyle(visualState.accentPrimary)
                    }
                    Divider().overlay(.white.opacity(0.12))
                    HStack {
                        Label("Restores", systemImage: "hammer.fill").foregroundStyle(.white.opacity(0.64))
                        Spacer()
                        Text(restorationTarget).fontWeight(.semibold)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .padding(16)
                .adaptiveGlassSurface(cornerRadius: 20, prominence: .hero)

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
}
