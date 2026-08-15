public struct QuestContext: Equatable, Codable, Sendable {
    public enum Source: String, Codable, Sendable { case text, speech, photo }

    public var text: String
    public var preferredMinutes: Int?
    public var source: Source

    public init(text: String, preferredMinutes: Int? = nil, source: Source) {
        self.text = text
        self.preferredMinutes = preferredMinutes.map { max(1, $0) }
        self.source = source
    }
}
