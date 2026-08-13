import Foundation
import XCTest

final class BuildCompatibilityTests: XCTestCase {
    func testIOS27AttachmentAPIIsExplicitlyCompileFlagGated() throws {
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

    func testScrollableOnboardingScreensUseStickyBottomActions() throws {
        let lifeArea = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")
        let avatarStudio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")

        XCTAssertTrue(lifeArea.contains(".safeAreaInset(edge: .bottom)"))
        XCTAssertTrue(lifeArea.contains("OnboardingActionDock"))
        XCTAssertTrue(avatarStudio.contains(".safeAreaInset(edge: .bottom)"))
        XCTAssertTrue(avatarStudio.contains("OnboardingActionDock"))
    }

    func testStudioIntroUsesCloudFirstRetainedBoltSequence() throws {
        let intro = try source("AfterStormApp/Launch/StudioIntroView.swift")

        XCTAssertTrue(intro.contains("cloudVisible"))
        XCTAssertTrue(intro.contains("strikeVisible"))
        XCTAssertTrue(intro.contains("boltLocked"))
        XCTAssertTrue(intro.contains("wordmarkVisible"))
    }

    func testAzurePackagingVerificationCannotTriggerGrepSigpipe141() throws {
        let pipeline = try source("azure-pipelines.yml")

        XCTAssertTrue(pipeline.contains("unzip -Z1"))
        XCTAssertTrue(pipeline.contains("zip-contents.txt"))
        XCTAssertFalse(pipeline.contains("unzip -l \"$OUTPUT\" | grep -q"))
    }

    private var repositoryRoot: URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(
            contentsOf: repositoryRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }
}
