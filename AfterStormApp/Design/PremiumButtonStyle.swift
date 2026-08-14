import SwiftUI

struct PremiumButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.afterStormVisualState) private var visualState

    var prominent = true

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: AfterStormTheme.compactRadius, style: .continuous)
        let pressed = configuration.isPressed

        return configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(prominent ? 0.96 : 0.88))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(prominent ? 0.34 : 0.22))
                    }

                    shape.fill(
                        LinearGradient(
                            colors: prominent
                                ? [
                                    visualState.accentPrimary.opacity(pressed ? 0.42 : 0.62),
                                    visualState.accentSecondary.opacity(pressed ? 0.26 : 0.42),
                                    .white.opacity(pressed ? 0.05 : 0.11)
                                ]
                                : [
                                    .white.opacity(pressed ? 0.05 : 0.10),
                                    visualState.accentPrimary.opacity(pressed ? 0.04 : 0.09),
                                    .clear
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)

                    shape.inset(by: 1.4).stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(pressed ? 0.20 : 0.48),
                                visualState.accentSecondary.opacity(pressed ? 0.14 : 0.30),
                                .white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                }
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [
                            AfterStormTheme.glassEdge.opacity(pressed ? 0.48 : 0.82),
                            visualState.accentPrimary.opacity(pressed ? 0.22 : 0.48),
                            .white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
            .shadow(
                color: visualState.accentPrimary.opacity(pressed ? 0.08 : (prominent ? 0.22 : 0.10)),
                radius: pressed ? 7 : 19,
                y: pressed ? 3 : 9
            )
            .shadow(
                color: .black.opacity(pressed ? 0.15 : 0.30),
                radius: pressed ? 6 : 18,
                y: pressed ? 2 : 10
            )
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.965 : 1))
            .brightness(pressed ? -0.025 : 0)
            .animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: pressed)
            .contentShape(Rectangle())
    }
}
