import Foundation
import XCTest

final class StormAtmosphereAssetTests: XCTestCase {
    func testLuxuryBackgroundUsesDeterministicStormTextureAsset() throws {
        let scriptURL = repositoryRoot.appendingPathComponent("scripts/generate-storm-atmosphere.py")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: scriptURL.path),
            "The dedicated deterministic storm generator must exist."
        )
        guard FileManager.default.fileExists(atPath: scriptURL.path) else { return }

        let script = try String(contentsOf: scriptURL, encoding: .utf8)
        let background = try source("AfterStormApp/Design/AdaptiveStormBackground.swift")
        let pipeline = try source("azure-pipelines.yml")
        let contentsURL = repositoryRoot
            .appendingPathComponent("AfterStormApp/Resources/Assets.xcassets/StormAtmosphere.imageset/Contents.json")

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: contentsURL.path),
            "The StormAtmosphere asset catalog entry must exist."
        )

        for token in ["STORM_BG_DIR", "render_storm_atmosphere", "generate_storm_atmosphere", "storm-atmosphere.png"] {
            XCTAssertTrue(script.contains(token), "Missing deterministic storm asset token: \(token)")
        }
        XCTAssertTrue(background.contains("Image(\"StormAtmosphere\")"))
        XCTAssertTrue(pipeline.contains("python3 scripts/generate-storm-atmosphere.py"))

        guard FileManager.default.fileExists(atPath: contentsURL.path) else { return }
        let contents = try String(contentsOf: contentsURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("storm-atmosphere.png"))
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(_ relativePath: String) throws -> String {
        try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
