import AfterStormCore
import SwiftUI

struct AvatarPreviewView: View {
    let kind: AvatarKind
    let style: AvatarStyle
    var size: CGFloat = 150

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.afterStormVisualState) private var visualState
    @State private var preferences = ExperiencePreferences.shared
    @State private var floating = false
    @State private var blinking = false
    @State private var aura = false

    private var accent: Color {
        switch style.palette {
        case .stormBlue: AfterStormTheme.rainBlue
        case .afterglow: AfterStormTheme.afterglow
        case .forest: AfterStormTheme.restoredGreen
        case .berry: Color(red: 0.72, green: 0.34, blue: 0.66)
        }
    }

    private var animationEnabled: Bool {
        preferences.avatarAnimationEnabled && preferences.allowsMotion(systemReduceMotion: reduceMotion)
    }

    private var motionStrength: CGFloat {
        CGFloat(preferences.cinematicStrength)
    }

    private var animationTaskID: String {
        "\(animationEnabled)-\(preferences.intensity.rawValue)-\(preferences.avatarAnimationEnabled)"
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    visualState.accentPrimary.opacity(aura && animationEnabled ? 0.34 : 0.24),
                    accent.opacity(0.18),
                    visualState.accentSecondary.opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.48, y: 0.40),
                startRadius: 4,
                endRadius: size * 0.70
            )
            .scaleEffect(aura && animationEnabled ? 1.08 : 1)
            .blur(radius: 3)

            Circle()
                .fill(.ultraThinMaterial)
                .opacity(0.44)
                .padding(size * 0.045)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.54),
                            visualState.accentPrimary.opacity(0.58),
                            accent.opacity(0.32),
                            .white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
                .padding(size * 0.045)

            Ellipse()
                .fill(visualState.accentPrimary.opacity(aura && animationEnabled ? 0.18 : 0.10))
                .frame(width: size * 0.58, height: size * 0.13)
                .blur(radius: 12)
                .offset(y: size * 0.32)

            Group {
                if kind == .stormling {
                    StormlingShape(accent: accent, style: style, blink: blinking)
                } else {
                    HumanShape(accent: accent, style: style, blink: blinking)
                }
            }
            .offset(y: animationEnabled ? (floating ? -3 * motionStrength : 2 * motionStrength) : 0)
            .scaleEffect(animationEnabled ? (floating ? 1.012 : 0.996) : 1)
        }
        .frame(width: size, height: size)
        .shadow(
            color: visualState.accentPrimary.opacity(aura && animationEnabled ? 0.34 : 0.20),
            radius: aura && animationEnabled ? 30 : 22,
            y: 8
        )
        .animation(animationEnabled ? .easeInOut(duration: 1.9).repeatForever(autoreverses: true) : .default, value: floating)
        .animation(animationEnabled && preferences.intensity == .cinematic ? .easeInOut(duration: 2.4).repeatForever(autoreverses: true) : .default, value: aura)
        .task(id: animationTaskID) {
            guard animationEnabled else {
                floating = false
                blinking = false
                aura = false
                return
            }

            floating = true
            aura = preferences.intensity == .cinematic

            while !Task.isCancelled && animationEnabled {
                let delay = Int.random(in: 2400...4200)
                try? await Task.sleep(for: .milliseconds(delay))
                guard !Task.isCancelled && animationEnabled else { return }
                withAnimation(.easeOut(duration: 0.08)) { blinking = true }
                try? await Task.sleep(for: .milliseconds(110))
                withAnimation(.easeIn(duration: 0.10)) { blinking = false }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind == .stormling ? "Customized Stormling avatar preview" : "Customized human avatar preview")
    }
}

private struct StormlingShape: View {
    let accent: Color
    let style: AvatarStyle
    let blink: Bool

    private var cloudScale: CGSize {
        switch style.headShape {
        case .round: CGSize(width: 1.0, height: 1.0)
        case .softSquare: CGSize(width: 1.10, height: 0.86)
        case .tall: CGSize(width: 0.88, height: 1.12)
        }
    }

    private var eyeSize: CGFloat {
        switch style.eyeStyle { case .bright: 11; case .calm: 8; case .bold: 13 }
    }

