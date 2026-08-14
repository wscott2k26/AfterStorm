import AfterStormCore
import SwiftUI

struct AvatarStudioView: View {
    @Environment(\.afterStormVisualState) private var visualState
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
        ZStack {
            AdaptiveStormBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Make it yours.")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        Text("Quick choices now. More looks unlock as The Block comes back to life.")
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .shadow(color: .black.opacity(0.34), radius: 9, y: 3)

                    AvatarPreviewView(kind: kind, style: style, size: 190)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)

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
                        .foregroundStyle(.white.opacity(0.64))

                    Color.clear.frame(height: 76)
                }
                .padding(22)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(visualState.accentPrimary)
                    Text("Your first look is ready")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
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
            .adaptiveGlassSurface(cornerRadius: 26, prominence: .control)
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
    }

    private func picker<T: Hashable>(_ title: String, options: [T], selection: Binding<T>, label: @escaping (T) -> String) -> some View {
        let columns = [GridItem(.adaptive(minimum: 88), spacing: 8)]

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .shadow(color: .black.opacity(0.28), radius: 6, y: 2)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(options, id: \.self) { option in
                    let selected = selection.wrappedValue == option

                    Button {
                        HapticsService.tap()
                        withAnimation(AfterStormTheme.quickSpring) {
                            selection.wrappedValue = option
                        }
                    } label: {
                        Text(label(option))
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 9)
                            .adaptiveGlassSurface(cornerRadius: 18, prominence: selected ? .control : .subtle)
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selected ? visualState.accentPrimary.opacity(0.76) : .clear, lineWidth: selected ? 1.2 : 0)
                            }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selected ? .white : .white.opacity(0.78))
                    .scaleEffect(selected ? 1.035 : 1)
                    .shadow(color: selected ? visualState.accentPrimary.opacity(0.18) : .clear, radius: 10, y: 4)
                    .animation(AfterStormTheme.quickSpring, value: selected)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }
}
