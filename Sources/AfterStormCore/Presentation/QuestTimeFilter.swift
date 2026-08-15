public enum QuestTimeFilter: String, CaseIterable, Equatable, Sendable {
    case any
    case upTo2
    case upTo5
    case upTo10
    case twentyPlus

    public func matches(minutes: Int) -> Bool {
        switch self {
        case .any:
            true
        case .upTo2:
            minutes <= 2
        case .upTo5:
            minutes <= 5
        case .upTo10:
            minutes <= 10
        case .twentyPlus:
            minutes >= 20
        }
    }
}
