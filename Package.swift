// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AfterStorm",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "AfterStormCore", targets: ["AfterStormCore"])
    ],
    targets: [
        .target(name: "AfterStormCore"),
        .testTarget(name: "AfterStormCoreTests", dependencies: ["AfterStormCore"])
    ]
)
