import SwiftUI

struct WorldHomeView: View {
    let model: AppSessionModel
    let onGiveQuest: () -> Void
    let onScan: () -> Void
    let onTell: () -> Void
    @State private var showingMap = false
    @State private var showingResidents = false

    private var blockIsRestored: Bool {
        !model.restorationNodes.isEmpty && model.restorationNodes.allSatisfy(\.isFullyRestored)
    }

    private var restorationFraction: Double {
        let restored = model.restorationNodes.reduce(0) { $0 + $1.stage }
        let total = model.restorationNodes.reduce(0) { $0 + $1.maxStage }
        guard total > 0 else { return 0 }
        return min(1, Double(restored) / Double(total))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            WorldDioramaView(nodes: model.restorationNodes, progressSparks: model.progress.sparks)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("THE BLOCK").font(.caption.bold()).tracking(2)
                        Text("\(model.progress.completedQuestCount) restorations made").font(.headline)
                    }
                    Spacer()
                    Label("\(model.progress.sparks)", systemImage: "sparkles")
                        .font(.subheadline.bold()).foregroundStyle(AfterStormTheme.spark)
                }

                if blockIsRestored {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("THE BLOCK IS RESTORED", systemImage: "sun.max.fill")
                            .font(.caption.bold()).tracking(1.5).foregroundStyle(AfterStormTheme.spark)
                        Text("The storm was bigger than we thought.")
                            .font(.headline)
                        Text("A new damaged area waits beyond the horizon.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityElement(children: .combine)
                }

                Button { HapticsService.tap(); onGiveQuest() } label: {
                    Label("Give Me a Quest", systemImage: "bolt.fill")
                }
                .buttonStyle(PremiumButtonStyle())

                HStack(spacing: 10) {
                    action("Scan", "camera.viewfinder", onScan)
                    action("Tell", "waveform", onTell)
                    action("Map", "map.fill") { showingMap = true }
                    action("Residents", "person.3.fill") { showingResidents = true }
                }
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.12), lineWidth: 1) }
            .padding(16)
        }
        .sheet(isPresented: $showingMap) { RestorationMapView(model: model) }
        .sheet(isPresented: $showingResidents) { ResidentsView(model: model) }
        .onAppear { AudioService.shared.updateWorldAmbience(restorationFraction: restorationFraction) }
        .onChange(of: restorationFraction) { _, fraction in
            AudioService.shared.updateWorldAmbience(restorationFraction: fraction)
        }
        .onDisappear { AudioService.shared.stopWorldAmbience() }
    }

    private func action(_ title: String, _ symbol: String, _ action: @escaping () -> Void) -> some View {
        Button { HapticsService.tap(); action() } label: {
            VStack(spacing: 5) { Image(systemName: symbol); Text(title).font(.caption2.bold()) }
                .frame(maxWidth: .infinity).padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .tint(.white.opacity(0.75))
    }
}
