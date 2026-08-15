import SwiftUI

struct MeView: View {
    @Bindable var model: AppSessionModel
    @Environment(\.afterStormVisualState) private var visualState
    @State private var showingResidents = false
    @State private var showingPlus = false
    @State private var showingPrivacy = false
    @State private var showingSettings = false
    @State private var showingAvatarStudio = false
    @State private var showingLifeAreas = false

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveStormBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            AvatarPreviewView(
                                kind: model.avatarKind ?? .stormling,
                                style: model.avatarStyle,
                                size: 126
                            )

                            Text(model.avatarKind == .human ? "Restorer" : "Stormling Restorer")
                                .font(.title2.bold())
                                .shadow(color: .black.opacity(0.32), radius: 8, y: 3)

                            Button("Edit My Look") {
                                HapticsService.tap()
                                showingAvatarStudio = true
                            }
                            .buttonStyle(PremiumButtonStyle(prominent: false))
                        }
                        .padding(16)
                        .adaptiveGlassSurface(cornerRadius: 28, prominence: .hero)

                        PlayerProgressView(model: model)
                            .padding(12)
                            .adaptiveGlassSurface(cornerRadius: 24, prominence: .standard)

                        menuButton("What I’m Restoring", "slider.horizontal.3") { showingLifeAreas = true }
                        menuButton("Residents", "person.3.fill") { showingResidents = true }
                        menuButton("Settings", "gearshape.fill") { showingSettings = true }
                        menuButton("AfterStorm+", "sparkles.rectangle.stack.fill") { showingPlus = true }
                        menuButton("Privacy & Data", "hand.raised.fill") { showingPrivacy = true }
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Me")
            .tint(visualState.accentPrimary)
            .sheet(isPresented: $showingResidents) { ResidentsView(model: model) }
            .sheet(isPresented: $showingSettings) { SettingsView() }
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
        Button {
            HapticsService.tap()
            action()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(visualState.accentPrimary.opacity(0.11))
                        .frame(width: 34, height: 34)
                    Image(systemName: symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(visualState.accentPrimary)
                }
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(visualState.accentSecondary.opacity(0.82))
            }
            .padding(16)
            .adaptiveGlassSurface(cornerRadius: 20, prominence: .standard)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens \(title)")
    }
}
