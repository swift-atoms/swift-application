// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-application",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Application",
            targets: ["Application"]
        ),
        .library(
            name: "Application Standard Library Integration",
            targets: ["Application Standard Library Integration"]
        ),
        .library(
            name: "Application Apple Foundation Integration",
            targets: ["Application Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Application",
            dependencies: []
        ),
        .target(
            name: "Application Standard Library Integration",
            dependencies: ["Application"]
        ),
        .target(
            name: "Application Apple Foundation Integration",
            dependencies: [
                "Application",
                "Application Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Application Tests",
            dependencies: ["Application"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
