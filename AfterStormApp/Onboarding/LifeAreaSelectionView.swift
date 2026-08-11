import AfterStormCore
import SwiftUI

struct LifeAreaSelectionView: View {
    @State private var selection: Set<LifeArea>
    let onContinue: (Set<LifeArea>) -> Void

    init(selectedAreas: Set<LifeArea>, onContinue: @escaping (Set<LifeArea>) -> Void) {
        _selection = State(initialValue: selectedAreas)
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("What needs restoring?")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("Pick as many as you need. AfterStorm will keep the quests small.")
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                    ForEach(LifeArea.allCases, id: \.self) { area in
                        areaButton(area)
                    }
                }

                Button {
                    HapticsService.tap()
                    selection = Set(LifeArea.allCases)
                } label: {
                    Label("Honestly… everything", systemImage: selection.count == LifeArea.allCases.count ? "checkmark.circle.fill" : "tornado")
                }
                .buttonStyle(PremiumButtonStyle(prominent: false))

                Button("Continue") {
                    HapticsService.tap()
                    onContinue(selection)
                }
                .buttonStyle(PremiumButtonStyle())
                .disabled(selection.isEmpty)
                .opacity(selection.isEmpty ? 0.45 : 1)
            }
            .padding(22)
        }
    }

    private func areaButton(_ area: LifeArea) -> some View {
        Button {
            HapticsService.tap()
            if selection.contains(area) { selection.remove(area) } else { selection.insert(area) }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: area.symbol)
                    .font(.title2)
                    .foregroundStyle(selection.contains(area) ? AfterStormTheme.spark : .white.opacity(0.72))
                Text(area.displayName)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .padding(16)
            .background(selection.contains(area) ? .white.opacity(0.15) : .white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(selection.contains(area) ? AfterStormTheme.spark.opacity(0.72) : .white.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection.contains(area) ? .isSelected : [])
    }
}

private extension LifeArea {
    var displayName: String {
        switch self {
        case .home: "Home & clutter"
        case .work: "Work & productivity"
        case .focus: "Focus & procrastination"
        case .digital: "Digital mess"
        case .movement: "Movement & energy"
        case .learning: "Learning & growth"
        case .lifeAdmin: "Errands & life admin"
        }
    }

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
