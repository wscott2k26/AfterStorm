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
        case .standard: 0.22
        case .tile: 0.28
        case .hero: 0.32
        case .control: 0.26
        }
    }

    var glowOpacity: Double {
        switch self {
        case .subtle: 0.05
        case .standard: 0.12
        case .tile: 0.16
        case .hero: 0.22
        case .control: 0.18
        }
    }

    var tintMultiplier: Double {
        switch self {
        case .subtle: 0.78
        case .standard: 0.60
        case .tile: 0.42
        case .hero: 0.54
        case .control: 0.46
        }
    }

    var specularOpacity: Double {
        switch self {
        case .subtle: 0.10
        case .standard: 0.18
        case .tile: 0.23
        case .hero: 0.28
        case .control: 0.22
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
                            .fill(
                                visualState.glassTint.opacity(
                                    visualState.glassOpacity * prominence.tintMultiplier
                                )
                            )
                    }

                    if !reduceTransparency {
                        shape
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(isHero ? 0.29 : (isTile ? 0.25 : (isControl ? 0.23 : 0.20))),
                                        visualState.accentPrimary.opacity(isHero ? 0.16 : (isTile ? 0.14 : 0.11)),
                                        visualState.accentSecondary.opacity(isControl ? 0.08 : 0.055),
                                        .clear
                                    ],
                                    center: UnitPoint(x: 0.04, y: 0.00),
                                    startRadius: 0,
                                    endRadius: isHero ? 230 : (isTile ? 190 : 165)
                                )
                            )
                            .blendMode(.screen)
                    }

                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence.highlightOpacity),
                                    visualState.accentPrimary.opacity(isControl ? 0.20 : (isTile ? 0.15 : 0.11)),
                                    .clear,
                                    visualState.accentSecondary.opacity(isTile ? 0.09 : 0.065)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)

                    shape
                        .inset(by: 1.7)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(isHero ? 0.40 : (isTile ? 0.36 : (isControl ? 0.34 : 0.30))),
                                    .white.opacity(0.05),
                                    visualState.accentPrimary.opacity(isTile ? 0.21 : 0.17),
                                    visualState.accentSecondary.opacity(isControl ? 0.15 : 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isTile ? 0.95 : 0.78
                        )
                }
            }
            .overlay {
                specularBand(shape)
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
                                    .white.opacity(isHero ? 0.48 : (isTile ? 0.43 : 0.34)),
                                    visualState.accentSecondary.opacity(isTile ? 0.20 : 0.14),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isHero ? 126 : (isTile ? 110 : 94), height: isTile ? 1.9 : 1.6)
                        .padding(.top, 2.4)
                        .padding(.leading, cornerRadius * 0.68)
                        .blur(radius: 0.25)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(prominence.glowOpacity),
                radius: isHero ? 27 : (isTile ? 22 : 18),
                y: isHero ? 10 : (isTile ? 8 : 7)
            )
            .shadow(
                color: .black.opacity(isHero ? 0.38 : (isTile ? 0.36 : 0.32)),
                radius: isHero ? 31 : (isTile ? 28 : 24),
                y: isHero ? 17 : (isTile ? 14 : 12)
            )
    }

    @ViewBuilder
    private func specularBand(_ shape: RoundedRectangle) -> some View {
        if !reduceTransparency {
            shape
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: .white.opacity(prominence.specularOpacity * 0.38), location: 0.18),
                            .init(color: .white.opacity(prominence.specularOpacity), location: 0.31),
                            .init(color: visualState.accentPrimary.opacity(prominence.specularOpacity * 0.58), location: 0.43),
                            .init(color: .clear, location: 0.61),
                            .init(color: visualState.accentSecondary.opacity(prominence.specularOpacity * 0.24), location: 0.86),
                            .init(color: .clear, location: 1.00)
                        ],
                        startPoint: UnitPoint(x: -0.18, y: -0.08),
                        endPoint: UnitPoint(x: 1.08, y: 0.90)
                    )
                )
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func crystalHighlight(_ shape: RoundedRectangle) -> some View {
        let isHero = prominence == .hero
        let isTile = prominence == .tile
        let isControl = prominence == .control

        shape
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(isHero ? 0.78 : (isTile ? 0.70 : (isControl ? 0.66 : 0.61))),
                        visualState.accentPrimary.opacity(isHero ? 0.40 : (isTile ? 0.37 : 0.31)),
                        .white.opacity(0.06),
                        visualState.accentSecondary.opacity(isHero ? 0.27 : (isTile ? 0.24 : 0.20))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isHero ? 1.45 : (isTile ? 1.25 : 1.08)
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
                                        .white.opacity(selected ? 0.35 : 0.27),
                                        visualState.accentPrimary.opacity(selected ? 0.20 : 0.14),
                                        visualState.accentSecondary.opacity(selected ? 0.09 : 0.06),
                                        .clear
                                    ],
                                    center: UnitPoint(x: 0.06, y: 0.02),
                                    startRadius: 0,
                                    endRadius: 155
                                )
                            )

                        shape
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: .white.opacity(selected ? 0.19 : 0.14), location: 0.00),
                                        .init(color: .clear, location: 0.28),
                                        .init(color: visualState.accentSecondary.opacity(selected ? 0.12 : 0.085), location: 0.67),
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
                color: visualState.accentSecondary.opacity(selected ? 0.18 : 0.09),
                radius: selected ? 19 : 13,
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
                            .white.opacity(selected ? 0.90 : 0.78),
                            visualState.accentPrimary.opacity(selected ? 0.58 : 0.46),
                            .white.opacity(0.08),
                            visualState.accentSecondary.opacity(selected ? 0.37 : 0.29)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selected ? 1.8 : 1.35
                )

            shape
                .inset(by: 2.4)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(selected ? 0.37 : 0.28),
                            .clear,
                            visualState.accentSecondary.opacity(selected ? 0.18 : 0.13)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.68
                )
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
    }
}

