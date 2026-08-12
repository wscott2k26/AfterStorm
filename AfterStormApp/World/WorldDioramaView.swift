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
    private var weather: WorldWeatherState { WorldWeatherState(fraction: restorationFraction) }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                weather.skyGradient
                    .brightness(weather.ambientBrightness)
                    .ignoresSafeArea()

                CloudShelf(weather: weather)
                    .opacity(atmosphericOnly ? 0.48 : 1)

                Circle()
                    .fill(AfterStormTheme.afterglow.opacity(weather.sunOpacity))
                    .frame(width: 250, height: 250)
                    .blur(radius: 44)
                    .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.16)
                    .accessibilityHidden(true)

                #if canImport(RealityKit) && canImport(UIKit) && !targetEnvironment(simulator)
                RealityWorldLayer(restoredStages: restoredStages, totalStages: totalStages)
                    .opacity(atmosphericOnly ? 0.12 : 0.25 + restorationFraction * 0.16)
                    .id(restoredStages)
                    .allowsHitTesting(false)
                #endif

                PremiumBlockScene(
                    restoredStages: restoredStages,
                    totalStages: totalStages,
                    restorationFraction: restorationFraction,
                    weather: weather,
                    reduceMotion: reduceMotion
                )
                .frame(
                    width: proxy.size.width * (atmosphericOnly ? 0.90 : 0.98),
                    height: min(CGFloat(430), proxy.size.height * (atmosphericOnly ? 0.42 : 0.54))
                )
                .position(
                    x: proxy.size.width * 0.5,
                    y: proxy.size.height * (atmosphericOnly ? 0.70 : 0.52)
                )
                .opacity(atmosphericOnly ? 0.44 : 1)

                if !atmosphericOnly {
                    WorldLifeLayer(restoredStages: restoredStages, reduceMotion: reduceMotion)
                }

                if !atmosphericOnly && restoredStages >= totalStages {
                    NextDistrictSilhouette()
                        .transition(.opacity)
                }

                if !reduceMotion && weather.rainIntensity > 0.03 {
                    RainField(intensity: weather.rainIntensity)
                        .allowsHitTesting(false)
                } else if weather.rainIntensity > 0.03 {
                    LinearGradient(
                        colors: [.white.opacity(0.035 * weather.rainIntensity), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AfterStormTheme.deepSky.opacity(weather.foregroundHazeOpacity)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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
                    .padding(.top, 18)
                    .padding(.trailing, 18)
                    .accessibilityLabel("\(progressSparks) Sparks")
            }
        }
        .accessibilityValue("The Block is \(Int(restorationFraction * 100)) percent restored and the weather is \(weather.accessibilityName)")
    }
}

private enum WorldWeatherState {
    case stormy
    case clearing
    case afterglow

    init(fraction: Double) {
        switch fraction {
        case ..<0.36: self = .stormy
        case ..<0.76: self = .clearing
        default: self = .afterglow
        }
    }

    var skyGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .stormy:
            colors = [AfterStormTheme.deepSky, AfterStormTheme.stormBlue, AfterStormTheme.rainBlue.opacity(0.72)]
        case .clearing:
            colors = [AfterStormTheme.deepSky.opacity(0.92), AfterStormTheme.clearingSky, AfterStormTheme.rainBlue.opacity(0.55)]
        case .afterglow:
            colors = [AfterStormTheme.deepSky.opacity(0.88), AfterStormTheme.afterglowSky, AfterStormTheme.duskRose.opacity(0.82), AfterStormTheme.afterglow.opacity(0.36)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var rainIntensity: Double {
        switch self {
        case .stormy: 0.72
        case .clearing: 0.28
        case .afterglow: 0.035
        }
    }

    var cloudOpacity: Double {
        switch self {
        case .stormy: 0.82
        case .clearing: 0.48
        case .afterglow: 0.18
        }
    }

    var sunOpacity: Double {
        switch self {
        case .stormy: 0.04
        case .clearing: 0.18
        case .afterglow: 0.40
        }
    }

    var ambientBrightness: Double {
        switch self {
        case .stormy: -0.02
        case .clearing: 0.035
        case .afterglow: 0.075
        }
    }

    var foregroundHazeOpacity: Double {
        switch self {
        case .stormy: 0.30
        case .clearing: 0.18
        case .afterglow: 0.10
        }
    }

    var accessibilityName: String {
        switch self {
        case .stormy: "stormy"
        case .clearing: "clearing"
        case .afterglow: "afterglow"
        }
    }
}

private struct CloudShelf: View {
    let weather: WorldWeatherState

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                cloud(width: 220, height: 72, opacity: weather.cloudOpacity)
                    .position(x: proxy.size.width * 0.22, y: proxy.size.height * 0.13)
                cloud(width: 180, height: 58, opacity: weather.cloudOpacity * 0.82)
                    .position(x: proxy.size.width * 0.70, y: proxy.size.height * 0.09)
                cloud(width: 260, height: 82, opacity: weather.cloudOpacity * 0.62)
                    .position(x: proxy.size.width * 0.53, y: proxy.size.height * 0.22)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func cloud(width: CGFloat, height: CGFloat, opacity: Double) -> some View {
        Capsule()
            .fill(Color.white.opacity(0.08 * opacity))
            .frame(width: width, height: height)
            .blur(radius: 18)
            .overlay {
                Capsule()
                    .fill(AfterStormTheme.stormBlue.opacity(0.28 * opacity))
                    .blur(radius: 12)
            }
    }
}

private struct PremiumBlockScene: View {
    let restoredStages: Int
    let totalStages: Int
    let restorationFraction: Double
    let weather: WorldWeatherState
    let reduceMotion: Bool

