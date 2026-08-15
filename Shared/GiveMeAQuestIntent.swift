import AfterStormCore
import AppIntents
import Foundation

struct GiveMeAQuestIntent: AppIntent {
    static let title: LocalizedStringResource = "Give Me a Quest"
    static let description = IntentDescription("Get one small AfterStorm quest based on your chosen life areas.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let snapshot = WidgetSnapshotStore.load()
        let areas = Set(snapshot.selectedAreas.compactMap(LifeArea.init(rawValue:)))
        let allowed = areas.isEmpty ? Set(LifeArea.allCases) : areas
        let composer = LocalContextQuestComposer(seed: Int(Date().timeIntervalSince1970) % 97)
        let context = QuestContext(text: "Give me one useful quick win I can start now.", preferredMinutes: 5, source: .text)
        let quests = try await composer.suggestions(for: context, selectedAreas: allowed, count: 1)
        guard let quest = quests.first else {
            return .result(dialog: IntentDialog("The weather is quiet right now. Open AfterStorm and I’ll find you a quest."))
        }
        return .result(dialog: IntentDialog("\(quest.title). \(quest.instruction) It earns \(quest.sparkReward) Sparks."))
    }
}
