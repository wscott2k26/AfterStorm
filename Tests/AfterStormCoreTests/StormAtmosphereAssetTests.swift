import Foundation
import XCTest

final class StormAtmosphereAssetTests: XCTestCase {
    func testLuxuryBackgroundUsesBundledLicensedStormPhoto() throws {
        let scriptURL = repositoryRoot.appendingPathComponent("scripts/generate-storm-atmosphere.py")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: scriptURL.path),
            "The storm asset staging script must exist."
        )
        guard FileManager.default.fileExists(atPath: scriptURL.path) else { return }

        let script = try String(contentsOf: scriptURL, encoding: .utf8)
        let background = try source("AfterStormApp/Design/AdaptiveStormBackground.swift")
        let pipeline = try source("azure-pipelines.yml")
        let mirrorWorkflow = try source(".github/workflows/swift-core-diagnostic.yml")
        let attribution = try source("docs/quality/third-party-asset-attributions.md")
        let contentsURL = repositoryRoot
            .appendingPathComponent("AfterStormApp/Resources/Assets.xcassets/StormAtmosphere.imageset/Contents.json")

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: contentsURL.path),
            "The StormAtmosphere asset catalog entry must exist."
        )

        for token in [
            "PEXELS_SOURCE_URL",
            "Tom Van Dyck",
            "storm-atmosphere.jpg"
        ] {
            XCTAssertTrue(script.contains(token), "Missing licensed real-storm asset token: \(token)")
        }

        XCTAssertTrue(background.contains("Image(\"StormAtmosphere\")"))
        XCTAssertTrue(pipeline.contains("python3 scripts/generate-storm-atmosphere.py"))
        XCTAssertTrue(pipeline.contains("storm-atmosphere.jpg"))
        XCTAssertTrue(mirrorWorkflow.contains("python3 scripts/generate-storm-atmosphere.py"))
        XCTAssertTrue(
            mirrorWorkflow.contains("storm-atmosphere.jpg"),
            "The Xcode 26 mirror must verify the same JPEG staged by the generator and Azure pipeline."
        )
        XCTAssertFalse(
            mirrorWorkflow.contains("storm-atmosphere.png"),
            "The Xcode 26 mirror must not require the retired deterministic PNG asset."
        )
        XCTAssertTrue(attribution.contains("Tom Van Dyck"))
        XCTAssertTrue(attribution.contains("Pexels"))
        XCTAssertTrue(attribution.contains("15532423"))

        guard FileManager.default.fileExists(atPath: contentsURL.path) else { return }
        let contents = try String(contentsOf: contentsURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("storm-atmosphere.jpg"))
    }

    func testPexelsDownloaderUsesBrowserCompatibleRequestHeaders() throws {
        let script = try source("scripts/generate-storm-atmosphere.py")

        for token in [
            "Request(",
            "urlopen(",
            "User-Agent",
            "Referer",
            "https://www.pexels.com/"
        ] {
            XCTAssertTrue(
                script.contains(token),
                "Storm photo download must use browser-compatible request metadata: missing \(token)"
            )
        }

        XCTAssertFalse(
            script.contains("urlretrieve("),
            "Bare urlretrieve requests are rejected by Pexels with HTTP 403 on hosted CI runners."
        )
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
