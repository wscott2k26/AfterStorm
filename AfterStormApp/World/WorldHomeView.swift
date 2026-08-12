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

    private var weatherLabel: String {
        switch restorationFraction {
        case ..<0.36: "Stormy"
        case ..<0.76: "Clearing"
        default: "Afterglow"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            WorldDioramaView(nodes: model.restorationNodes, progressSparks: model.progress.sparks)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("THE BLOCK")
                            .font(.caption2.bold())
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.64))
                        Text("\(model.progress.completedQuestCount) restorations • \(weatherLabel)")
                            .font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                    Text("\(Int(restorationFraction * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(AfterStormTheme.spark)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(AfterStormTheme.spark.opacity(0.10), in: Capsule())
                }

                if blockIsRestored {
                    HStack(spacing: 10) {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(AfterStormTheme.spark)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("THE BLOCK IS RESTORED")
                                .font(.caption.bold())
                                .tracking(1)
                            Text("Another damaged district waits beyond the horizon.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityElement(children: .combine)
                }

                Button {
                    HapticsService.tap()
                    onGiveQuest()
                } label: {
                    Label("Give Me a Quest", systemImage: "bolt.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PremiumButtonStyle())

                HStack(spacing: 8) {
                    action("Scan", "camera.viewfinder", onScan)
                    action("Tell", "waveform", onTell)
                    action("Map", "map.fill") { showingMap = true }
                    action("Residents", "person.3.fill") { showingResidents = true }
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .stroke(.white.opacity(0.11), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 18, y: 8)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
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
        Button {
            HapticsService.tap()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 13))
        .tint(.white.opacity(0.74))
    }
}