    private let buildingCount = 7

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                blockGround
                    .frame(height: proxy.size.height * 0.58)

                road
                    .frame(height: proxy.size.height * 0.26)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 18)

                reflectionLayer
                    .frame(height: proxy.size.height * 0.20)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 22)

                treeLayer
                    .padding(.horizontal, 8)
                    .padding(.bottom, proxy.size.height * 0.31)

                buildingLayer
                    .padding(.horizontal, 14)
                    .padding(.bottom, proxy.size.height * 0.31)

                lampLayer
                    .padding(.horizontal, 24)
                    .padding(.bottom, proxy.size.height * 0.17)

                curbGlow
                    .padding(.horizontal, 24)
                    .padding(.bottom, proxy.size.height * 0.14)
            }
            .rotation3DEffect(.degrees(reduceMotion ? 0 : 4.2), axis: (x: 1, y: 0, z: 0))
            .shadow(color: .black.opacity(0.46), radius: 28, y: 20)
        }
        .accessibilityHidden(true)
    }

    private var blockGround: some View {
        RoundedRectangle(cornerRadius: 46, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        AfterStormTheme.deepLeaf.opacity(0.20 + restorationFraction * 0.36),
                        AfterStormTheme.wetAsphalt.opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 46)
                    .stroke(AfterStormTheme.restoredGreen.opacity(0.10 + restorationFraction * 0.26), lineWidth: 1)
            }
    }

    private var road: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [AfterStormTheme.wetReflection.opacity(0.42), AfterStormTheme.wetAsphalt],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                HStack(spacing: 18) {
                    ForEach(0..<7, id: \.self) { _ in
                        Capsule()
                            .fill(.white.opacity(0.16 + restorationFraction * 0.10))
                            .frame(width: 26, height: 2)
                    }
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.white.opacity(0.055))
                    .frame(height: 1)
            }
    }

    private var buildingLayer: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<buildingCount, id: \.self) { index in
                building(index)
            }
        }
    }

    @ViewBuilder
    private func building(_ index: Int) -> some View {
        let firstStage = index * 3
        let localStage = min(3, max(0, restoredStages - firstStage))
        let restoredAmount = Double(localStage) / 3.0
        let width: CGFloat = index.isMultiple(of: 2) ? 44 : 36
        let height: CGFloat = CGFloat(86 + (index % 3) * 25)

        VStack(spacing: 4) {
            if index == 4 {
                Text("CORNER")
                    .font(.system(size: 6, weight: .black, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(
                        localStage >= 2 ? AfterStormTheme.lanternWarm : .white.opacity(0.28)
                    )
                    .shadow(
                        color: localStage >= 2 ? AfterStormTheme.lanternWarm.opacity(0.75) : .clear,
                        radius: 5
                    )
            }

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AfterStormTheme.afterglow.opacity(0.12 + restoredAmount * 0.54),
                            AfterStormTheme.stormBlue.opacity(0.94 - restoredAmount * 0.30)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height)
                .overlay(alignment: .top) {
                    VStack(spacing: 7) {
                        ForEach(0..<3, id: \.self) { window in
                            let isLit = window < localStage
                            RoundedRectangle(cornerRadius: 2)
                                .fill(isLit ? AfterStormTheme.lanternWarm.opacity(0.94) : .white.opacity(0.075))
                                .frame(width: width * 0.42, height: 7)
                                .shadow(
                                    color: isLit ? AfterStormTheme.lanternWarm.opacity(0.62) : .clear,
                                    radius: 5
                                )
                        }
                    }
                    .padding(.top, 13)
                }
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(localStage >= 1 ? AfterStormTheme.lanternWarm.opacity(0.70) : .black.opacity(0.32))
                        .frame(width: width * 0.30, height: 18)
                        .padding(.bottom, 4)
                }
        }
    }

    private var lampLayer: some View {
        HStack {
            ForEach(0..<6, id: \.self) { index in
                let threshold = 2 + index * 4
                StreetLampView(lit: restoredStages >= threshold)
                if index < 5 { Spacer() }
            }
        }
    }

    private var reflectionLayer: some View {
        HStack {
            ForEach(0..<6, id: \.self) { index in
                let lit = restoredStages >= 2 + index * 4
                Ellipse()
                    .fill(lit ? AfterStormTheme.lanternWarm.opacity(0.18) : .clear)
                    .frame(width: 30, height: 76)
                    .blur(radius: 11)
                if index < 5 { Spacer() }
            }
        }
    }

    private var curbGlow: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        AfterStormTheme.rainBlue.opacity(0.12),
                        AfterStormTheme.lanternWarm.opacity(0.08 + restorationFraction * 0.28),
                        AfterStormTheme.rainBlue.opacity(0.10)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 3)
            .blur(radius: 1.5)
    }

    private var treeLayer: some View {
        HStack(alignment: .bottom) {
            RestoringTree(progress: treeProgress(offset: 0.00), lean: -8)
            Spacer()
            RestoringTree(progress: treeProgress(offset: 0.10), lean: 5)
            Spacer()
            RestoringTree(progress: treeProgress(offset: 0.18), lean: -4)
            Spacer()
            RestoringTree(progress: treeProgress(offset: 0.28), lean: 7)
            Spacer()
            RestoringTree(progress: treeProgress(offset: 0.38), lean: -6)
        }
    }

    private func treeProgress(offset: Double) -> Double {
        min(1, max(0.08, restorationFraction * 1.35 - offset))
    }
}

