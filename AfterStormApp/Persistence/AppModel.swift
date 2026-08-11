import Foundation
import SwiftData

@Model
final class AppModel {
    var recordID: String
    var snapshotData: Data
    var hasCompletedOnboarding: Bool
    var updatedAt: Date

    init(
        recordID: String = "primary",
        snapshotData: Data = Data(),
        hasCompletedOnboarding: Bool = false,
        updatedAt: Date = .now
    ) {
        self.recordID = recordID
        self.snapshotData = snapshotData
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.updatedAt = updatedAt
    }
}
