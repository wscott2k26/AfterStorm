import SwiftUI

struct PremiumPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var pressedScale: CGFloat = 0.982
    var pressedBrightness: Double = -0.018

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? pressedScale : 1))
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .animation(
                reduceMotion ? nil : AfterStormTheme.quickSpring,
                value: configuration.isPressed
            )
    }
}
