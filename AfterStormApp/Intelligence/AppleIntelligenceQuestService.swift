import AfterStormCore
import CoreGraphics
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct AppleIntelligenceQuestService {
    enum ServiceError: Error { case unavailable, malformedResponse }

    @available(iOS 26.0, *)
    func suggestions(for context: QuestContext, selectedAreas: Set<LifeArea>, count: Int) async throws -> [Quest] {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard model.isAvailable else { throw ServiceError.unavailable }

        let allowed = selectedAreas.map(\.rawValue).sorted().joined(separator: ", ")
        let session = LanguageModelSession(instructions: """
        You are the quest designer for AfterStorm. Create tiny, respectful real-life quests. Never shame the person. Keep tasks bounded and safe. Return only pipe-delimited lines with exactly 6 fields: title|instruction|lifeArea|minutes|sparks|restorationNodeID. Life area must be one of: home, work, focus, digital, movement, learning, lifeAdmin. Restoration node must be one of: east-lights, maple-home, corner-store, workshop, bridge, power-station, main-street, park.
        """)
        let response = try await session.respond(to: """
        Context: \(context.text)
        Allowed life areas: \(allowed)
        Preferred minutes: \(context.preferredMinutes.map(String.init) ?? "not specified")
        Create exactly \(count) different quests.
        """)
        let parsed = parse(response.content, selectedAreas: selectedAreas, limit: count)
        guard parsed.count == count else { throw ServiceError.malformedResponse }
        return parsed
        #else
        throw ServiceError.unavailable
        #endif
    }

    @available(iOS 27.0, *)
    func sceneDescription(for image: CGImage) async throws -> String {
        #if compiler(>=6.3) && canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard model.isAvailable else { throw ServiceError.unavailable }
        let session = LanguageModelSession(instructions: "Describe only useful, nonjudgmental details that can become small everyday-life tasks.")
        let prompt = Prompt {
            "Describe this scene in 2-4 short sentences. Mention visible objects or work areas that could reasonably support a small task. Do not judge cleanliness or the person."
            Attachment(image)
        }
        return try await session.respond(to: prompt).content
        #else
        // Xcode 26 / older Foundation Models SDKs still build the full app.
        // Scene analysis falls back to Vision/local context until the iOS 27 API is available.
        throw ServiceError.unavailable
        #endif
    }

    private func parse(_ raw: String, selectedAreas: Set<LifeArea>, limit: Int) -> [Quest] {
        raw.split(whereSeparator: \.isNewline).compactMap { line in
            let pieces = line.split(separator: "|", omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            guard pieces.count == 6,
                  let area = LifeArea(rawValue: pieces[2]),
                  selectedAreas.isEmpty || selectedAreas.contains(area),
                  let minutes = Int(pieces[3]),
                  let sparks = Int(pieces[4]),
                  validNodes.contains(pieces[5]) else { return nil }
            return Quest(
                title: pieces[0],
                instruction: pieces[1],
                lifeArea: area,
                estimatedMinutes: max(1, min(minutes, 30)),
                sparkReward: max(5, min(sparks, 40)),
                restorationNodeID: pieces[5]
            )
        }.prefix(limit).map { $0 }
    }

    private var validNodes: Set<String> {
        ["east-lights", "maple-home", "corner-store", "workshop", "bridge", "power-station", "main-street", "park"]
    }
}
