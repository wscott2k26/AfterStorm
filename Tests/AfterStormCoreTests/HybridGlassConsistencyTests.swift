import Foundation
import XCTest

final class HybridGlassConsistencyTests: XCTestCase {
    func testCoreGlassHasBroadReflectionAndReusableIconWell() throws {
        let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")

        for token in [
            "HybridGlassIconWellModifier",
            "hybridGlassIconWell",
            "RadialGradient",
            "specularBand",
            "crystalRim"
        ] {
            XCTAssertTrue(glass.contains(token), "Missing shared glass-depth token: \(token)")
        }
    }

    func testQuestSurfacesUseSharedGlassLanguage() throws {
        let quests = try source("AfterStormApp/Main/QuestsView.swift")
        let first = try source("AfterStormApp/Onboarding/FirstQuestView.swift")
        let life = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")

        XCTAssertTrue(quests.contains(".hybridGlassIconWell("))
        XCTAssertTrue(first.contains(".hybridGlassIconWell("))
        XCTAssertTrue(life.contains(".hybridGlassIconWell("))
        XCTAssertTrue(first.contains("PremiumButtonStyle(prominent: true)"))
        XCTAssertTrue(life.contains(".adaptiveGlassSurface(cornerRadius: 26, prominence: .control)"))
    }

    func testPremiumButtonCarriesCrystalSpecularTreatment() throws {
        let button = try source("AfterStormApp/Design/PremiumButtonStyle.swift")

        XCTAssertTrue(button.contains("RadialGradient"))
        XCTAssertTrue(button.contains("specularBand"))
        XCTAssertTrue(button.contains("accessibilityReduceTransparency"))
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
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