private struct StreetLampView: View {
    let lit: Bool

    var body: some View {
        VStack(spacing: -1) {
            ZStack {
                if lit {
                    Circle()
                        .fill(AfterStormTheme.lanternWarm.opacity(0.42))
                        .frame(width: 24, height: 24)
                        .blur(radius: 6)
                }
                RoundedRectangle(cornerRadius: 4)
                    .fill(lit ? AfterStormTheme.lanternWarm : .white.opacity(0.16))
                    .frame(width: 11, height: 8)
                    .shadow(
                        color: lit ? AfterStormTheme.lanternWarm.opacity(0.72) : .clear,
                        radius: 5
                    )
            }
            Capsule()
                .fill(.white.opacity(0.24))
                .frame(width: 2, height: 34)
        }
        .frame(width: 28, height: 48)
    }
}

private struct RestoringTree: View {
    let progress: Double
    let lean: Double

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(Color(red: 0.28, green: 0.19, blue: 0.12))
                .frame(width: 5, height: 44)

            Capsule()
                .fill(Color(red: 0.28, green: 0.19, blue: 0.12).opacity(0.85))
                .frame(width: 3, height: 25)
                .rotationEffect(.degrees(-34))
                .offset(x: -8, y: -25)

            Capsule()
                .fill(Color(red: 0.28, green: 0.19, blue: 0.12).opacity(0.85))
                .frame(width: 3, height: 23)
                .rotationEffect(.degrees(34))
                .offset(x: 8, y: -25)

            ZStack {
                Circle()
                    .fill(AfterStormTheme.deepLeaf.opacity(0.52 + progress * 0.32))
                    .frame(width: 30, height: 30)
                    .offset(x: -8, y: -6)
                Circle()
                    .fill(AfterStormTheme.freshLeaf.opacity(0.34 + progress * 0.62))
                    .frame(width: 34, height: 34)
                    .offset(x: 8, y: -7)
                Circle()
                    .fill(AfterStormTheme.restoredGreen.opacity(0.38 + progress * 0.55))
                    .frame(width: 38, height: 38)
                    .offset(y: -16)
            }
            .scaleEffect(0.22 + progress * 0.78)
            .opacity(0.20 + progress * 0.80)
            .offset(y: -31)

