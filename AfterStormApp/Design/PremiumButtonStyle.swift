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
            .foregroundStyle(prominent ? Color.white : Color.white.opacity(0.91))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(prominent ? 0.96 : 0.90))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(prominent ? 0.25 : 0.14))
                    }

                    if !reduceTransparency {
                        shape.fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(prominent ? (pressed ? 0.18 : 0.30) : (pressed ? 0.11 : 0.20)),
                                    visualState.accentPrimary.opacity(prominent ? (pressed ? 0.24 : 0.36) : (pressed ? 0.09 : 0.17)),
                                    visualState.accentSecondary.opacity(prominent ? (pressed ? 0.12 : 0.20) : 0.07),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.06, y: 0.02),
                                startRadius: 0,
                                endRadius: 170
                            )
                        )
                        .blendMode(.screen)
                    }

                    shape.fill(
                        LinearGradient(
                            colors: prominent
                                ? [
                                    visualState.accentPrimary.opacity(pressed ? 0.34 : 0.50),
                                    visualState.accentSecondary.opacity(pressed ? 0.20 : 0.33),
                                    .white.opacity(pressed ? 0.04 : 0.09),
                                    .clear
                                ]
                                : [
                                    .white.opacity(pressed ? 0.06 : 0.12),
                                    visualState.accentPrimary.opacity(pressed ? 0.05 : 0.11),
                                    visualState.accentSecondary.opacity(pressed ? 0.03 : 0.06),
                                    .clear
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)

                    shape.inset(by: 1.5).stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(pressed ? 0.22 : 0.54),
                                visualState.accentSecondary.opacity(pressed ? 0.15 : 0.32),
                                visualState.accentPrimary.opacity(pressed ? 0.09 : 0.19),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.82
                    )
                }
            }
            .overlay {
                specularBand(shape, pressed: pressed)
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [
                            AfterStormTheme.glassEdge.opacity(pressed ? 0.52 : 0.90),
                            visualState.accentPrimary.opacity(pressed ? 0.24 : 0.52),
                            .white.opacity(0.08),
                            visualState.accentSecondary.opacity(pressed ? 0.13 : 0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: prominent ? 1.18 : 1.0
                )
            }
            .overlay(alignment: .topLeading) {
                if !reduceTransparency {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominent ? (pressed ? 0.26 : 0.48) : (pressed ? 0.16 : 0.31)),
                                    visualState.accentSecondary.opacity(prominent ? 0.19 : 0.11),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: prominent ? 112 : 88, height: 1.7)
                        .padding(.leading, 24)
                        .padding(.top, 2.5)
                        .blur(radius: 0.25)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(pressed ? 0.08 : (prominent ? 0.25 : 0.12)),
                radius: pressed ? 7 : (prominent ? 21 : 15),
                y: pressed ? 3 : 9
            )
            .shadow(
                color: .black.opacity(pressed ? 0.16 : 0.32),
                radius: pressed ? 6 : 19,
                y: pressed ? 2 : 10
            )
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.965 : 1))
            .brightness(pressed ? -0.025 : 0)
            .animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: pressed)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    private func specularBand(_ shape: RoundedRectangle, pressed: Bool) -> some View {
        if !reduceTransparency {
            shape
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: .white.opacity(pressed ? 0.05 : (prominent ? 0.10 : 0.07)), location: 0.19),
                            .init(color: .white.opacity(pressed ? 0.11 : (prominent ? 0.24 : 0.16)), location: 0.32),
                            .init(color: visualState.accentPrimary.opacity(pressed ? 0.08 : (prominent ? 0.18 : 0.10)), location: 0.43),
                            .init(color: .clear, location: 0.62),
                            .init(color: visualState.accentSecondary.opacity(pressed ? 0.03 : 0.07), location: 0.86),
                            .init(color: .clear, location: 1.00)
                        ],
                        startPoint: UnitPoint(x: -0.15, y: -0.12),
                        endPoint: UnitPoint(x: 1.05, y: 0.92)
                    )
                )
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
    }
}
