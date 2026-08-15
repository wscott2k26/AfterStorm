import AfterStormCore
import SwiftUI

struct AvatarChoiceView: View {
    @Environment(\.afterStormVisualState) private var visualState
    @State private var selection: AvatarKind?
    let onContinue: (AvatarKind) -> Void

    init(selectedKind: AvatarKind?, onContinue: @escaping (AvatarKind) -> Void) {
        _selection = State(initialValue: selectedKind)
        self.onContinue = onContinue
    }

    var body: some View {
        ZStack {
            AdaptiveStormBackground()

            VStack(alignment: .leading, spacing: 22) {
                Text("Who are you in this world?")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .shadow(color: .black.opacity(0.35), radius: 9, y: 3)
                Text("Human or Stormling — you can make it yours later.")
                    .foregroundStyle(.white.opacity(0.72))

                HStack(spacing: 14) {
                    avatarCard(.human, title: "Human", symbol: "person.crop.circle.fill", accent: AfterStormTheme.afterglow)
                    avatarCard(.stormling, title: "Stormling", symbol: "cloud.bolt.rain.fill", accent: AfterStormTheme.rainBlue)
                }

                Spacer()

                Button("That’s Me") {
                    guard let selection else { return }
                    HapticsService.tap()
                    onContinue(selection)
                }
                .buttonStyle(PremiumButtonStyle())
                .disabled(selection == nil)
                .opacity(selection == nil ? 0.45 : 1)
            }
            .padding(22)
        }
    }

    private func avatarCard(_ kind: AvatarKind, title: String, symbol: String, accent: Color) -> some View {
        let selected = selection == kind

        return Button {
            HapticsService.tap()
            withAnimation(AfterStormTheme.premiumSpring) { selection = kind }
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    RadialGradient(
                        colors: [
                            accent.opacity(selected ? 0.34 : 0.20),
                            visualState.accentPrimary.opacity(selected ? 0.16 : 0.06),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 65
                    )
                    .frame(width: 126, height: 126)

                    Circle().stroke(.white.opacity(0.22), lineWidth: 1).frame(width: 96, height: 96)
                    Image(systemName: symbol)
                        .font(.system(size: 54, weight: .semibold))
                        .foregroundStyle(accent.gradient)
                        .shadow(color: accent.opacity(0.36), radius: selected ? 14 : 7)
                }

                Text(title).font(.title3.weight(.bold))
                Text(kind == .stormling ? "Born from the weather." : "Bring yourself into The Block.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 245)
            .padding(14)
            .adaptiveGlassSurface(cornerRadius: 28, prominence: selected ? .hero : .standard)
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(selected ? visualState.accentPrimary.opacity(0.86) : .clear, lineWidth: selected ? 1.6 : 0)
            }
            .scaleEffect(selected ? 1.02 : 0.985)
            .shadow(color: selected ? visualState.accentPrimary.opacity(0.18) : .clear, radius: 16, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
