import SwiftUI

struct StudioIntroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var preferences = ExperiencePreferences.shared
    @State private var cloudVisible = false
    @State private var lightningVisible = false
    @State private var lightningLocked = false
    @State private var wordmarkVisible = false
    @State private var studiosVisible = false
    @State private var drift = false
    @State private var lightningOffset: CGFloat = -130
    let onFinished: () -> Void

    private var motionAllowed: Bool {
        preferences.allowsMotion(systemReduceMotion: reduceMotion)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Circle()
                .fill(AfterStormTheme.stormBlue.opacity(0.48))
                .frame(width: 390, height: 390)
                .blur(radius: 70)
                .offset(x: motionAllowed && drift ? 90 : -70, y: -80)

            Circle()
                .fill(AfterStormTheme.rainBlue.opacity(0.32))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: motionAllowed && drift ? -90 : 70, y: 70)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AfterStormTheme.spark.opacity(lightningVisible ? 0.24 : (lightningLocked ? 0.08 : 0)))
                        .frame(width: 180, height: 180)
                        .blur(radius: lightningVisible ? 22 : 34)

                    Image(systemName: "cloud.fill")
                        .font(.system(size: 92, weight: .black))
                        .foregroundStyle(.white.opacity(0.94))
                        .shadow(color: AfterStormTheme.rainBlue.opacity(0.36), radius: 24, y: 10)
                        .opacity(cloudVisible ? 1 : 0)
                        .scaleEffect(cloudVisible ? 1 : 0.76)
                        .offset(y: motionAllowed ? (drift ? -2 : 2) : 0)

                    if lightningVisible && preferences.lightningEffectsEnabled {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 68, weight: .black))
                            .foregroundStyle(.white)
                            .shadow(color: .white.opacity(0.92), radius: 16)
                            .shadow(color: AfterStormTheme.spark.opacity(0.95), radius: 28)
                            .offset(y: lightningOffset)
                            .transition(.opacity)
                    }

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(AfterStormTheme.spark)
                        .shadow(color: AfterStormTheme.spark.opacity(lightningLocked ? 0.72 : 0), radius: 18)
                        .offset(y: 20)
                        .opacity(lightningLocked ? 1 : 0)
                        .scaleEffect(lightningLocked ? 1 : 0.58)
                }
                .frame(width: 190, height: 150)

                VStack(spacing: 7) {
                    Text("STORM AND ME")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .tracking(2.4)
                        .opacity(wordmarkVisible ? 1 : 0)
                        .offset(y: wordmarkVisible ? 0 : 10)

                    Text("STUDIOS")
                        .font(.caption.weight(.bold))
                        .tracking(7)
                        .foregroundStyle(.white.opacity(0.62))
                        .opacity(studiosVisible ? 1 : 0)
                        .offset(y: studiosVisible ? 0 : 7)
                }
                .foregroundStyle(.white)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Storm and Me Studios")
        .task {
            guard motionAllowed else {
                cloudVisible = true
                lightningLocked = true
                wordmarkVisible = true
                studiosVisible = true
                try? await Task.sleep(for: .milliseconds(900))
                onFinished()
                return
            }

            withAnimation(.spring(response: 0.62, dampingFraction: 0.82)) {
                cloudVisible = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                drift = true
            }

            try? await Task.sleep(for: .milliseconds(430))

            if preferences.lightningEffectsEnabled {
                AudioService.shared.playIntroThunder()
                lightningOffset = -130
                withAnimation(.easeOut(duration: 0.06)) {
                    lightningVisible = true
                }
                HapticsService.restorationImpact()
                withAnimation(.easeIn(duration: 0.12)) {
                    lightningOffset = -2
                }
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    lightningVisible = false
                    lightningLocked = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.35)) {
                    lightningLocked = true
                }
            }

            try? await Task.sleep(for: .milliseconds(260))
            withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) {
                wordmarkVisible = true
            }
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.easeOut(duration: 0.32)) {
                studiosVisible = true
            }
            try? await Task.sleep(for: .milliseconds(850))
            onFinished()
        }
    }
}
