import AfterStormCore
import SwiftUI

struct CollectionView: View {
    let model: AppSessionModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(CollectibleCatalog.launch) { item in
                        let unlocked = model.unlockedCollectibles.contains(item)
                        VStack(alignment: .leading, spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22).fill((unlocked ? AfterStormTheme.afterglow : .gray).opacity(0.15))
                                Image(systemName: symbol(for: item.kind)).font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(unlocked ? AfterStormTheme.spark : .secondary)
                            }.frame(height: 108)
                            Text(unlocked ? item.title : "Locked").font(.headline)
                            Text(unlocked ? item.detail : "\(item.requiredQuestCount) quests • \(item.requiredSparks) Sparks")
                                .font(.caption).foregroundStyle(.secondary).lineLimit(3)
                        }
                        .padding(13)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(unlocked ? item.title : "Locked collectible, unlocks at \(item.requiredQuestCount) quests and \(item.requiredSparks) Sparks")
                    }
                }.padding(18)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Collection")
        }
    }

    private func symbol(for kind: Collectible.Kind) -> String {
        switch kind {
        case .outfit: "tshirt.fill"; case .accessory: "sparkles"; case .decoration: "chair.lounge.fill"
        case .plant: "leaf.fill"; case .light: "lamp.floor.fill"; case .sign: "signpost.right.fill"
        case .pet: "pawprint.fill"; case .weather: "sun.max.fill"
        }
    }
}
