public struct RestorationReaction: Equatable, Sendable {
    public let speaker: String
    public let message: String

    public init(restoredStages: Int) {
        switch restoredStages {
        case ..<6:
            speaker = "Nova"
            message = "I knew one little light could change the whole street."
        case 6..<12:
            speaker = "Rumble"
            message = "Hear that? The Block is waking back up."
        case 12..<18:
            speaker = "Pip"
            message = "More doors are opening. Keep going—little by little."
        case 18..<23:
            speaker = "Miso"
            message = "The rain is easing. Folks are coming outside again."
        default:
            speaker = "Mara"
            message = "Look at that horizon. The storm reached farther than The Block."
        }
    }
}
