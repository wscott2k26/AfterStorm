import AfterStormCore
import SwiftUI

struct ResidentsView: View {
    let model: AppSessionModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(ResidentCatalog.launch) { resident in
                        let unlocked = model.unlockedResidents.contains(resident)
                        HStack(spacing: 15) {
                            Image(systemName: symbol(for: resident.kind))
                                .font(.title2).frame(width: 54, height: 54)
                                .background((unlocked ? AfterStormTheme.rainBlue : .gray).opacity(0.18), in: Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(unlocked ? resident.name : "Unknown Resident").font(.headline)
                                Text(unlocked ? resident.personality : "Restore more of The Block to meet them.")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                if unlocked { Text(resident.story).font(.caption).foregroundStyle(.white.opacity(0.65)) }
                            }
                            Spacer()
                            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                                .foregroundStyle(unlocked ? AfterStormTheme.restoredGreen : .secondary)
                        }
                        .padding(16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
                    }
                }.padding(18)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Residents")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    private func symbol(for kind: Resident.Kind) -> String {
        switch kind { case .stormling: "cloud.bolt.fill"; case .human: "person.fill"; case .animal: "pawprint.fill" }
    }
}
