import Foundation

public actor LocalQuestEngine: QuestEngine {
    private struct Template: Sendable {
        let title: String
        let instruction: String
        let lifeArea: LifeArea
        let estimatedMinutes: Int
        let sparkReward: Int
        let restorationNodeID: String
    }

    private let seed: Int
    private var requestOffset = 0

    public init(seed: Int = 0) {
        self.seed = seed
    }

    public func suggestions(for areas: Set<LifeArea>, count: Int) async throws -> [Quest] {
        guard count > 0, !areas.isEmpty else { return [] }

        let available = Self.templates.filter { areas.contains($0.lifeArea) }
        guard !available.isEmpty else { return [] }

        let base = abs(seed % available.count)
        let start = (base + requestOffset) % available.count
        requestOffset = (requestOffset + 1) % available.count
        return (0..<min(count, available.count)).map { index in
            let template = available[(start + index) % available.count]
            return Quest(
                title: template.title,
                instruction: template.instruction,
                lifeArea: template.lifeArea,
                estimatedMinutes: template.estimatedMinutes,
                sparkReward: template.sparkReward,
                restorationNodeID: template.restorationNodeID
            )
        }
    }

    private static let templates: [Template] = [
        .init(title: "Clear one surface", instruction: "Choose one desk, counter, table, or nightstand and reset only that surface.", lifeArea: .home, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "east-lights"),
        .init(title: "Put away ten things", instruction: "Return ten visible items to where they belong. Stop at ten.", lifeArea: .home, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "maple-home"),
        .init(title: "Reset one corner", instruction: "Pick one small corner of a room and make it calmer than you found it.", lifeArea: .home, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "corner-store"),
        .init(title: "Restore one small zone", instruction: "Choose one contained home zone, give it twenty focused minutes, then stop even if the whole room is not finished.", lifeArea: .home, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "maple-home"),

        .init(title: "Close one work loop", instruction: "Finish one small work task that can be completed without starting anything new.", lifeArea: .work, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "workshop"),
        .init(title: "Send the one reply", instruction: "Answer one message or email that has been waiting on you.", lifeArea: .work, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "east-lights"),
        .init(title: "Prep your next task", instruction: "Open what you need and write the very next action for your next work block.", lifeArea: .work, estimatedMinutes: 3, sparkReward: 10, restorationNodeID: "bridge"),
        .init(title: "Twenty-minute work closeout", instruction: "Pick one meaningful work item and give it one clean twenty-minute closeout block with notifications quiet.", lifeArea: .work, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "workshop"),

        .init(title: "Five-minute focus", instruction: "Choose one thing, silence distractions, and give it five clean minutes.", lifeArea: .focus, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "power-station"),
        .init(title: "Start before ready", instruction: "Spend two minutes beginning the task you have been avoiding. You can stop after two.", lifeArea: .focus, estimatedMinutes: 2, sparkReward: 10, restorationNodeID: "main-street"),
        .init(title: "Finish the smallest piece", instruction: "Find the smallest unfinished part of your current task and close just that piece.", lifeArea: .focus, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "workshop"),
        .init(title: "One deep-focus block", instruction: "Choose one task, silence distractions, and stay with only that task for twenty minutes.", lifeArea: .focus, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "power-station"),

        .init(title: "Delete ten files", instruction: "Remove ten screenshots, downloads, or files you no longer need.", lifeArea: .digital, estimatedMinutes: 3, sparkReward: 10, restorationNodeID: "east-lights"),
        .init(title: "Clear five notifications", instruction: "Handle or dismiss five notifications, then stop.", lifeArea: .digital, estimatedMinutes: 2, sparkReward: 10, restorationNodeID: "main-street"),
        .init(title: "Tidy one folder", instruction: "Choose one digital folder and organize only what is visible there.", lifeArea: .digital, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "workshop"),
        .init(title: "Digital reset block", instruction: "Spend twenty minutes on one digital mess—files, inbox, photos, or downloads—and stop when the timer ends.", lifeArea: .digital, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "main-street"),

        .init(title: "Take a five-minute walk", instruction: "Walk for five minutes at an easy pace. Indoors counts.", lifeArea: .movement, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "park"),
        .init(title: "Stretch for two minutes", instruction: "Give your shoulders, back, and legs two gentle minutes of movement.", lifeArea: .movement, estimatedMinutes: 2, sparkReward: 10, restorationNodeID: "park"),
        .init(title: "Move for ten", instruction: "Pick any movement you can comfortably do and keep it going for ten minutes.", lifeArea: .movement, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "bridge"),
        .init(title: "Twenty minutes outside or in", instruction: "Choose comfortable movement you can sustain for twenty minutes. Easy walking and indoor laps count.", lifeArea: .movement, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "park"),

        .init(title: "Read for five", instruction: "Read something useful or meaningful for five uninterrupted minutes.", lifeArea: .learning, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "corner-store"),
        .init(title: "Learn one thing", instruction: "Choose one question you have and spend five minutes finding a clear answer.", lifeArea: .learning, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "workshop"),
        .init(title: "Review one note", instruction: "Open one saved note, lesson, or flashcard set and review only that item.", lifeArea: .learning, estimatedMinutes: 3, sparkReward: 10, restorationNodeID: "maple-home"),
        .init(title: "Learn for twenty", instruction: "Pick one lesson, chapter, or skill and give it twenty uninterrupted minutes without trying to finish the whole subject.", lifeArea: .learning, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "corner-store"),

        .init(title: "Handle one errand", instruction: "Choose the shortest life-admin task you can fully finish right now.", lifeArea: .lifeAdmin, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "bridge"),
        .init(title: "Pay or schedule one bill", instruction: "Handle one due bill or schedule its payment, then stop.", lifeArea: .lifeAdmin, estimatedMinutes: 5, sparkReward: 15, restorationNodeID: "power-station"),
        .init(title: "Make one appointment", instruction: "Schedule one appointment, pickup, or service you have been postponing.", lifeArea: .lifeAdmin, estimatedMinutes: 10, sparkReward: 20, restorationNodeID: "main-street"),
        .init(title: "Life-admin power block", instruction: "Use twenty minutes to finish as many tiny calls, forms, calendar items, or bill tasks as comfortably fit—then stop.", lifeArea: .lifeAdmin, estimatedMinutes: 20, sparkReward: 30, restorationNodeID: "bridge")
    ]
}
