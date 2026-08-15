import SwiftUI

struct StormRevealView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showCopy = false
    let onBegin: () -> Void

    var body: some View {
        ZStack {
            WorldDioramaView(nodes: [], progressSparks: 0, atmosphericOnly: true)
                .ignoresSafeArea()
                .overlay(.black.opacity(0.22))

            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 14) {
                    Text("Every storm leaves something behind.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("But little things can rebuild a world.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                    Button("Begin") {
                        HapticsService.tap()
                        onBegin()
                    }
                    .buttonStyle(PremiumButtonStyle())
                    .padding(.top, 10)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
                .padding(20)
                .opacity(showCopy ? 1 : 0)
                .offset(y: showCopy ? 0 : 28)
            }
        }
        .task {
            if reduceMotion { showCopy = true }
            else { withAnimation(.spring(response: 0.7, dampingFraction: 0.84).delay(0.25)) { showCopy = true } }
        }
    }
}
