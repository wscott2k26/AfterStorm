import SwiftUI

struct PremiumButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var prominent = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(prominent ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: AfterStormTheme.compactRadius, style: .continuous)
                    .fill(prominent ? AnyShapeStyle(AfterStormTheme.afterglowGradient) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay {
                        RoundedRectangle(cornerRadius: AfterStormTheme.compactRadius, style: .continuous)
                            .stroke(.white.opacity(configuration.isPressed ? 0.35 : 0.18), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.12 : 0.28), radius: configuration.isPressed ? 5 : 16, y: configuration.isPressed ? 2 : 9)
            }
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(reduceMotion ? nil : AfterStormTheme.quickSpring, value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}
