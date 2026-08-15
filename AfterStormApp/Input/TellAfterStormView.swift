import AfterStormCore
import SwiftUI

struct TellAfterStormView: View {
    let model: AppSessionModel
    let onQuests: ([Quest]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var speech = SpeechInputService()
    @State private var isGenerating = false
    @State private var message: String?
    private let service = ContextualQuestService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("What’s going on?").font(.title2.bold())
                    Text("A sentence is enough. AfterStorm turns it into something small enough to start.").foregroundStyle(.secondary)

                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty { Text("I have ten minutes…\nMy office is a mess…\nI need something easy…").foregroundStyle(.secondary).padding(18).allowsHitTesting(false) }
                        }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack { chip("I have 5 minutes"); chip("I’m overwhelmed"); chip("I need a quick win"); chip("Help me focus") }
                    }

                    Button {
                        Task {
                            await speech.toggle()
                            if !speech.transcript.isEmpty { text = speech.transcript }
                        }
                    } label: {
                        Label(speech.isListening ? "Listening…" : "Speak It", systemImage: speech.isListening ? "waveform.circle.fill" : "mic.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(speech.isListening ? .red : AfterStormTheme.rainBlue)

                    if let speechError = speech.errorMessage { Text(speechError).font(.footnote).foregroundStyle(.secondary) }
                    if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }

                    Button {
                        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        isGenerating = true
                        Task {
                            do {
                                let context = QuestContext(text: text, source: speech.transcript.isEmpty ? .text : .speech)
                                let quests = try await service.suggestions(for: context, selectedAreas: model.selectedAreas)
                                await MainActor.run { isGenerating = false; onQuests(quests) }
                            } catch {
                                await MainActor.run { isGenerating = false; message = "I couldn’t shape that yet. Try saying what you have time or energy for." }
                            }
                        }
                    } label: {
                        if isGenerating { ProgressView().tint(.black) } else { Label("Shape My Quest", systemImage: "bolt.fill") }
                    }
                    .buttonStyle(PremiumButtonStyle())
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                }.padding(20)
            }
            .background(AfterStormTheme.worldGradient.ignoresSafeArea())
            .navigationTitle("Tell AfterStorm")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { speech.stop(); dismiss() } } }
            .onChange(of: speech.transcript) { _, value in if !value.isEmpty { text = value } }
            .onDisappear { speech.stop() }
        }
    }

    private func chip(_ value: String) -> some View {
        Button(value) { HapticsService.tap(); text = value }.buttonStyle(.bordered)
    }
}
