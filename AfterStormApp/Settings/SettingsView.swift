import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var preferences = ExperiencePreferences.shared
    @State private var showingPlus = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack {
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
                }

                Section("Sound & Haptics") {
                    Toggle("Ambience", isOn: boolBinding(\.ambienceEnabled))
                    Toggle("Sound Effects", isOn: boolBinding(\.soundEffectsEnabled))
                    Toggle("Haptics", isOn: boolBinding(\.hapticsEnabled))
                }

                Section("Account & Sync") {
                    Label("Playing on this device", systemImage: "iphone")
                    LabeledContent("World save", value: "iCloud when available")
                    Text("AfterStorm keeps working with local storage if iCloud is unavailable. No account is required to play.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Subscription") {
                    Button {
                        showingPlus = true
                    } label: {
                        Label("AfterStorm+", systemImage: "sparkles.rectangle.stack.fill")
                    }
                }

                Section("Privacy & Data") {
                    Button {
                        showingPrivacy = true
                    } label: {
                        Label("Privacy & Data", systemImage: "hand.raised.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
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
