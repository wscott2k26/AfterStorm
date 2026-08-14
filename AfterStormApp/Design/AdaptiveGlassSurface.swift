import SwiftUI

enum AdaptiveGlassProminence {
    case subtle
    case standard
    case tile
    case hero
    case control

    var highlightOpacity: Double {
        switch self {
        case .subtle: 0.11
        case .standard: 0.18
        case .tile: 0.24
        case .hero: 0.26
        case .control: 0.23
        }
    }

    var glowOpacity: Double {
        switch self {
        case .subtle: 0.05
        case .standard: 0.11
        case .tile: 0.14
        case .hero: 0.20
        case .control: 0.16
        }
    }

    var tintMultiplier: Double {
        switch self {
        case .subtle: 0.82
        case .standard: 0.78
        case .tile: 0.56
        case .hero: 0.72
        case .control: 0.62
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
        let isHero = prominence == .hero
        let isTile = prominence == .tile
        let isControl = prominence == .control

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
                                    visualState.accentPrimary.opacity(isControl ? 0.20 : (isTile ? 0.14 : 0.10)),
                                    .clear,
                                    visualState.accentSecondary.opacity(isTile ? 0.08 : 0.06)
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
                                    .init(color: .white.opacity(isHero ? 0.23 : (isTile ? 0.20 : 0.15)), location: 0.0),
                                    .init(color: visualState.accentPrimary.opacity(isHero ? 0.12 : (isTile ? 0.10 : 0.07)), location: 0.20),
                                    .init(color: .clear, location: 0.48),
                                    .init(color: visualState.accentSecondary.opacity(isTile ? 0.055 : 0.035), location: 1.0)
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
                                    .white.opacity(isHero ? 0.36 : (isTile ? 0.34 : 0.28)),
                                    .white.opacity(0.05),
                                    visualState.accentPrimary.opacity(isTile ? 0.19 : 0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: isTile ? 0.85 : 0.7
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
                                    .white.opacity(isHero ? 0.42 : (isTile ? 0.38 : 0.28)),
                                    visualState.accentSecondary.opacity(isTile ? 0.17 : 0.12),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isHero ? 116 : (isTile ? 102 : 86), height: isTile ? 1.7 : 1.4)
                        .padding(.top, 2.6)
                        .padding(.leading, cornerRadius * 0.72)
                        .blur(radius: 0.35)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(prominence.glowOpacity),
                radius: isHero ? 25 : (isTile ? 21 : 17),
                y: isHero ? 9 : (isTile ? 8 : 7)
            )
            .shadow(
                color: .black.opacity(isHero ? 0.35 : (isTile ? 0.34 : 0.31)),
                radius: isHero ? 30 : (isTile ? 27 : 24),
                y: isHero ? 16 : (isTile ? 14 : 12)
            )
    }

    @ViewBuilder
    private func crystalHighlight(_ shape: RoundedRectangle) -> some View {
        let isHero = prominence == .hero
        let isTile = prominence == .tile

        shape
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(isHero ? 0.72 : (isTile ? 0.64 : 0.56)),
                        visualState.accentPrimary.opacity(isHero ? 0.36 : (isTile ? 0.34 : 0.28)),
                        .white.opacity(0.05),
                        visualState.accentSecondary.opacity(isHero ? 0.24 : (isTile ? 0.22 : 0.18))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isHero ? 1.35 : (isTile ? 1.15 : 1.0)
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
    }
}

private struct HybridGlassTileModifier: ViewModifier {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let cornerRadius: CGFloat
    let selected: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .adaptiveGlass(
                cornerRadius: cornerRadius,
                prominence: selected ? .hero : .tile
            )
            .overlay {
                if !reduceTransparency {
                    ZStack {
                        shape
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(selected ? 0.32 : 0.24),
                                        visualState.accentPrimary.opacity(selected ? 0.18 : 0.12),
                                        visualState.accentSecondary.opacity(selected ? 0.08 : 0.05),
                                        .clear
                                    ],
                                    center: UnitPoint(x: 0.08, y: 0.03),
                                    startRadius: 0,
                                    endRadius: 145
                                )
                            )

                        shape
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(selected ? 0.16 : 0.11), location: 0.00),
                                        .init(color: .clear, location: 0.31),
                                        .init(color: visualState.accentSecondary.opacity(selected ? 0.11 : 0.075), location: 0.67),
                                        .init(color: .clear, location: 1.00)
                                    ],
                                    startPoint: UnitPoint(x: -0.15, y: 0.03),
                                    endPoint: UnitPoint(x: 1.12, y: 1.0)
                                )
                            )
                    }
                    .blendMode(.screen)
                    .allowsHitTesting(false)
                }
            }
            .overlay {
                crystalRim(shape)
            }
            .shadow(
                color: visualState.accentSecondary.opacity(selected ? 0.16 : 0.08),
                radius: selected ? 18 : 12,
                y: selected ? 8 : 6
            )
    }

    @ViewBuilder
    private func crystalRim(_ shape: RoundedRectangle) -> some View {
        ZStack {
            shape
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(selected ? 0.86 : 0.74),
                            visualState.accentPrimary.opacity(selected ? 0.54 : 0.42),
                            .white.opacity(0.08),
                            visualState.accentSecondary.opacity(selected ? 0.34 : 0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selected ? 1.75 : 1.30
                )

            shape
                .inset(by: 2.4)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(selected ? 0.34 : 0.25),
                            .clear,
                            visualState.accentSecondary.opacity(selected ? 0.16 : 0.11)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.65
                )
        }
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

    func hybridGlassTile(
        cornerRadius: CGFloat = 22,
        selected: Bool = false
    ) -> some View {
        modifier(
            HybridGlassTileModifier(
                cornerRadius: cornerRadius,
                selected: selected
            )
        )
    }
}
