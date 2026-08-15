import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    private let privacyPolicyURL = URL(string: "https://stormandmeofficial.com/afterstorm/privacy")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    privacyCard("Photos stay temporary", "Scan My World analyzes the image you choose for the current request. AfterStorm does not save that photo into its progress database.", "photo.badge.checkmark")
                    privacyCard("Local first", "Your restoration progress is stored on your device first. Managed iCloud sync can keep that progress across your Apple devices when enabled for the app.", "iphone.and.arrow.forward")
                    privacyCard("Voice is optional", "Tell AfterStorm works with typing. Speech recognition is optional and only starts after you grant permission.", "waveform.badge.mic")
                    privacyCard("No shame data", "AfterStorm is designed around small wins. It does not need an advertising profile built from what you struggle with.", "hand.raised.fill")

                    Link(destination: privacyPolicyURL) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.circle.fill")
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Full Privacy Policy")
                                    .font(.headline)
                                Text("Read the complete Storm And Me LLC policy for AfterStorm.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.68))
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "arrow.up.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.72))
                        }
                        .foregroundStyle(.white)
                        .padding(16)
                        .adaptiveGlass(cornerRadius: 22, prominence: .control)
                    }
                    .accessibilityHint("Opens the AfterStorm privacy policy on stormandmeofficial.com")
                }
                .padding(20)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Privacy & Data")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    private func privacyCard(_ title: String, _ detail: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol).font(.title2).foregroundStyle(AfterStormTheme.spark).frame(width: 34)
            VStack(alignment: .leading, spacing: 5) { Text(title).font(.headline); Text(detail).foregroundStyle(.secondary) }
        }
        .padding(16).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
    }
}
