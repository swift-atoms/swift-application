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
        .library(name: "Application", targets: ["Application"]),

        .library(name: "Application Foundation Integration", targets: ["Application Foundation Integration"]),
        .library(name: "Application Test Support", targets: ["Application Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Application",
            dependencies: [
            ],
            path: "Sources/Application"
        ),
        
        .target(
            name: "Application Foundation Integration",
            dependencies: [
                .target(name: "Application"),
            ],
            path: "Sources/Application Foundation Integration"
        ),
        .target(
            name: "Application Test Support",
            dependencies: [
                .target(name: "Application"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Application Tests",
            dependencies: [
                .target(name: "Application"),
                .target(name: "Application Test Support"),
                .target(name: "Application Foundation Integration"),
            ],
            path: "Tests/Application Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
