import AfterStormCore
import SwiftUI

struct RestorationRevealView: View {
    let quest: Quest
    let nodes: [RestorationNode]
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.afterStormVisualState) private var visualState
    @State private var revealed = false
    @State private var pulse = false

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
                .scaleEffect(reduceMotion ? 1 : (revealed ? 1.045 : 0.94))
                .brightness(revealed ? 0.07 : -0.16)
                .animation(
                    reduceMotion ? .easeOut(duration: 0.25) : .spring(response: 1.0, dampingFraction: 0.82),
                    value: revealed
                )

            Circle()
                .stroke(
                    visualState.accentPrimary.opacity(pulse ? 0 : 0.72),
                    lineWidth: pulse ? 2 : 14
                )
                .frame(width: pulse ? 520 : 90, height: pulse ? 520 : 90)
                .scaleEffect(pulse ? 1 : 0.35)
                .blur(radius: pulse ? 3 : 0)
                .opacity(reduceMotion ? 0 : 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            Circle()
                .fill(visualState.accentSecondary.opacity(pulse ? 0.02 : 0.30))
                .frame(width: pulse ? 390 : 120, height: pulse ? 390 : 120)
                .blur(radius: 34)
                .opacity(reduceMotion ? 0.12 : 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            RadialGradient(
                colors: [
                    visualState.accentPrimary.opacity(revealed ? 0.12 : 0),
                    visualState.accentSecondary.opacity(revealed ? 0.05 : 0),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.68),
                startRadius: 8,
                endRadius: 330
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            VStack {
                Spacer()
                VStack(spacing: 10) {
                    ZStack {
                        RadialGradient(
                            colors: [
                                visualState.accentPrimary.opacity(0.32),
                                visualState.accentSecondary.opacity(0.10),
                                .clear
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: 48
                        )
                        .frame(width: 92, height: 92)

                        Circle()
                            .stroke(.white.opacity(0.22), lineWidth: 1)
                            .frame(width: 70, height: 70)

                        Image(systemName: "bolt.fill")
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(visualState.accentPrimary)
                            .shadow(color: visualState.accentPrimary.opacity(0.54), radius: 12)
                    }

                    Text("YOU RESTORED")
                        .font(.caption.bold())
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.68))

                    Text(nodeTitle)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)

                    Label("+\(quest.sparkReward) Sparks", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(visualState.accentPrimary)

                    Text("\(reaction.speaker): “\(reaction.message)”")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    Button("See My World") {
                        HapticsService.tap()
                        onContinue()
                    }
                    .buttonStyle(PremiumButtonStyle())
                    .padding(.top, 8)
                }
                .padding(20)
                .adaptiveGlassSurface(cornerRadius: 28, prominence: .hero)
                .padding(16)
            }
            .opacity(revealed ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (revealed ? 0 : 34))
            .animation(
                reduceMotion ? .easeOut(duration: 0.20) : .spring(response: 0.78, dampingFraction: 0.78).delay(0.12),
                value: revealed
            )
        }
        .task {
            if !reduceMotion {
                try? await Task.sleep(for: .milliseconds(220))
            }

            AudioService.shared.playRestoration()
            HapticsService.majorRestoration()

            if reduceMotion {
                revealed = true
                pulse = true
            } else {
                withAnimation(.easeOut(duration: 1.15)) {
                    pulse = true
                }
                withAnimation(.spring(response: 0.88, dampingFraction: 0.80)) {
                    revealed = true
                }
            }
        }
    }
}
