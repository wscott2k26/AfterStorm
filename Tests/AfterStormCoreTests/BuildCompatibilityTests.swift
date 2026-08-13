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

    func testScrollableOnboardingScreensUseStickyBottomGlassActions() throws {
        let lifeArea = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")
        let avatarStudio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")

        XCTAssertTrue(lifeArea.contains(".safeAreaInset(edge: .bottom)"))
        XCTAssertTrue(avatarStudio.contains(".safeAreaInset(edge: .bottom)"))
    }

    func testStudioIntroUsesCloudFirstRetainedLightningSequence() throws {
        let intro = try source("AfterStormApp/Launch/StudioIntroView.swift")

        XCTAssertTrue(intro.contains("cloudVisible"))
        XCTAssertTrue(intro.contains("lightningVisible"))
        XCTAssertTrue(intro.contains("lightningLocked"))
        XCTAssertTrue(intro.contains("wordmarkVisible"))
    }

    func testAzurePackagingVerificationCannotTriggerGrepSigpipe141() throws {
        let pipeline = try source("azure-pipelines.yml")

        XCTAssertTrue(pipeline.contains("unzip -Z1"))
        XCTAssertTrue(pipeline.contains("zip-contents.txt"))
        XCTAssertFalse(pipeline.contains("unzip -l \"$OUTPUT\" | grep -q"))
    }

    func testAvatarStudioUsesOneVerticalScrollAndAdaptiveWrappingChips() throws {
        let source = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")
        XCTAssertTrue(source.contains("GridItem(.adaptive"))
        XCTAssertFalse(source.contains("ScrollView(.horizontal"))
        XCTAssertTrue(source.contains(".safeAreaInset(edge: .bottom)"))
    }

    func testExperiencePreferencesExposeAllRequiredControls() throws {
        let source = try source("AfterStormApp/Settings/ExperiencePreferences.swift")
        for token in [
            "ExperienceIntensity", "cinematic", "balanced", "calm", "followSystem",
            "weatherParticlesEnabled", "cameraMotionEnabled", "lightningEffectsEnabled",
            "avatarAnimationEnabled", "ambienceEnabled", "soundEffectsEnabled", "hapticsEnabled"
        ] {
            XCTAssertTrue(source.contains(token), "Missing preference token: \(token)")
        }
    }

    func testMeExposesSettingsAndSettingsExposesSensoryControls() throws {
        let me = try source("AfterStormApp/Main/MeView.swift")
        let settings = try source("AfterStormApp/Settings/SettingsView.swift")
        XCTAssertTrue(me.contains("Settings"))
        XCTAssertTrue(me.contains("showingSettings"))
        XCTAssertTrue(settings.contains("Experience"))
        XCTAssertTrue(settings.contains("Sound & Haptics"))
        XCTAssertTrue(settings.contains("Lightning & Flash"))
    }

    func testAudioAndHapticsRespectExperiencePreferences() throws {
        let audio = try source("AfterStormApp/Services/AudioService.swift")
        let haptics = try source("AfterStormApp/Services/HapticsService.swift")
        XCTAssertTrue(audio.contains("ExperiencePreferences.shared"))
        XCTAssertTrue(audio.contains("soundEffectsEnabled"))
        XCTAssertTrue(audio.contains("ambienceEnabled"))
        XCTAssertTrue(haptics.contains("ExperiencePreferences.shared"))
        XCTAssertTrue(haptics.contains("hapticsEnabled"))
    }

    func testAvatarAndWorldReadSensoryPreferences() throws {
        let avatar = try source("AfterStormApp/Onboarding/AvatarPreviewView.swift")
        let world = try source("AfterStormApp/World/WorldHomeView.swift")
        XCTAssertTrue(avatar.contains("ExperiencePreferences.shared"))
        XCTAssertTrue(avatar.contains("avatarAnimationEnabled"))
        XCTAssertTrue(world.contains("ExperiencePreferences.shared"))
        XCTAssertTrue(world.contains("weatherParticlesEnabled"))
        XCTAssertTrue(world.contains("cameraMotionEnabled"))
    }

    func testReactiveVisualStateExposesLuxuryPalette() throws {
        let visual = try source("AfterStormApp/Design/RestorationVisualState.swift")
        let theme = try source("AfterStormApp/Design/AfterStormTheme.swift")

        for token in [
            "struct RestorationVisualState", "restorationFraction", "accentPrimary",
            "accentSecondary", "glassTint", "stormIntensity", "afterglowIntensity",
            "glowIntensity", "backgroundColors"
        ] {
            XCTAssertTrue(visual.contains(token), "Missing visual-state token: \(token)")
        }
        XCTAssertTrue(theme.contains("stormTeal"))
        XCTAssertTrue(theme.contains("glassSilver"))
        XCTAssertTrue(theme.contains("afterglowRose"))
    }

    func testReactiveVisualStateIsContinuousAndInjectedAtRoot() throws {
        let environmentURL = repositoryRoot.appendingPathComponent("AfterStormApp/Design/AdaptiveVisualEnvironment.swift")
        XCTAssertTrue(FileManager.default.fileExists(atPath: environmentURL.path), "Adaptive visual environment must exist.")
        guard FileManager.default.fileExists(atPath: environmentURL.path) else { return }

        let visual = try source("AfterStormApp/Design/RestorationVisualState.swift")
        let environment = try source("AfterStormApp/Design/AdaptiveVisualEnvironment.swift")
        let model = try source("AfterStormApp/App/AppSessionModel.swift")
        let root = try source("AfterStormApp/App/RootView.swift")

        for token in ["stormWeight", "clearingWeight", "afterglowWeight", "glassOpacity", "interpolatedColor"] {
            XCTAssertTrue(visual.contains(token), "Missing continuous visual token: \(token)")
        }
        XCTAssertFalse(visual.contains("restorationFraction < 0.5 ?"), "Visual progression must not be one hard 50 percent switch.")
        XCTAssertTrue(environment.contains("afterStormVisualState"))
        XCTAssertTrue(model.contains("var restorationFraction: Double"))
        XCTAssertTrue(root.contains(".environment(\\.afterStormVisualState"))
    }

    func testAdaptiveStormAndGlassPrimitivesAreLayered() throws {
        let storm = try source("AfterStormApp/Design/AdaptiveStormBackground.swift")
        let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")

        XCTAssertTrue(storm.contains("ExperiencePreferences.shared"))
        XCTAssertTrue(storm.contains("LinearGradient"))
        XCTAssertTrue(storm.contains("blur(radius:"))
        XCTAssertTrue(storm.contains("mist"))
        XCTAssertTrue(glass.contains(".ultraThinMaterial"))
        XCTAssertTrue(glass.contains("LinearGradient"))
        XCTAssertTrue(glass.contains("shadow"))
        XCTAssertTrue(glass.contains("adaptiveGlass"))
    }

    func testHighImpactScreensConsumeAdaptiveLuxurySystem() throws {
        let avatarStudio = try source("AfterStormApp/Onboarding/AvatarStudioView.swift")
        let quest = try source("AfterStormApp/Quest/QuestDetailView.swift")
        let world = try source("AfterStormApp/World/WorldHomeView.swift")
        let me = try source("AfterStormApp/Main/MeView.swift")

        XCTAssertTrue(avatarStudio.contains("AdaptiveStormBackground"))
        XCTAssertTrue(avatarStudio.contains("adaptiveGlass"))
        XCTAssertTrue(quest.contains("AdaptiveStormBackground"))
        XCTAssertTrue(world.contains("adaptiveGlass"))
        XCTAssertTrue(me.contains("adaptiveGlass"))
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
