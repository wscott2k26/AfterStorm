import SwiftUI

struct StudioIntroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var reveal = false
    @State private var flash = false
    @State private var drift = false
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Circle()
                .fill(AfterStormTheme.stormBlue.opacity(0.48))
                .frame(width: 390, height: 390)
                .blur(radius: 70)
                .offset(x: drift ? 90 : -70, y: -80)

            Circle()
                .fill(AfterStormTheme.rainBlue.opacity(0.32))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: drift ? -90 : 70, y: 70)

            VStack(spacing: 12) {
                ZStack {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 88, weight: .black))
                        .foregroundStyle(.white.opacity(0.92))
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(AfterStormTheme.spark)
                        .offset(y: 30)
                }
                .shadow(color: AfterStormTheme.spark.opacity(flash ? 0.9 : 0.16), radius: flash ? 34 : 8)

                Text("STORM AND ME")
                    .font(.system(size: 29, weight: .black, design: .rounded))
                    .tracking(2.4)
                Text("STUDIOS")
                    .font(.caption.weight(.bold))
                    .tracking(7)
                    .foregroundStyle(.white.opacity(0.62))
            }
            .foregroundStyle(.white)
            .opacity(reveal ? 1 : 0)
            .scaleEffect(reveal ? 1 : 0.88)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Storm and Me Studios")
        .task {
            AudioService.shared.playIntroThunder()
            if reduceMotion {
                reveal = true
                try? await Task.sleep(for: .milliseconds(900))
                onFinished()
                return
            }

            withAnimation(.spring(response: 0.65, dampingFraction: 0.78)) { reveal = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { drift = true }
            try? await Task.sleep(for: .milliseconds(520))
            withAnimation(.easeOut(duration: 0.08)) { flash = true }
            HapticsService.restorationImpact()
            try? await Task.sleep(for: .milliseconds(90))
            withAnimation(.easeIn(duration: 0.22)) { flash = false }
            try? await Task.sleep(for: .milliseconds(950))
            onFinished()
        }
    }
}
