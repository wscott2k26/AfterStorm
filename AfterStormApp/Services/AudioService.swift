import Foundation
#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
final class AudioService {
    static let shared = AudioService()

    #if canImport(AVFoundation)
    private var players: [String: AVAudioPlayer] = [:]
    private var ambiencePlayers: [String: AVAudioPlayer] = [:]
    #endif

    private init() {}

    func playIntroThunder() { play(named: "storm-intro", extension: "wav", volume: 0.42) }
    func playQuestComplete() { play(named: "quest-complete", extension: "wav", volume: 0.62) }
    func playRestoration() { play(named: "restoration-impact", extension: "wav", volume: 0.68) }
    func playUnlock() { play(named: "unlock", extension: "wav", volume: 0.54) }

    func updateWorldAmbience(restorationFraction: Double) {
        #if canImport(AVFoundation)
        let fraction = max(0, min(1, restorationFraction))
        playLoop(named: "world-rain", volume: Float(0.12 - fraction * 0.07))
        playLoop(named: "world-afterglow", volume: Float(0.015 + fraction * 0.09))
        #endif
    }

    func stopWorldAmbience() {
        #if canImport(AVFoundation)
        for player in ambiencePlayers.values { player.stop() }
        ambiencePlayers.removeAll()
        #endif
    }

    private func play(named name: String, extension ext: String, volume: Float) {
        #if canImport(AVFoundation)
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            players[name] = player
        } catch {
            return
        }
        #endif
    }

    #if canImport(AVFoundation)
    private func playLoop(named name: String, volume: Float) {
        if let existing = ambiencePlayers[name] {
            existing.setVolume(volume, fadeDuration: 0.45)
            if !existing.isPlaying { existing.play() }
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.numberOfLoops = -1
        player.volume = 0
        player.prepareToPlay()
        player.play()
        player.setVolume(volume, fadeDuration: 0.8)
        ambiencePlayers[name] = player
    }
    #endif
}
