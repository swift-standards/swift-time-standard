// swift-tools-version: 6.3.1

import PackageDescription

extension String {
    static let timeStandard: Self = "Time Standard"
}

extension Target.Dependency {
    static var timeStandard: Self { .target(name: .timeStandard) }
    static var time: Self { .product(name: "Time Primitives", package: "swift-time-primitives") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var iso8601: Self { .product(name: "ISO 8601", package: "swift-iso-8601") }
    static var rfc5322: Self { .product(name: "RFC 5322", package: "swift-rfc-5322") }
    static var rfc3339: Self { .product(name: "RFC 3339", package: "swift-rfc-3339") }
    static var standardsTestSupport: Self { .product(name: "Test Primitives", package: "swift-test-primitives") }
}

let package = Package(
    name: "swift-time-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "Time Standard", targets: ["Time Standard"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-time-primitives"),
        .package(path: "../../swift-iso/swift-iso-8601"),
        .package(path: "../../swift-ietf/swift-rfc-5322"),
        .package(path: "../../swift-ietf/swift-rfc-3339")
    ],
    targets: [
        .target(
            name: "Time Standard",
            dependencies: [
                .time,
                .standards,
                .iso8601,
                .rfc5322,
                .rfc3339
            ]
        ),
        .testTarget(
            name: "Time Standard Tests",
            dependencies: [
                "Time Standard",
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
