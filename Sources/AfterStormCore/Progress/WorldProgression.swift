public enum WorldProgression {
    public static func complete(
        quest: Quest,
        progress: inout PlayerProgress,
        nodes: inout [RestorationNode]
    ) {
        progress.sparks += max(0, quest.sparkReward)
        progress.completedQuestCount += 1

        guard let index = nodes.firstIndex(where: { $0.id == quest.restorationNodeID }) else { return }
        nodes[index].stage = min(nodes[index].stage + 1, nodes[index].maxStage)
    }
}
