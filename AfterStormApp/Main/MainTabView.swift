import AfterStormCore
import SwiftUI

struct MainTabView: View {
    @Bindable var model: AppSessionModel
    let onGiveQuest: () -> Void
    let onSelectQuest: (Quest) -> Void
    let onScan: () -> Void
    let onTell: () -> Void

    @State private var selection: Tab = .world

    enum Tab: Hashable { case world, quests, collection, me }

    var body: some View {
        TabView(selection: $selection) {
            WorldHomeView(
                model: model,
                onGiveQuest: onGiveQuest,
                onScan: onScan,
                onTell: onTell
            )
            .tag(Tab.world)
            .tabItem { Label("World", systemImage: "globe.americas.fill") }

            QuestsView(model: model, onSelect: onSelectQuest, onGiveQuest: onGiveQuest)
                .tag(Tab.quests)
                .tabItem { Label("Quests", systemImage: "bolt.fill") }

            CollectionView(model: model)
                .tag(Tab.collection)
                .tabItem { Label("Collection", systemImage: "backpack.fill") }

            MeView(model: model)
                .tag(Tab.me)
                .tabItem { Label("Me", systemImage: "person.crop.circle.fill") }
        }
        .tint(AfterStormTheme.spark)
    }
}
