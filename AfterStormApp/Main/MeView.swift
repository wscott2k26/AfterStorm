import SwiftUI

struct MeView: View {
    @Bindable var model: AppSessionModel
    @State private var showingResidents = false
    @State private var showingPlus = false
    @State private var showingPrivacy = false
    @State private var showingAvatarStudio = false
    @State private var showingLifeAreas = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AvatarPreviewView(kind: model.avatarKind ?? .stormling, style: model.avatarStyle, size: 112)
                    Text(model.avatarKind == .human ? "Restorer" : "Stormling Restorer")
                        .font(.title2.bold())
                    Button("Edit My Look") { showingAvatarStudio = true }
                        .buttonStyle(.bordered)

                    PlayerProgressView(model: model)

                    menuButton("What I’m Restoring", "slider.horizontal.3") { showingLifeAreas = true }
                    menuButton("Residents", "person.3.fill") { showingResidents = true }
                    menuButton("AfterStorm+", "sparkles.rectangle.stack.fill") { showingPlus = true }
                    menuButton("Privacy & Data", "hand.raised.fill") { showingPrivacy = true }
                }.padding(18)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Me")
            .sheet(isPresented: $showingResidents) { ResidentsView(model: model) }
            .sheet(isPresented: $showingPlus) { AfterStormPlusView() }
            .sheet(isPresented: $showingPrivacy) { PrivacyView() }
            .sheet(isPresented: $showingAvatarStudio) {
                AvatarStudioView(
                    kind: model.avatarKind ?? .stormling,
                    initialStyle: model.avatarStyle,
                    unlockedCollectibles: model.unlockedCollectibles
                ) { style in
                    model.setAvatarStyle(style)
                    showingAvatarStudio = false
                }
            }
            .sheet(isPresented: $showingLifeAreas) {
                NavigationStack {
                    LifeAreaSelectionView(selectedAreas: model.selectedAreas) { areas in
                        model.setAreas(areas)
                        showingLifeAreas = false
                    }
                    .navigationTitle("What I’m Restoring")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private func menuButton(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: symbol)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens \(title)")
    }
}
