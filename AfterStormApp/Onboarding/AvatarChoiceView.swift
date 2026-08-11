import AfterStormCore
import SwiftUI

struct AvatarChoiceView: View {
    @State private var selection: AvatarKind?
    let onContinue: (AvatarKind) -> Void

    init(selectedKind: AvatarKind?, onContinue: @escaping (AvatarKind) -> Void) {
        _selection = State(initialValue: selectedKind)
        self.onContinue = onContinue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Who are you in this world?")
                .font(.system(size: 34, weight: .black, design: .rounded))
            Text("Human or Stormling — you can make it yours later.")
                .foregroundStyle(.secondary)

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

    private func avatarCard(_ kind: AvatarKind, title: String, symbol: String, accent: Color) -> some View {
        Button {
            HapticsService.tap()
            withAnimation(AfterStormTheme.premiumSpring) { selection = kind }
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(accent.opacity(0.20)).frame(width: 110, height: 110)
                    Circle().stroke(accent.opacity(0.55), lineWidth: 1).frame(width: 94, height: 94)
                    Image(systemName: symbol).font(.system(size: 54, weight: .semibold)).foregroundStyle(accent)
                }
                Text(title).font(.title3.weight(.bold))
                Text(kind == .stormling ? "Born from the weather." : "Bring yourself into The Block.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 245)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(selection == kind ? accent : .white.opacity(0.10), lineWidth: selection == kind ? 2 : 1)
            }
            .scaleEffect(selection == kind ? 1.02 : 0.985)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection == kind ? .isSelected : [])
    }
}
