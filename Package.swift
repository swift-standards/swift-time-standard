// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let timeStandard: Self = "Time Standard"
}

extension Target.Dependency {
    static var timeStandard: Self { .target(name: .timeStandard) }
    static var time: Self { .product(name: "Time", package: "swift-time") }
    static var standards: Self {
        .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    }
    static var iso8601: Self { .product(name: "ISO 8601", package: "swift-iso-8601") }
    static var rfc5322: Self { .product(name: "RFC 5322", package: "swift-rfc-5322") }
    static var rfc3339: Self { .product(name: "RFC 3339", package: "swift-rfc-3339") }
}

let package = Package(
    name: "swift-time-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "Time Standard", targets: ["Time Standard"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-iso/swift-iso-8601.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5322.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-3339.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Time Standard",
            dependencies: [
                .time,
                .standards,
                .iso8601,
                .rfc5322,
                .rfc3339,
            ]
        ),
        .testTarget(
            name: "Time Standard Tests",
            dependencies: [
                "Time Standard"
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

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
