import AfterStormCore
import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct QuestCompleteView: View {
    let quest: Quest
    let onConfirm: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.afterStormVisualState) private var visualState
    @State private var burst = false
    @State private var afterPhotoItem: PhotosPickerItem?
    @State private var afterPhotoData: Data?

    var body: some View {
        let hasAfterPhoto = afterPhotoData != nil

        return ZStack {
            AdaptiveStormBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 42)

                    ZStack {
                        RadialGradient(
                            colors: [
                                visualState.accentPrimary.opacity(0.34),
                                visualState.accentSecondary.opacity(0.14),
                                .clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 126
                        )
                        .frame(width: 240, height: 240)

                        ForEach(0..<12, id: \.self) { index in
                            Circle()
                                .fill(index.isMultiple(of: 3) ? AfterStormTheme.spark : (index.isMultiple(of: 2) ? visualState.accentPrimary : visualState.accentSecondary))
                                .frame(width: index.isMultiple(of: 3) ? 9 : 7, height: index.isMultiple(of: 3) ? 9 : 7)
                                .offset(
                                    x: burst && !reduceMotion ? CGFloat(cos(Double(index) * .pi / 6) * 104) : 0,
                                    y: burst && !reduceMotion ? CGFloat(sin(Double(index) * .pi / 6) * 104) : 0
                                )
                                .opacity(burst && !reduceMotion ? 0 : 1)
                        }

                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(visualState.accentPrimary)
                            .shadow(color: visualState.accentPrimary.opacity(0.52), radius: 18)
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("You did the thing.")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                        Text("That’s enough. Now watch what it changed.")
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .shadow(color: .black.opacity(0.34), radius: 9, y: 3)

                    #if canImport(UIKit)
                    if let data = afterPhotoData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.22), lineWidth: 1)
                            }
                            .shadow(color: visualState.accentPrimary.opacity(0.14), radius: 18, y: 7)
                            .accessibilityLabel("Optional after photo")
                    }
                    #endif

                    PhotosPicker(selection: $afterPhotoItem, matching: .images) {
                        Label(
                            hasAfterPhoto ? "Change after photo" : "Add an after photo (optional)",
                            systemImage: "photo.badge.plus"
                        )
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .adaptiveGlassSurface(cornerRadius: 18, prominence: .subtle)
                    .buttonStyle(PremiumPressButtonStyle(pressedScale: 0.985, pressedBrightness: -0.012))
                    .accessibilityHint("The photo stays in this screen and is not saved by AfterStorm")

                    Button("I DID IT  ⚡") {
                        AudioService.shared.playQuestComplete()
                        HapticsService.questComplete()
                        onConfirm()
                    }
                    .buttonStyle(PremiumButtonStyle())
                    .padding(.top, 12)
                }
                .padding(24)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.85)) { burst = true }
        }
        .onChange(of: afterPhotoItem) { _, item in
            guard let item else {
                afterPhotoData = nil
                return
            }
            Task { @MainActor in
                afterPhotoData = try? await item.loadTransferable(type: Data.self)
            }
        }
    }
}
