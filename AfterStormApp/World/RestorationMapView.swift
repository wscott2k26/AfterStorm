import SwiftUI

struct RestorationMapView: View {
    let model: AppSessionModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(model.restorationNodes.enumerated()), id: \.element.id) { index, node in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle().fill(node.isFullyRestored ? AfterStormTheme.restoredGreen.opacity(0.25) : AfterStormTheme.stormBlue.opacity(0.5))
                                Image(systemName: symbol(for: index)).foregroundStyle(node.isFullyRestored ? AfterStormTheme.restoredGreen : AfterStormTheme.spark)
                            }.frame(width: 50, height: 50)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(node.title).font(.headline)
                                ProgressView(value: Double(node.stage), total: Double(node.maxStage)).tint(AfterStormTheme.spark)
                                Text(node.isFullyRestored ? "Restored" : "Stage \(node.stage) of \(node.maxStage)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(15)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                }.padding(18)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Restoration Map")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    private func symbol(for index: Int) -> String {
        ["lightbulb.fill", "house.fill", "storefront.fill", "hammer.fill", "bridge.fill", "bolt.fill", "road.lanes", "tree.fill"][index % 8]
    }
}
