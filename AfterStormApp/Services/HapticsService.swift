import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreHaptics)
import CoreHaptics
#endif

@MainActor
enum HapticsService {
    #if canImport(CoreHaptics)
    private static var engine: CHHapticEngine?
    #endif

    static func tap() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    static func questAccepted() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7)
        #endif
    }

    static func questComplete() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func timerFinished() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.58)
        #endif
    }

    static func restorationImpact() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.9)
        #endif
    }

    static func unlock() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func collectibleUnlock() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(CoreHaptics)
        if playSparklePattern() { return }
        #endif
        unlock()
    }

    static func majorRestoration() {
        guard ExperiencePreferences.shared.hapticsEnabled else { return }
        #if canImport(CoreHaptics)
        if playRestorationPattern() { return }
        #endif
        restorationImpact()
    }

    #if canImport(CoreHaptics)
    private static func hapticEngine() -> CHHapticEngine? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        if let engine { return engine }
        guard let newEngine = try? CHHapticEngine() else { return nil }
        try? newEngine.start()
        engine = newEngine
        return newEngine
    }

    private static func play(events: [CHHapticEvent]) -> Bool {
        guard let engine = hapticEngine(),
              let pattern = try? CHHapticPattern(events: events, parameters: []),
              let player = try? engine.makePlayer(with: pattern) else { return false }
        try? engine.start()
        do {
            try player.start(atTime: CHHapticTimeImmediate)
            return true
        } catch {
            return false
        }
    }

    private static func playSparklePattern() -> Bool {
        let events: [CHHapticEvent] = [
            transient(intensity: 0.25, sharpness: 0.8, time: 0.0),
            transient(intensity: 0.5, sharpness: 0.9, time: 0.08),
            transient(intensity: 0.82, sharpness: 1.0, time: 0.17)
        ]
        return play(events: events)
    }

    private static func playRestorationPattern() -> Bool {
        let rumble = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.12)
            ],
            relativeTime: 0,
            duration: 0.34
        )
        let impact = transient(intensity: 1.0, sharpness: 0.68, time: 0.31)
        return play(events: [rumble, impact])
    }

    private static func transient(intensity: Float, sharpness: Float, time: TimeInterval) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time
        )
    }
    #endif
}
