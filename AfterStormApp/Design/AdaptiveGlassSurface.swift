import SwiftUI

enum AdaptiveGlassProminence {
    case subtle
    case standard
    case hero
    case control

    var highlightOpacity: Double {
        switch self {
        case .subtle: 0.09
        case .standard: 0.14
        case .hero: 0.22
        case .control: 0.18
        }
    }

    var glowOpacity: Double {
        switch self {
        case .subtle: 0.05
        case .standard: 0.09
        case .hero: 0.17
        case .control: 0.14
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
                            .fill(visualState.glassTint.opacity(0.94))
                    } else {
                        shape
                            .fill(.ultraThinMaterial)
                        shape
                            .fill(visualState.glassTint.opacity(visualState.glassOpacity))
                    }

                    shape
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(prominence.highlightOpacity),
                                    visualState.accentPrimary.opacity(prominence == .control ? 0.15 : 0.07),
                                    .clear,
                                    visualState.accentSecondary.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)

                    shape
                        .inset(by: 1.5)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.26),
                                    .white.opacity(0.04),
                                    visualState.accentPrimary.opacity(0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.7
                        )
                }
            }
            .overlay {
                shape
                    .stroke(
                        LinearGradient(
                            colors: [
                                AfterStormTheme.glassEdge.opacity(0.82),
                                visualState.accentSecondary.opacity(0.32),
                                .white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: visualState.accentPrimary.opacity(prominence.glowOpacity),
                radius: prominence == .hero ? 24 : 16,
                y: 7
            )
            .shadow(color: .black.opacity(0.30), radius: 28, y: 14)
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
