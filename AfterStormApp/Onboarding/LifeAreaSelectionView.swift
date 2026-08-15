import AfterStormCore
import SwiftUI

struct LifeAreaSelectionView: View {
    @Environment(\.afterStormVisualState) private var visualState
    @State private var selection: Set<LifeArea>
    let onContinue: (Set<LifeArea>) -> Void

    init(selectedAreas: Set<LifeArea>, onContinue: @escaping (Set<LifeArea>) -> Void) {
        _selection = State(initialValue: selectedAreas)
        self.onContinue = onContinue
    }

    var body: some View {
        ZStack {
            AdaptiveStormBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What needs restoring?")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        Text("Pick as many as you need. AfterStorm will keep the quests small.")
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .textShadowForStorm()

                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                        ForEach(LifeArea.allCases, id: \.self) { area in
                            areaButton(area)
                        }
                    }

                    Button {
                        HapticsService.tap()
                        selection = Set(LifeArea.allCases)
                    } label: {
                        Label(
                            "Honestly… everything",
                            systemImage: selection.count == LifeArea.allCases.count ? "checkmark.circle.fill" : "tornado"
                        )
                    }
                    .buttonStyle(PremiumButtonStyle(prominent: false))
                    .padding(.bottom, 14)
                }
                .padding(22)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 9) {
                HStack(spacing: 7) {
                    Image(systemName: selection.isEmpty ? "sparkles" : "checkmark.circle.fill")
                        .foregroundStyle(selection.isEmpty ? .white.opacity(0.70) : visualState.accentPrimary)
                    Text(selection.isEmpty ? "Choose at least one area to continue" : "\(selection.count) selected")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.90))
                    Spacer(minLength: 0)
                }

                Button("Continue") {
                    HapticsService.tap()
                    onContinue(selection)
                }
                .buttonStyle(PremiumButtonStyle())
                .disabled(selection.isEmpty)
                .opacity(selection.isEmpty ? 0.76 : 1)
            }
            .padding(14)
            .adaptiveGlassSurface(cornerRadius: 26, prominence: .control)
            .shadow(color: visualState.accentSecondary.opacity(0.12), radius: 19, y: 8)
            .padding(.horizontal, 14)
            .padding(.top, 8)
        }
    }

    private func areaButton(_ area: LifeArea) -> some View {
        let selected = selection.contains(area)

        return Button {
            HapticsService.tap()
            withAnimation(AfterStormTheme.quickSpring) {
                if selected {
                    selection.remove(area)
                } else {
                    selection.insert(area)
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                areaIcon(area, selected: selected)

                Text(area.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.97))
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .padding(16)
            .hybridGlassTile(cornerRadius: 22, selected: selected)
            .overlay(alignment: .topTrailing) {
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, visualState.accentPrimary)
                        .shadow(color: visualState.accentPrimary.opacity(0.42), radius: 7)
                        .padding(12)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(selected ? 1.018 : 1)
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func areaIcon(_ area: LifeArea, selected: Bool) -> some View {
        Image(systemName: area.symbol)
            .font(.title3.weight(.semibold))
            .foregroundStyle(selected ? .white : .white.opacity(0.94))
            .frame(width: 43, height: 43)
            .hybridGlassIconWell(cornerRadius: 14, selected: selected)
    }
}

private extension View {
    func textShadowForStorm() -> some View {
        shadow(color: .black.opacity(0.34), radius: 9, y: 3)
    }
}

private extension LifeArea {
    var symbol: String {
        switch self {
        case .home: "house.fill"
        case .work: "briefcase.fill"
        case .focus: "scope"
        case .digital: "rectangle.stack.fill"
        case .movement: "figure.walk"
        case .learning: "book.fill"
        case .lifeAdmin: "checklist"
        }
    }
}
