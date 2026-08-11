import AfterStormCore
import SwiftUI

struct RestorationRevealView: View {
    let quest: Quest
    let nodes: [RestorationNode]
    let onContinue: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var restored = false

    private var nodeTitle: String {
        nodes.first(where: { $0.id == quest.restorationNodeID })?.title ?? "The Block"
    }

    private var reaction: RestorationReaction {
        RestorationReaction(restoredStages: nodes.reduce(0) { $0 + $1.stage })
    }

    var body: some View {
        ZStack {
            WorldDioramaView(nodes: nodes, progressSparks: quest.sparkReward)
                .ignoresSafeArea()
                .scaleEffect(reduceMotion ? 1 : (restored ? 1 : 1.08))
                .brightness(restored ? 0.12 : -0.18)

            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "bolt.fill").font(.system(size: 40, weight: .black)).foregroundStyle(AfterStormTheme.spark)
                    Text("YOU RESTORED").font(.caption.bold()).tracking(3).foregroundStyle(.white.opacity(0.66))
                    Text(nodeTitle).font(.system(size: 32, weight: .black, design: .rounded)).multilineTextAlignment(.center)
                    Label("+\(quest.sparkReward) Sparks", systemImage: "sparkles").font(.headline).foregroundStyle(AfterStormTheme.spark)
                    Text("\(reaction.speaker): “\(reaction.message)”")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                    Button("See My World") { HapticsService.tap(); onContinue() }.buttonStyle(PremiumButtonStyle()).padding(.top, 10)
                }
                .padding(22)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
                .padding(18)
            }
            .opacity(restored ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (restored ? 0 : 28))
        }
        .task {
            if !reduceMotion { try? await Task.sleep(for: .milliseconds(350)) }
            AudioService.shared.playRestoration()
            HapticsService.restorationImpact()
            if reduceMotion { restored = true }
            else { withAnimation(.spring(response: 0.85, dampingFraction: 0.78)) { restored = true } }
        }
    }
}
