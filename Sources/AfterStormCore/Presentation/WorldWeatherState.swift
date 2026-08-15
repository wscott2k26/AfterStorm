public enum WorldWeatherState: String, Equatable, Sendable {
    case stormy
    case clearing
    case afterglow

    public init(restoredStages: Int, totalStages: Int) {
        guard totalStages > 0 else {
            self = .stormy
            return
        }

        let fraction = min(1, max(0, Double(restoredStages) / Double(totalStages)))
        if fraction < 0.25 {
            self = .stormy
        } else if fraction < 0.60 {
            self = .clearing
        } else {
            self = .afterglow
        }
    }
}
