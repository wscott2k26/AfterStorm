import AfterStormCore
import Foundation
import SwiftData
import WidgetKit

struct PersistedAppState {
    let snapshot: SessionSnapshot
    let hasCompletedOnboarding: Bool
}

@MainActor
final class PersistenceService {
    private let context: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(context: ModelContext) { self.context = context }

    func load() throws -> PersistedAppState? {
        let records = try primaryRecords()
        guard let record = records.max(by: { $0.updatedAt < $1.updatedAt }), !record.snapshotData.isEmpty else { return nil }
        let snapshot = try decoder.decode(SessionSnapshot.self, from: record.snapshotData)
        try removeDuplicatePrimaryRecords(keeping: record, from: records)
        updateWidget(snapshot)
        return PersistedAppState(snapshot: snapshot, hasCompletedOnboarding: record.hasCompletedOnboarding)
    }

    func save(snapshot: SessionSnapshot, hasCompletedOnboarding: Bool) throws {
        let data = try encoder.encode(snapshot)
        let records = try primaryRecords()
        let record: AppModel
        if let existing = records.max(by: { $0.updatedAt < $1.updatedAt }) {
            record = existing
        } else {
            record = AppModel()
            context.insert(record)
        }

        record.snapshotData = data
        record.hasCompletedOnboarding = hasCompletedOnboarding
        record.updatedAt = .now
        try removeDuplicatePrimaryRecords(keeping: record, from: records)
        try context.save()
        updateWidget(snapshot)
    }

    private func primaryRecords() throws -> [AppModel] {
        var descriptor = FetchDescriptor<AppModel>()
        descriptor.fetchLimit = 20
        return try context.fetch(descriptor).filter { $0.recordID == "primary" }
    }

    private func removeDuplicatePrimaryRecords(keeping record: AppModel, from records: [AppModel]) throws {
        for duplicate in records where duplicate !== record { context.delete(duplicate) }
        if context.hasChanges { try context.save() }
    }

    private func updateWidget(_ snapshot: SessionSnapshot) {
        WidgetSnapshotStore.save(
            WidgetSnapshot(
                sparks: snapshot.progress.sparks,
                completedQuestCount: snapshot.progress.completedQuestCount,
                restoredStages: snapshot.restorationNodes.reduce(0) { $0 + $1.stage },
                totalStages: snapshot.restorationNodes.reduce(0) { $0 + $1.maxStage },
                selectedAreas: snapshot.selectedAreas.map(\.rawValue).sorted(),
                updatedAt: .now
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}