    var body: some View {
        ZStack {
            Image(systemName: "cloud.fill")
                .resizable().scaledToFit()
                .foregroundStyle(accent.gradient)
                .frame(width: 98 * cloudScale.width, height: 70 * cloudScale.height)
                .offset(y: 8)

            if style.stormlingBody == .fluffy {
                ForEach([CGFloat(-42), CGFloat(-28), CGFloat(30), CGFloat(43)], id: \.self) { x in
                    Circle().fill(accent.opacity(0.92)).frame(width: 20, height: 20).offset(x: x, y: 10)
                }
            } else if style.stormlingBody == .rainSpeckled {
                ForEach([CGFloat(-30), CGFloat(-8), CGFloat(18), CGFloat(34)], id: \.self) { x in
                    Circle().fill(.white.opacity(0.34)).frame(width: 4, height: 7).offset(x: x, y: 20 + x.truncatingRemainder(dividingBy: 9))
                }
            }

            Circle()
                .fill(.white.opacity(0.94))
                .frame(width: eyeSize, height: style.eyeStyle == .calm ? 4 : eyeSize)
                .scaleEffect(x: 1, y: blink ? 0.12 : 1)
                .offset(x: -19, y: 4)
            Circle()
                .fill(.white.opacity(0.94))
                .frame(width: eyeSize, height: style.eyeStyle == .calm ? 4 : eyeSize)
                .scaleEffect(x: 1, y: blink ? 0.12 : 1)
                .offset(x: 19, y: 4)
            Capsule().fill(.black.opacity(0.35)).frame(width: 22, height: 4).offset(y: 24)
            accessory
        }
    }

    @ViewBuilder private var accessory: some View {
        switch style.accessory {
        case .none: EmptyView()
        case .beanie: Image(systemName: "beanie.fill").font(.system(size: 38)).foregroundStyle(.white.opacity(0.9)).offset(y: -34)
        case .glasses: Image(systemName: "eyeglasses").font(.system(size: 34, weight: .bold)).foregroundStyle(.black.opacity(0.65)).offset(y: 5)
        case .satchel: Image(systemName: "bag.fill").font(.system(size: 22)).foregroundStyle(.brown).offset(x: 42, y: 28)
        }
    }
}

private struct HumanShape: View {
    let accent: Color
    let style: AvatarStyle
    let blink: Bool

    private var skin: Color {
        switch style.skinTone {
        case .warmLight: Color(red: 0.91, green: 0.72, blue: 0.58)
        case .golden: Color(red: 0.72, green: 0.48, blue: 0.30)
        case .brown: Color(red: 0.45, green: 0.27, blue: 0.17)
        case .deep: Color(red: 0.27, green: 0.16, blue: 0.12)
        }
    }

    private var eyeHeight: CGFloat { style.eyeStyle == .calm ? 3 : (style.eyeStyle == .bold ? 7 : 5) }

    var body: some View {
        ZStack {
            Circle().fill(skin).frame(width: 50, height: 50).offset(y: -32)
            hair
            HStack(spacing: 13) {
                Capsule().fill(.white.opacity(0.92)).frame(width: 7, height: eyeHeight)
                Capsule().fill(.white.opacity(0.92)).frame(width: 7, height: eyeHeight)
            }
            .scaleEffect(x: 1, y: blink ? 0.12 : 1)
            .offset(y: -31)

            RoundedRectangle(cornerRadius: 28).fill(accent.gradient).frame(width: 72, height: 82).offset(y: 33)
            Image(systemName: style.outfit == .raincoat ? "cloud.rain.fill" : style.outfit == .fieldJacket ? "leaf.fill" : "bolt.fill")
                .foregroundStyle(.white.opacity(0.9)).offset(y: 28)

            if style.accessory == .beanie { Image(systemName: "beanie.fill").font(.system(size: 34)).offset(y: -58) }
            if style.accessory == .glasses { Image(systemName: "eyeglasses").font(.system(size: 28, weight: .bold)).offset(y: -30) }
            if style.accessory == .satchel { Image(systemName: "bag.fill").foregroundStyle(.brown).offset(x: 43, y: 28) }
        }
    }

    @ViewBuilder private var hair: some View {
        switch style.hairStyle {
        case .cropped:
            Capsule().fill(.black.opacity(0.82)).frame(width: 45, height: 16).offset(y: -53)
        case .curls:
            HStack(spacing: -3) { ForEach(0..<4, id: \.self) { _ in Circle().fill(.black.opacity(0.82)).frame(width: 16, height: 16) } }.offset(y: -53)
        case .waves:
            Capsule().fill(.black.opacity(0.82)).frame(width: 52, height: 19).rotationEffect(.degrees(-7)).offset(y: -53)
        case .locs:
            HStack(spacing: 4) { ForEach(0..<5, id: \.self) { _ in Capsule().fill(.black.opacity(0.82)).frame(width: 6, height: 31) } }.offset(y: -47)
        }
    }
}
