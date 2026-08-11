import AppIntents

struct AfterStormShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GiveMeAQuestIntent(),
            phrases: [
                "Give me a quest in \(.applicationName)",
                "Give me an \(.applicationName) quest",
                "What should I restore in \(.applicationName)"
            ],
            shortTitle: "Give Me a Quest",
            systemImageName: "bolt.fill"
        )
    }
}
