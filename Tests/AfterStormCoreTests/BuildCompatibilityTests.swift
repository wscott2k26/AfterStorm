import Foundation
import XCTest

final class BuildCompatibilityTests: XCTestCase {
    func testIOS27AttachmentAPIIsExplicitlyCompileFlagGated() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let serviceURL = repositoryRoot
            .appendingPathComponent("AfterStormApp")
            .appendingPathComponent("Intelligence")
            .appendingPathComponent("AppleIntelligenceQuestService.swift")

        let source = try String(contentsOf: serviceURL, encoding: .utf8)

        XCTAssertTrue(
            source.contains("#if AFTERSTORM_MULTIMODAL && canImport(FoundationModels)"),
            "The iOS 27 Attachment API must stay behind AFTERSTORM_MULTIMODAL so Xcode 26 never type-checks it."
        )
        XCTAssertFalse(
            source.contains("#if compiler(>=6.3) && canImport(FoundationModels)"),
            "Compiler-version gating is insufficient because Xcode 26.6 can use a Swift compiler new enough to satisfy it while its FoundationModels SDK still lacks Attachment."
        )
    }
}
