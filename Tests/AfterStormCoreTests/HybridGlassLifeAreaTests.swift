import Foundation
import XCTest

final class HybridGlassLifeAreaTests: XCTestCase {
    func testLifeAreaTilesUseDedicatedHybridGlassTreatment() throws {
        let lifeArea = try source("AfterStormApp/Onboarding/LifeAreaSelectionView.swift")

        XCTAssertTrue(
            lifeArea.contains(".hybridGlassTile("),
            "Life-area cards need the dedicated lens-like glass treatment rather than the generic card surface."
        )
        XCTAssertFalse(
            lifeArea.contains(".adaptiveGlassSurface(cornerRadius: 22, prominence: selected ? .hero : .standard)"),
            "The generic standard/hero surface reads too flat on large square life-area tiles."
        )
    }

    func testHybridGlassTileAddsLensBloomAndCrystalRim() throws {
        let glass = try source("AfterStormApp/Design/AdaptiveGlassSurface.swift")

        for token in [
            "case tile",
            "HybridGlassTileModifier",
            "hybridGlassTile",
            "RadialGradient",
            "crystalRim",
            "accessibilityReduceTransparency"
        ] {
            XCTAssertTrue(glass.contains(token), "Missing life-area glass depth token: \(token)")
        }
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
