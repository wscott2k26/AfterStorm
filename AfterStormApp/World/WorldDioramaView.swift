import AfterStormCore
import SwiftUI
#if canImport(RealityKit)
import RealityKit
#endif
#if canImport(UIKit)
import UIKit
#endif

struct WorldDioramaView: View {
    let nodes: [RestorationNode]
    let progressSparks: Int
    var atmosphericOnly = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var restoredStages: Int { nodes.reduce(0) { $0 + $1.stage } }
    private var totalStages: Int { max(24, nodes.reduce(0) { $0 + $1.maxStage }) }
    private var restorationFraction: Double {
        guard totalStages > 0 else { return 0 }
        return min(1, Double(restoredStages) / Double(totalStages))
    }

    var body: some View {
        ZStack {
            AfterStormTheme.worldGradient
                .brightness(restorationFraction * 0.07)

            #if canImport(RealityKit) && canImport(UIKit) && !targetEnvironment(simulator)
            RealityWorldLayer(restoredStages: restoredStages, totalStages: totalStages)
                .opacity(atmosphericOnly ? 0.20 : 0.40 + restorationFraction * 0.14)
                .id(restoredStages)
                .allowsHitTesting(false)
            #endif

            Circle()
                .fill(AfterStormTheme.afterglow.opacity(0.08 + restorationFraction * 0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 48)
                .offset(x: 150, y: -245)
                .accessibilityHidden(true)

            Circle()
                .fill(AfterStormTheme.rainBlue.opacity(max(0.08, 0.22 - restorationFraction * 0.13)))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -170, y: -120)
                .accessibilityHidden(true)

            VStack {
                Spacer()
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 44)
                        .fill(Color.black.opacity(max(0.16, 0.30 - restorationFraction * 0.10)))
                        .frame(height: 245)
                        .blur(radius: 2)

                    HStack(alignment: .bottom, spacing: 7) {
                        ForEach(0..<7, id: \.self) { index in building(index) }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 38)

                    stageLights
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                }
                .rotation3DEffect(.degrees(reduceMotion ? 0 : 5), axis: (x: 1, y: 0, z: 0))
                .shadow(color: .black.opacity(0.45), radius: 30, y: 18)
                .padding(.horizontal, 10)
                .padding(.bottom, 80)
            }

            if !atmosphericOnly { WorldLifeLayer(restoredStages: restoredStages) }

            if !atmosphericOnly && restoredStages >= totalStages {
                NextDistrictSilhouette()
                    .transition(.opacity)
            }

            if !reduceMotion {
                RainField(intensity: max(0.12, 0.68 - restorationFraction * 0.53))
                    .allowsHitTesting(false)
            } else {
                LinearGradient(colors: [.white.opacity(0.04), .clear], startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .overlay(alignment: .topTrailing) {
            if !atmosphericOnly {
                Label("\(progressSparks)", systemImage: "sparkles")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(18)
                    .accessibilityLabel("\(progressSparks) Sparks")
            }
        }
        .accessibilityValue("The Block is \(Int(restorationFraction * 100)) percent restored")
    }

    private var stageLights: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalStages, id: \.self) { stage in
                Capsule()
                    .fill(stage < restoredStages ? AfterStormTheme.spark : .white.opacity(0.08))
                    .frame(maxWidth: .infinity)
                    .frame(height: stage < restoredStages ? 5 : 3)
                    .shadow(color: stage < restoredStages ? AfterStormTheme.spark.opacity(0.7) : .clear, radius: 4)
            }
        }
        .accessibilityHidden(true)
    }

    private func building(_ index: Int) -> some View {
        let firstStage = index * 3
        let localStage = min(3, max(0, restoredStages - firstStage))
        let restoredAmount = Double(localStage) / 3.0

        return RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        AfterStormTheme.afterglow.opacity(0.18 + restoredAmount * 0.72),
                        AfterStormTheme.stormBlue.opacity(0.92 - restoredAmount * 0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: index.isMultiple(of: 2) ? 43 : 35, height: CGFloat(72 + (index % 3) * 28))
            .overlay(alignment: .top) {
                VStack(spacing: 7) {
                    ForEach(0..<3, id: \.self) { window in
                        let isLit = window < localStage
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isLit ? AfterStormTheme.spark.opacity(0.90) : .white.opacity(0.07))
                            .frame(width: 16, height: 7)
                            .shadow(color: isLit ? AfterStormTheme.spark.opacity(0.55) : .clear, radius: 3)
                    }
                }
                .padding(.top, 12)
            }
    }
}

