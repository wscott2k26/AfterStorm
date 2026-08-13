import Foundation
import Observation

@MainActor
enum ExperienceIntensity: String, CaseIterable, Identifiable {
    case cinematic
    case balanced
    case calm
    case followSystem

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cinematic: "Cinematic"
        case .balanced: "Balanced"
        case .calm: "Calm"
        case .followSystem: "Follow System"
        }
    }
}

@MainActor
@Observable
final class ExperiencePreferences {
    static let shared = ExperiencePreferences()

    private enum Keys {
        static let prefix = "afterstorm.experience."
        static let intensity = prefix + "intensity"
        static let weatherParticles = prefix + "weatherParticles"
        static let cameraMotion = prefix + "cameraMotion"
        static let lightningEffects = prefix + "lightningEffects"
        static let avatarAnimation = prefix + "avatarAnimation"
        static let ambience = prefix + "ambience"
        static let soundEffects = prefix + "soundEffects"
        static let haptics = prefix + "haptics"
    }

    private let defaults = UserDefaults.standard
    private var isApplyingPreset = false

    var intensity: ExperienceIntensity {
        didSet {
            defaults.set(intensity.rawValue, forKey: Keys.intensity)
            if !isApplyingPreset { applyVisualPreset(intensity) }
        }
    }
    var weatherParticlesEnabled: Bool { didSet { defaults.set(weatherParticlesEnabled, forKey: Keys.weatherParticles) } }
    var cameraMotionEnabled: Bool { didSet { defaults.set(cameraMotionEnabled, forKey: Keys.cameraMotion) } }
    var lightningEffectsEnabled: Bool { didSet { defaults.set(lightningEffectsEnabled, forKey: Keys.lightningEffects) } }
    var avatarAnimationEnabled: Bool { didSet { defaults.set(avatarAnimationEnabled, forKey: Keys.avatarAnimation) } }
    var ambienceEnabled: Bool { didSet { defaults.set(ambienceEnabled, forKey: Keys.ambience) } }
    var soundEffectsEnabled: Bool { didSet { defaults.set(soundEffectsEnabled, forKey: Keys.soundEffects) } }
    var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Keys.haptics) } }

    private init() {
        if let raw = defaults.string(forKey: Keys.intensity), let saved = ExperienceIntensity(rawValue: raw) {
            intensity = saved
        } else {
            intensity = .cinematic
        }
        weatherParticlesEnabled = Self.bool(defaults, key: Keys.weatherParticles, fallback: true)
        cameraMotionEnabled = Self.bool(defaults, key: Keys.cameraMotion, fallback: true)
        lightningEffectsEnabled = Self.bool(defaults, key: Keys.lightningEffects, fallback: true)
        avatarAnimationEnabled = Self.bool(defaults, key: Keys.avatarAnimation, fallback: true)
        ambienceEnabled = Self.bool(defaults, key: Keys.ambience, fallback: true)
        soundEffectsEnabled = Self.bool(defaults, key: Keys.soundEffects, fallback: true)
        hapticsEnabled = Self.bool(defaults, key: Keys.haptics, fallback: true)
    }

    func applyPreset(_ intensity: ExperienceIntensity) {
        isApplyingPreset = true
        self.intensity = intensity
        isApplyingPreset = false
        applyVisualPreset(intensity)
    }

    func allowsMotion(systemReduceMotion: Bool) -> Bool {
        guard !systemReduceMotion else { return false }
        return intensity != .calm
    }

    var cinematicStrength: Double {
        switch intensity {
        case .cinematic: 1.0
        case .balanced: 0.55
        case .calm: 0.0
        case .followSystem: 0.72
        }
    }

    private func applyVisualPreset(_ intensity: ExperienceIntensity) {
        switch intensity {
        case .cinematic:
            weatherParticlesEnabled = true
            cameraMotionEnabled = true
            lightningEffectsEnabled = true
            avatarAnimationEnabled = true
        case .balanced:
            weatherParticlesEnabled = true
            cameraMotionEnabled = false
            lightningEffectsEnabled = true
            avatarAnimationEnabled = true
        case .calm:
            weatherParticlesEnabled = false
            cameraMotionEnabled = false
            lightningEffectsEnabled = false
            avatarAnimationEnabled = false
        case .followSystem:
            weatherParticlesEnabled = true
            cameraMotionEnabled = true
            lightningEffectsEnabled = true
            avatarAnimationEnabled = true
        }
    }

    private static func bool(_ defaults: UserDefaults, key: String, fallback: Bool) -> Bool {
        guard defaults.object(forKey: key) != nil else { return fallback }
        return defaults.bool(forKey: key)
    }
}
