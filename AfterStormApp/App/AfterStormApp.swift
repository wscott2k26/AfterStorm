import SwiftData
import SwiftUI

@main
struct AfterStormApp: App {
    private let modelContainer: ModelContainer? = Self.makeModelContainer()

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                RootView().preferredColorScheme(.dark).modelContainer(modelContainer)
            } else {
                StorageRecoveryView().preferredColorScheme(.dark)
            }
        }
    }

    private static func makeModelContainer() -> ModelContainer? {
        let schema = Schema([AppModel.self])

        let cloudConfiguration = ModelConfiguration(
            "AfterStormCloud",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .automatic
        )
        if let cloud = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) { return cloud }

        let localConfiguration = ModelConfiguration(
            "AfterStormLocal",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
        if let local = try? ModelContainer(for: schema, configurations: [localConfiguration]) { return local }

        let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try? ModelContainer(for: schema, configurations: [fallback])
    }
}

private struct StorageRecoveryView: View {
    var body: some View {
        ZStack {
            AfterStormTheme.worldGradient.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "cloud.bolt.fill").font(.system(size: 56)).foregroundStyle(AfterStormTheme.spark)
                Text("The storm interrupted storage.").font(.title2.bold()).multilineTextAlignment(.center)
                Text("AfterStorm couldn't open either iCloud-backed or local persistent storage. Restart the app before continuing so progress isn't temporary.")
                    .foregroundStyle(.secondary).multilineTextAlignment(.center)
            }.padding(30)
        }
    }
}
