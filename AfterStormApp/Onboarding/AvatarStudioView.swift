import AfterStormCore
import SwiftUI

struct AvatarStudioView: View {
    let kind: AvatarKind
    let initialStyle: AvatarStyle
    let unlockedCollectibles: [Collectible]
    let onContinue: (AvatarStyle) -> Void
    @State private var style: AvatarStyle

    init(
        kind: AvatarKind,
        initialStyle: AvatarStyle,
        unlockedCollectibles: [Collectible] = [],
        onContinue: @escaping (AvatarStyle) -> Void
    ) {
        self.kind = kind
        self.initialStyle = initialStyle
        self.unlockedCollectibles = unlockedCollectibles
        self.onContinue = onContinue
        _style = State(initialValue: initialStyle)
    }

    private var unlockedIDs: Set<String> { Set(unlockedCollectibles.map(\.id)) }
    private var availableOutfits: [AvatarStyle.Outfit] {
        AvatarStyle.Outfit.allCases.filter { $0 != .raincoat || unlockedIDs.contains("raincoat") }
    }
    private var availableAccessories: [AvatarStyle.Accessory] {
        AvatarStyle.Accessory.allCases.filter { $0 != .beanie || unlockedIDs.contains("storm-beanie") }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Make it yours.")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("Quick choices now. More looks unlock as The Block comes back to life.")
                    .foregroundStyle(.secondary)

                AvatarPreviewView(kind: kind, style: style, size: 180)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                picker("Palette", options: AvatarStyle.Palette.allCases, selection: $style.palette) { $0.displayName }

                if kind == .human {
                    picker("Skin tone", options: AvatarStyle.SkinTone.allCases, selection: $style.skinTone) { $0.displayName }
                    picker("Hair", options: AvatarStyle.HairStyle.allCases, selection: $style.hairStyle) { $0.displayName }
                } else {
                    picker("Stormling body", options: AvatarStyle.StormlingBody.allCases, selection: $style.stormlingBody) { $0.displayName }
                    picker("Head shape", options: AvatarStyle.HeadShape.allCases, selection: $style.headShape) { $0.displayName }
                }

                picker("Eyes", options: AvatarStyle.EyeStyle.allCases, selection: $style.eyeStyle) { $0.displayName }
                picker("Outfit", options: availableOutfits, selection: $style.outfit) { $0.displayName }
                picker("Accessory", options: availableAccessories, selection: $style.accessory) { $0.displayName }

                Text("Your look can change later as you unlock more of The Block.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            .padding(22)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AfterStormTheme.spark)
                    Text("Your first look is ready")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.76))
                    Spacer(minLength: 0)
                }

                Button("That’s Me") {
                    HapticsService.unlock()
                    onContinue(style)
                }
                .buttonStyle(PremiumButtonStyle())
                .accessibilityHint("Save this look and continue to your first quest.")
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(AfterStormTheme.spark.opacity(0.26), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.28), radius: 22, y: 8)
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
    }

    private func picker<T: Hashable>(_ title: String, options: [T], selection: Binding<T>, label: @escaping (T) -> String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(label(option)) {
                            HapticsService.tap()
                            withAnimation(AfterStormTheme.quickSpring) { selection.wrappedValue = option }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selection.wrappedValue == option ? AfterStormTheme.rainBlue : .gray.opacity(0.35))
                        .scaleEffect(selection.wrappedValue == option ? 1.035 : 1)
                        .animation(AfterStormTheme.quickSpring, value: selection.wrappedValue == option)
                        .accessibilityAddTraits(selection.wrappedValue == option ? .isSelected : [])
                    }
                }
            }
        }
    }
}
