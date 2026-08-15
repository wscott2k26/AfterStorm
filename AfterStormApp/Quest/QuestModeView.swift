import AfterStormCore
import SwiftUI

struct QuestModeView: View {
    let quest: Quest
    let onEasier: () -> Void
    let onDone: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var remainingSeconds: Int
    @State private var isPaused = false

    init(quest: Quest, onEasier: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.quest = quest
        self.onEasier = onEasier
        self.onDone = onDone
        _remainingSeconds = State(initialValue: max(1, quest.estimatedMinutes) * 60)
    }

    private var timerText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timerTaskID: String {
        "\(quest.id.uuidString)-\(quest.estimatedMinutes)-\(isPaused)"
    }

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AfterStormTheme.rainBlue.opacity(0.16))
                    .frame(width: 180, height: 180)
                    .scaleEffect(reduceMotion ? 1 : (breathe ? 1.08 : 0.94))
                Circle().stroke(AfterStormTheme.spark.opacity(0.36), lineWidth: 1).frame(width: 140, height: 140)
                VStack(spacing: 5) {
                    ZStack {
                        Image(systemName: "cloud.fill").font(.system(size: 62)).foregroundStyle(AfterStormTheme.rainBlue.gradient)
                        HStack(spacing: 17) {
                            Circle().fill(.white).frame(width: 7, height: 7)
                            Circle().fill(.white).frame(width: 7, height: 7)
                        }.offset(y: 3)
                    }
                    Text("Nova is working with you").font(.caption2.bold()).foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Nova the Stormling is keeping you company")

            Text(quest.title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                Text(timerText)
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(remainingSeconds == 0 ? AfterStormTheme.afterglow : AfterStormTheme.spark)
                    .accessibilityLabel(remainingSeconds == 0 ? "Timer finished" : "\(remainingSeconds / 60) minutes and \(remainingSeconds % 60) seconds remaining")
                Text(remainingSeconds == 0 ? "Time’s up — finish when you’re ready." : "A guide, not a deadline.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(isPaused ? "Resume" : "Pause") {
                    HapticsService.tap()
                    isPaused.toggle()
                }
                .buttonStyle(HybridGlassChipStyle(selected: isPaused))
                .disabled(remainingSeconds == 0)
            }

            Text(quest.instruction)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()
            Button("I’m Done") {
                HapticsService.questComplete()
                onDone()
            }
            .buttonStyle(PremiumButtonStyle())

            Button("Need Something Easier") {
                HapticsService.tap()
                onEasier()
            }
            .buttonStyle(PremiumButtonStyle(prominent: false))
            .accessibilityHint("Makes this quest shorter without removing your progress")
        }
        .padding(24)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathe = true }
        }
        .onChange(of: quest.estimatedMinutes) { _, newValue in
            remainingSeconds = max(1, newValue) * 60
            isPaused = false
        }
        .onChange(of: remainingSeconds) { oldValue, newValue in
            if oldValue > 0 && newValue == 0 {
                HapticsService.timerFinished()
            }
        }
        .task(id: timerTaskID) {
            guard !isPaused else { return }
            while !Task.isCancelled && remainingSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, !isPaused else { return }
                remainingSeconds = max(0, remainingSeconds - 1)
            }
        }
    }
}
