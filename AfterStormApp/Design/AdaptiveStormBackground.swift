import SwiftUI

struct AdaptiveStormBackground: View {
    @Environment(\.afterStormVisualState) private var visualState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var preferences = ExperiencePreferences.shared
    @State private var drift = false
    @State private var breathe = false
    @State private var lightningGlow = false

    private var motionAllowed: Bool {
        preferences.allowsMotion(systemReduceMotion: reduceMotion)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: visualState.backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image("StormAtmosphere")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .saturation(0.82 + visualState.clearingWeight * 0.12 + visualState.afterglowWeight * 0.06)
                    .contrast(1.08)
                    .brightness(-0.08 * visualState.stormWeight + 0.035 * visualState.afterglowWeight)
                    .opacity(reduceTransparency ? 0.82 : 0.92)
                    .scaleEffect(motionAllowed ? (drift ? 1.045 : 1.025) : 1.025)
                    .offset(
                        x: motionAllowed ? (drift ? 5 : -4) : 0,
                        y: motionAllowed ? (drift ? -3 : 2) : 0
                    )

                LinearGradient(
                    colors: [
                        AfterStormTheme.deepSky.opacity(0.18 + visualState.stormWeight * 0.18),
                        visualState.accentSecondary.opacity(0.05 + visualState.clearingWeight * 0.13),
                        AfterStormTheme.afterglowRose.opacity(visualState.afterglowWeight * 0.14),
                        AfterStormTheme.afterglow.opacity(visualState.afterglowWeight * 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.softLight)

                RadialGradient(
                    colors: [
                        visualState.accentPrimary.opacity(
                            visualState.glowIntensity * (breathe && motionAllowed ? 1.0 : 0.72)
                        ),
                        visualState.accentSecondary.opacity(visualState.glowIntensity * 0.16),
                        .clear
                    ],
                    center: UnitPoint(x: 0.74, y: 0.20),
                    startRadius: 8,
                    endRadius: max(proxy.size.width, proxy.size.height) * 0.70
                )
                .blendMode(.screen)

                atmosphericCloudLayer(size: proxy.size)
                    .opacity(reduceTransparency ? 0.62 : 0.82)

                mist
                    .opacity(reduceTransparency ? 0.32 : 0.58)

                if preferences.weatherParticlesEnabled {
                    rainVeil
                        .opacity(0.13 + visualState.stormWeight * 0.24)
                }

                if preferences.lightningEffectsEnabled {
                    lightningBloom(size: proxy.size)
                }

                LinearGradient(
                    colors: [
                        .clear,
                        AfterStormTheme.deepSky.opacity(0.18 + visualState.stormWeight * 0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                if reduceTransparency {
                    Color.black.opacity(0.08 + visualState.stormWeight * 0.07)
                }
            }
            .clipped()
        }
        .ignoresSafeArea()
        .onAppear { startAtmosphere() }
        .onChange(of: reduceMotion) { _, _ in startAtmosphere() }
        .onChange(of: preferences.intensity) { _, _ in startAtmosphere() }
        .onChange(of: preferences.lightningEffectsEnabled) { _, _ in startAtmosphere() }
        .accessibilityHidden(true)
    }

    private func startAtmosphere() {
        drift = false
        breathe = false
        lightningGlow = false
        guard motionAllowed else { return }

        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
            drift = true
        }
        withAnimation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true)) {
            breathe = true
        }
        if preferences.lightningEffectsEnabled {
            withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
                lightningGlow = true
            }
        }
    }

    private func atmosphericCloudLayer(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let masses: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, Double, CGFloat)] = [
                (0.06, 0.04, 0.56, 0.18, 32, 1.00, 12),
                (0.46, 0.02, 0.62, 0.22, 38, 0.92, -10),
                (0.18, 0.18, 0.72, 0.24, 44, 0.82, 8),
                (0.58, 0.21, 0.58, 0.20, 36, 0.76, -8),
                (-0.06, 0.34, 0.68, 0.20, 46, 0.54, 7),
                (0.52, 0.40, 0.66, 0.18, 48, 0.46, -6)
            ]

            for mass in masses {
                var layer = context
                layer.addFilter(.blur(radius: mass.4))
                let offset = drift && motionAllowed ? mass.6 : -mass.6 * 0.35
                let rect = CGRect(
                    x: canvasSize.width * mass.0 + offset,
                    y: canvasSize.height * mass.1,
                    width: canvasSize.width * mass.2,
                    height: canvasSize.height * mass.3
                )
                let cloudColor = AfterStormTheme.glassSilver.opacity(
                    (0.035 + visualState.stormWeight * 0.085 + visualState.clearingWeight * 0.03) * mass.5
                )
                layer.fill(Path(ellipseIn: rect), with: .color(cloudColor))
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private var mist: some View {
        ZStack {
            Capsule()
                .fill(AfterStormTheme.rainBlue.opacity(0.10 + visualState.stormWeight * 0.10))
                .frame(width: 460, height: 120)
                .blur(radius: 58)
                .offset(x: drift && motionAllowed ? 42 : -26, y: 82)

            Capsule()
                .fill(visualState.accentSecondary.opacity(0.08 + visualState.clearingWeight * 0.10))
                .frame(width: 380, height: 90)
                .blur(radius: 48)
                .offset(x: drift && motionAllowed ? -70 : -30, y: -34)
        }
    }

    private var rainVeil: some View {
        Canvas { context, size in
            for index in 0..<26 {
                let x = CGFloat((index * 47) % 390) / 390 * size.width
                let y = CGFloat((index * 83) % 720) / 720 * size.height
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + 7, y: y + 22))
                context.stroke(path, with: .color(.white.opacity(0.24)), lineWidth: 0.7)
            }
        }
        .blur(radius: 0.25)
    }

    private func lightningBloom(size: CGSize) -> some View {
        RadialGradient(
            colors: [
                Color.white.opacity(lightningGlow && motionAllowed ? 0.09 : 0.02),
                AfterStormTheme.electricBlue.opacity(lightningGlow && motionAllowed ? 0.12 : 0.03),
                .clear
            ],
            center: UnitPoint(x: 0.72, y: 0.10),
            startRadius: 0,
            endRadius: max(size.width, size.height) * 0.42
        )
        .blendMode(.screen)
    }
}