private struct WorldLifeLayer: View {
    let restoredStages: Int

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if restoredStages >= 4 { life("cloud.fill", x: 0.20, y: 0.68, in: proxy, tint: AfterStormTheme.rainBlue) }
                if restoredStages >= 8 { life("pawprint.fill", x: 0.76, y: 0.74, in: proxy, tint: .white) }
                if restoredStages >= 12 { life("person.fill", x: 0.48, y: 0.70, in: proxy, tint: AfterStormTheme.afterglow) }
                if restoredStages >= 16 { life("leaf.fill", x: 0.86, y: 0.61, in: proxy, tint: AfterStormTheme.restoredGreen) }
                if restoredStages >= 20 { life("bird.fill", x: 0.34, y: 0.48, in: proxy, tint: .white) }
                if restoredStages >= 23 { life("sun.max.fill", x: 0.82, y: 0.20, in: proxy, tint: AfterStormTheme.spark) }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func life(_ symbol: String, x: CGFloat, y: CGFloat, in proxy: GeometryProxy, tint: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 19, weight: .bold))
            .foregroundStyle(tint)
            .padding(7)
            .background(.ultraThinMaterial, in: Circle())
            .position(x: proxy.size.width * x, y: proxy.size.height * y)
            .shadow(color: tint.opacity(0.30), radius: 8)
    }
}

private struct NextDistrictSilhouette: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 4) {
                Text("BEYOND THE BLOCK")
                    .font(.caption2.bold())
                    .tracking(2.2)
                    .foregroundStyle(.white.opacity(0.48))
                HStack(alignment: .bottom, spacing: 3) {
                    ForEach(0..<8, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.12))
                            .frame(width: CGFloat(8 + (index % 2) * 3), height: CGFloat(18 + (index % 4) * 7))
                    }
                }
                .blur(radius: 0.5)
            }
            .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.18)
        }
        .allowsHitTesting(false)
        .accessibilityLabel("A distant damaged district is visible beyond The Block")
    }
}

private struct RainField: View {
    let intensity: Double
    @State private var falling = false

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<34, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(0.18 * intensity))
                    .frame(width: 1.2, height: 18)
                    .rotationEffect(.degrees(12))
                    .position(
                        x: CGFloat((index * 53) % 380),
                        y: falling ? proxy.size.height + CGFloat(index * 8) : -40 - CGFloat(index * 13)
                    )
                    .animation(
                        .linear(duration: 1.15 + Double(index % 7) * 0.06)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index % 11) * 0.04),
                        value: falling
                    )
            }
        }
        .onAppear { falling = true }
        .accessibilityHidden(true)
    }
}

#if canImport(RealityKit) && canImport(UIKit) && !targetEnvironment(simulator)
private struct RealityWorldLayer: View {
    let restoredStages: Int
    let totalStages: Int

    private var fraction: Float {
        guard totalStages > 0 else { return 0 }
        return min(1, Float(restoredStages) / Float(totalStages))
    }

    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "afterstorm-diorama"

            let ground = ModelEntity(
                mesh: .generateBox(size: 4.6),
                materials: [SimpleMaterial(color: UIColor(red: 0.055, green: 0.075 + CGFloat(fraction) * 0.05, blue: 0.095, alpha: 1), isMetallic: false)]
            )
            ground.scale = [1, 0.025, 0.64]
            ground.position = [0, -0.9, 0]
            root.addChild(ground)

            for index in 0..<7 {
                let localStage = min(3, max(0, restoredStages - index * 3))
                let local = CGFloat(localStage) / 3
                let color = UIColor(
                    red: 0.11 + local * 0.72,
                    green: 0.15 + local * 0.42,
                    blue: 0.22 + local * 0.02,
                    alpha: 1
                )
                let building = ModelEntity(
                    mesh: .generateBox(size: 0.52),
                    materials: [SimpleMaterial(color: color, isMetallic: false)]
                )
                let height = Float(0.85 + Double(index % 3) * 0.22)
                building.scale = [0.72, height, 0.72]
                building.position = [Float(index - 3) * 0.48, -0.62 + (height * 0.22), 0]
                root.addChild(building)
            }

            content.add(root)
        }
    }
}
#endif
