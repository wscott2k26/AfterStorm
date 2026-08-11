import AfterStormCore
import PhotosUI
import SwiftUI
import UIKit

struct ScanMyWorldView: View {
    let model: AppSessionModel
    let onQuests: ([Quest]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var showingCamera = false
    @State private var isAnalyzing = false
    @State private var message: String?
    private let sceneService = SceneAnalysisService()
    private let questService = ContextualQuestService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Show me what you’re looking at.").font(.title2.bold()).frame(maxWidth: .infinity, alignment: .leading)
                    Text("AfterStorm will turn the scene into a few small options—not a judgment.")
                        .foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading)

                    ZStack {
                        RoundedRectangle(cornerRadius: 28).fill(.thinMaterial)
                        if let image { Image(uiImage: image).resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius: 28)) }
                        else { VStack(spacing: 12) { Image(systemName: "camera.viewfinder").font(.system(size: 46)); Text("Photo stays temporary").font(.caption).foregroundStyle(.secondary) } }
                    }.frame(height: 310).clipped()

                    HStack {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button { showingCamera = true } label: { Label("Take Photo", systemImage: "camera.fill") }
                                .buttonStyle(.borderedProminent)
                        }
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Choose Photo", systemImage: "photo.fill")
                        }
                        .buttonStyle(.bordered)
                    }

                    if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }

                    Button {
                        guard let image else { return }
                        isAnalyzing = true
                        message = "Finding a few small wins…"
                        Task {
                            let description = await sceneService.describe(image)
                            let context = QuestContext(text: description, source: .photo)
                            do {
                                let quests = try await questService.suggestions(for: context, selectedAreas: model.selectedAreas)
                                await MainActor.run { isAnalyzing = false; onQuests(quests) }
                            } catch {
                                await MainActor.run { isAnalyzing = false; message = "The scan got noisy. Try a clearer photo or Tell AfterStorm instead." }
                            }
                        }
                    } label: {
                        if isAnalyzing { ProgressView().tint(.black) } else { Label("Find My Quests", systemImage: "sparkles") }
                    }
                    .buttonStyle(PremiumButtonStyle())
                    .disabled(image == nil || isAnalyzing)
                    .opacity(image == nil ? 0.5 : 1)
                }.padding(20)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Scan My World")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
            .sheet(isPresented: $showingCamera) { CameraCaptureView { image = $0 } }
            .onChange(of: selectedItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self), let loaded = UIImage(data: data) {
                        await MainActor.run { image = loaded }
                    }
                }
            }
        }
    }
}