            if progress > 0.48 {
                HStack(spacing: 2) {
                    ForEach(0..<(progress > 0.78 ? 4 : 2), id: \.self) { index in
                        Circle()
                            .fill(index.isMultiple(of: 2) ? AfterStormTheme.afterglow : .white.opacity(0.82))
                            .frame(width: 3, height: 3)
                    }
                }
                .offset(y: 1)
            }
        }
        .frame(width: 44, height: 76)
        .rotationEffect(.degrees(lean * (1 - progress)))
    }
}

private struct WorldLifeLayer: View {
    let restoredStages: Int
    let reduceMotion: Bool
    @State private var bob = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if restoredStages >= 5 {
                    StormlingMiniature(tint: AfterStormTheme.rainBlue)
                        .position(x: proxy.size.width * 0.24, y: proxy.size.height * 0.61)
                        .offset(y: bob && !reduceMotion ? -2 : 1)
                }
                if restoredStages >= 9 {
                    TinyAnimalMiniature()
                        .position(x: proxy.size.width * 0.76, y: proxy.size.height * 0.67)
                        .offset(x: bob && !reduceMotion ? 3 : -2)
                }
                if restoredStages >= 13 {
                    StormlingMiniature(tint: AfterStormTheme.afterglow)
                        .position(x: proxy.size.width * 0.47, y: proxy.size.height * 0.60)
                        .offset(y: bob && !reduceMotion ? 1 : -2)
                }
                if restoredStages >= 17 {
                    HumanMiniature()
                        .position(x: proxy.size.width * 0.66, y: proxy.size.height * 0.61)
                }
                if restoredStages >= 21 {
                    StormlingMiniature(tint: AfterStormTheme.restoredGreen)
                        .position(x: proxy.size.width * 0.84, y: proxy.size.height * 0.57)
                        .offset(y: bob && !reduceMotion ? -2 : 1)
                }
                if restoredStages >= 23 {
                    Image(systemName: "bird.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.78))
                        .position(x: proxy.size.width * 0.36, y: proxy.size.height * 0.33)
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct StormlingMiniature: View {
    let tint: Color

    var body: some View {
        VStack(spacing: -3) {
            ZStack {
                Circle().fill(tint.opacity(0.92)).frame(width: 22, height: 22)
                HStack(spacing: 5) {
                    Circle().fill(.white.opacity(0.90)).frame(width: 3, height: 3)
                    Circle().fill(.white.opacity(0.90)).frame(width: 3, height: 3)
                }
                .offset(y: 1)
                Circle().fill(tint.opacity(0.82)).frame(width: 11, height: 11).offset(x: -8, y: -8)
                Circle().fill(tint.opacity(0.78)).frame(width: 10, height: 10).offset(x: 8, y: -7)
            }
            Capsule().fill(tint.opacity(0.86)).frame(width: 18, height: 23)
        }
        .shadow(color: tint.opacity(0.36), radius: 6, y: 2)
    }
}

private struct HumanMiniature: View {
    var body: some View {
        VStack(spacing: 0) {
            Circle().fill(.white.opacity(0.76)).frame(width: 12, height: 12)
            Capsule().fill(AfterStormTheme.rainBlue.opacity(0.88)).frame(width: 12, height: 24)
        }
        .shadow(color: .black.opacity(0.28), radius: 4, y: 2)
    }
}

private struct TinyAnimalMiniature: View {
    var body: some View {
        ZStack(alignment: .trailing) {
            Capsule().fill(.white.opacity(0.70)).frame(width: 24, height: 11)
            Circle().fill(.white.opacity(0.78)).frame(width: 10, height: 10).offset(x: 6, y: -4)
            Capsule().fill(.white.opacity(0.62)).frame(width: 3, height: 13).rotationEffect(.degrees(-42)).offset(x: -13, y: -5)
        }
        .frame(width: 34, height: 22)
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
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
            .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.15)
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
            ForEach(0..<36, id: \.self) { index in
                Capsule()
                    .fill(.white.opacity(0.19 * intensity))
                    .frame(width: 1.1, height: 17)
                    .rotationEffect(.degrees(12))
                    .position(
                        x: CGFloat((index * 53) % 410),
                        y: falling ? proxy.size.height + CGFloat(index * 8) : -40 - CGFloat(index * 13)
                    )
                    .animation(
                        .linear(duration: 1.12 + Double(index % 7) * 0.06)
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
                mesh: .generateBox(size: 4.8),
                materials: [SimpleMaterial(color: UIColor(red: 0.055, green: 0.075 + CGFloat(fraction) * 0.05, blue: 0.095, alpha: 1), isMetallic: false)]
            )
            ground.scale = [1, 0.025, 0.68]
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
