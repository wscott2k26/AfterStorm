import SwiftUI

enum AdaptiveGlassProminence {
    case subtle
    case standard
    case hero
    case control

    var highlightOpacity: Double {
        switch self {
        case .subtle: 0.11
        case .standard: 0.18
        case .hero: 0.26
        case .control: 0.21
        }
    }

    var glowOpacity: Double {
        switch self {
        case .subtle: 0.05
        case .standard: 0.11
        case .hero: 0.20
        case .control: 0.15
        }
    }

    var tintMultiplier: Double {
        switch self {
        case .subtle: 0.82
        case .standard: 0.78
        case .hero: 0.72
        case .control: 0.76
        }
    }
}

private struct AdaptiveGlassSurfaceModifier: ViewModifier {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let cornerRadius: CGFloat
    let prominence: AdaptiveGlassProminence

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                ZStack {
                    if reduceTransparency {
                        shape
                            .fill(visualState.glassTint.opacity(0.95))
                    } else {
                        shape
                            .fill(.ultraThinMaterial)
                        shape
                            .fill(visualState.glassTint.opacity(visualState.glassOpacity * prominence.tintMultiplier))
                    }

                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence.highlightOpacity),
                                    visualState.accentPrimary.opacity(prominence == .control ? 0.18 : 0.10),
                                    .clear,
                                    visualState.accentSecondary.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)

                    shape
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(prominence == .hero ? 0.23 : 0.15), location: 0.0),
                                    .init(color: visualState.accentPrimary.opacity(prominence == .hero ? 0.12 : 0.07), location: 0.20),
                                    .init(color: .clear, location: 0.48),
                                    .init(color: visualState.accentSecondary.opacity(0.035), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)

                    shape
                        .inset(by: 1.6)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence == .hero ? 0.36 : 0.28),
                                    .white.opacity(0.05),
                                    visualState.accentPrimary.opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.7
                        )
                }
            }
            .overlay {
                crystalHighlight(shape)
            }
            .overlay(alignment: .topLeading) {
                if !reduceTransparency {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence == .hero ? 0.42 : 0.28),
                                    visualState.accentSecondary.opacity(0.12),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: prominence == .hero ? 116 : 86, height: 1.4)
                        .padding(.top, 2.6)
                        .padding(.leading, cornerRadius * 0.72)
                        .blur(radius: 0.35)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(prominence.glowOpacity),
                radius: prominence == .hero ? 25 : 17,
                y: prominence == .hero ? 9 : 7
            )
            .shadow(
                color: .black.opacity(prominence == .hero ? 0.35 : 0.31),
                radius: prominence == .hero ? 30 : 24,
                y: prominence == .hero ? 16 : 12
            )
    }

    @ViewBuilder
    private func crystalHighlight(_ shape: RoundedRectangle) -> some View {
        shape
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(prominence == .hero ? 0.72 : 0.56),
                        visualState.accentPrimary.opacity(prominence == .hero ? 0.36 : 0.28),
                        .white.opacity(0.05),
                        visualState.accentSecondary.opacity(prominence == .hero ? 0.24 : 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: prominence == .hero ? 1.35 : 1.0
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
    }
}

struct HybridGlassChipStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.afterStormVisualState) private var visualState

    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shape = Capsule(style: .continuous)

        return configuration.label
            .font(.subheadline.weight(selected ? .semibold : .medium))
            .foregroundStyle(selected ? Color.white : Color.white.opacity(0.80))
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(selected ? 0.97 : 0.91))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(selected ? 0.30 : 0.17))
                    }

                    shape.fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(selected ? 0.18 : 0.09),
                                visualState.accentPrimary.opacity(selected ? 0.32 : 0.09),
                                visualState.accentSecondary.opacity(selected ? 0.16 : 0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
                }
            }
            .overlay {
                shape.stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(selected ? 0.66 : 0.30),
                            visualState.accentPrimary.opacity(selected ? 0.48 : 0.16),
                            visualState.accentSecondary.opacity(selected ? 0.24 : 0.09),
                            .white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selected ? 1.1 : 0.8
                )
            }
            .overlay(alignment: .topLeading) {
                if !reduceTransparency {
                    Capsule(style: .continuous)
                        .fill(.white.opacity(selected ? 0.34 : 0.17))
                        .frame(width: selected ? 34 : 24, height: 1)
                        .padding(.leading, 12)
                        .padding(.top, 1.5)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(selected ? 0.23 : 0.06),
                radius: selected ? 11 : 5,
                y: selected ? 5 : 2
            )
            .shadow(color: .black.opacity(selected ? 0.24 : 0.16), radius: 8, y: 4)
            .scaleEffect(reduceMotion ? 1 : (pressed ? 0.965 : 1))
            .brightness(pressed ? -0.02 : 0)
            .animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: pressed)
    }
}

extension View {
    func adaptiveGlass(
        cornerRadius: CGFloat = 24,
        prominence: AdaptiveGlassProminence = .standard
    ) -> some View {
        modifier(
            AdaptiveGlassSurfaceModifier(
                cornerRadius: cornerRadius,
                prominence: prominence
            )
        )
    }

    func adaptiveGlassSurface(
        cornerRadius: CGFloat = 24,
        prominence: AdaptiveGlassProminence = .standard
    ) -> some View {
        adaptiveGlass(cornerRadius: cornerRadius, prominence: prominence)
    }
}
