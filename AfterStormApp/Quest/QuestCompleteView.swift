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
    @State private var burst = false
    @State private var afterPhotoItem: PhotosPickerItem?
    @State private var afterPhotoData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 42)
                ZStack {
                    ForEach(0..<10, id: \.self) { index in
                        Circle().fill(index.isMultiple(of: 2) ? AfterStormTheme.spark : AfterStormTheme.restoredGreen)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: burst && !reduceMotion ? CGFloat(cos(Double(index) * .pi / 5) * 95) : 0,
                                y: burst && !reduceMotion ? CGFloat(sin(Double(index) * .pi / 5) * 95) : 0
                            )
                            .opacity(burst && !reduceMotion ? 0 : 1)
                    }
                    Image(systemName: "bolt.circle.fill").font(.system(size: 100)).foregroundStyle(AfterStormTheme.spark)
                }
                .accessibilityHidden(true)

                Text("You did the thing.").font(.system(size: 36, weight: .black, design: .rounded))
                Text("That’s enough. Now watch what it changed.").foregroundStyle(.secondary)

                #if canImport(UIKit)
                if let data = afterPhotoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .accessibilityLabel("Optional after photo")
                }
                #endif

                PhotosPicker(selection: $afterPhotoItem, matching: .images) {
                    Label(afterPhotoData == nil ? "Add an after photo (optional)" : "Change after photo", systemImage: "photo.badge.plus")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
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
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.85)) { burst = true }
        }
        .onChange(of: afterPhotoItem) { _, item in
            guard let item else { afterPhotoData = nil; return }
            Task { @MainActor in
                afterPhotoData = try? await item.loadTransferable(type: Data.self)
            }
        }
    }
}