private struct HybridGlassIconWellModifier: ViewModifier {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let cornerRadius: CGFloat
    let selected: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(selected ? 0.98 : 0.94))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(selected ? 0.30 : 0.18))
                    }

                    if !reduceTransparency {
                        shape.fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(selected ? 0.30 : 0.22),
                                    visualState.accentPrimary.opacity(selected ? 0.36 : 0.23),
                                    visualState.accentSecondary.opacity(selected ? 0.15 : 0.09),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.10, y: 0.02),
                                startRadius: 0,
                                endRadius: 62
                            )
                        )
                        .blendMode(.screen)
                    }
                }
            }
            .overlay {
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(selected ? 0.82 : 0.62),
                                visualState.accentPrimary.opacity(selected ? 0.52 : 0.36),
                                .white.opacity(0.06),
                                visualState.accentSecondary.opacity(selected ? 0.30 : 0.19)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: selected ? 1.18 : 0.94
                    )
            }
            .overlay {
                shape
                    .inset(by: 2.0)
                    .stroke(.white.opacity(selected ? 0.24 : 0.14), lineWidth: 0.55)
            }
            .shadow(
                color: visualState.accentPrimary.opacity(selected ? 0.30 : 0.16),
                radius: selected ? 11 : 8,
                y: 4
            )
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
            .foregroundStyle(selected ? Color.white : Color.white.opacity(0.84))
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background {
                ZStack {
                    if reduceTransparency {
                        shape.fill(visualState.glassTint.opacity(selected ? 0.97 : 0.91))
                    } else {
                        shape.fill(.ultraThinMaterial)
                        shape.fill(visualState.glassTint.opacity(selected ? 0.26 : 0.13))
                    }

                    shape.fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(selected ? 0.22 : 0.12),
                                visualState.accentPrimary.opacity(selected ? 0.34 : 0.11),
                                visualState.accentSecondary.opacity(selected ? 0.18 : 0.06),
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
                            .white.opacity(selected ? 0.70 : 0.36),
                            visualState.accentPrimary.opacity(selected ? 0.50 : 0.20),
                            visualState.accentSecondary.opacity(selected ? 0.27 : 0.11),
                            .white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selected ? 1.15 : 0.84
                )
            }
            .overlay(alignment: .topLeading) {
                if !reduceTransparency {
                    Capsule(style: .continuous)
                        .fill(.white.opacity(selected ? 0.38 : 0.20))
                        .frame(width: selected ? 36 : 26, height: 1.15)
                        .padding(.leading, 12)
                        .padding(.top, 1.5)
                        .allowsHitTesting(false)
                }
            }
            .shadow(
                color: visualState.accentPrimary.opacity(selected ? 0.25 : 0.07),
                radius: selected ? 12 : 5,
                y: selected ? 5 : 2
            )
            .shadow(color: .black.opacity(selected ? 0.25 : 0.17), radius: 8, y: 4)
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

    func hybridGlassIconWell(
        cornerRadius: CGFloat = 15,
        selected: Bool = false
    ) -> some View {
        modifier(
            HybridGlassIconWellModifier(
                cornerRadius: cornerRadius,
                selected: selected
            )
        )
    }
}
