import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.afterStormVisualState) private var visualState
    @State private var preferences = ExperiencePreferences.shared
    @State private var showingPlus = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveStormBackground()

                Form {
                    Section {
                        Picker("Experience", selection: intensityBinding) {
                            ForEach(ExperienceIntensity.allCases) { intensity in
                                Text(intensity.displayName).tag(intensity)
                            }
                        }
                        .pickerStyle(.menu)

                        Toggle("Weather & Particles", isOn: boolBinding(\.weatherParticlesEnabled))
                        Toggle("Camera Motion", isOn: boolBinding(\.cameraMotionEnabled))
                        Toggle("Lightning & Flash", isOn: boolBinding(\.lightningEffectsEnabled))
                        Toggle("Avatar Animation", isOn: boolBinding(\.avatarAnimationEnabled))
                    } header: {
                        Text("Experience")
                    } footer: {
                        Text("Cinematic is the full AfterStorm experience. Calm removes nonessential movement, and iPhone Reduce Motion always takes priority.")
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    .listRowBackground(visualState.glassTint.opacity(0.28))

                    Section("Sound & Haptics") {
                        Toggle("Ambience", isOn: boolBinding(\.ambienceEnabled))
                        Toggle("Sound Effects", isOn: boolBinding(\.soundEffectsEnabled))
                        Toggle("Haptics", isOn: boolBinding(\.hapticsEnabled))
                    }
                    .listRowBackground(visualState.glassTint.opacity(0.28))

                    Section("Account & Sync") {
                        Label("Playing on this device", systemImage: "iphone")
                        LabeledContent("World save", value: "iCloud when available")
                        Text("AfterStorm keeps working with local storage if iCloud is unavailable. No account is required to play.")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    .listRowBackground(visualState.glassTint.opacity(0.28))

                    Section("Subscription") {
                        Button {
                            HapticsService.tap()
                            showingPlus = true
                        } label: {
                            Label("AfterStorm+", systemImage: "sparkles.rectangle.stack.fill")
                                .foregroundStyle(visualState.accentPrimary)
                        }
                    }
                    .listRowBackground(visualState.glassTint.opacity(0.28))

                    Section("Privacy & Data") {
                        Button {
                            HapticsService.tap()
                            showingPrivacy = true
                        } label: {
                            Label("Privacy & Data", systemImage: "hand.raised.fill")
                        }
                    }
                    .listRowBackground(visualState.glassTint.opacity(0.28))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .tint(visualState.accentPrimary)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPlus) { AfterStormPlusView() }
            .sheet(isPresented: $showingPrivacy) { PrivacyView() }
        }
    }

    private var intensityBinding: Binding<ExperienceIntensity> {
        Binding(
            get: { preferences.intensity },
            set: { preferences.applyPreset($0) }
        )
    }

    private func boolBinding(_ keyPath: ReferenceWritableKeyPath<ExperiencePreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { preferences[keyPath: keyPath] },
            set: { preferences[keyPath: keyPath] = $0 }
        )
    }
}
