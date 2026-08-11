import Observation

@MainActor
@Observable
final class AppFlow {
    enum Phase: Equatable {
        case studioIntro
        case stormReveal
        case personalization
        case avatar
        case avatarStudio
        case firstQuest
        case questDetail
        case questMode
        case questComplete
        case restorationReveal
        case main
    }

    var phase: Phase = .studioIntro

    func advance(to phase: Phase) {
        self.phase = phase
    }
}
