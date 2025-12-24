// swift-tools-version:6.2

import PackageDescription

extension String {
    static let clocks: Self = "Clocks"
    static let timeStandard: Self = "Time Standard"
}

extension Target.Dependency {
    static var clocks: Self { .target(name: .clocks) }
    static var timeStandard: Self { .target(name: .timeStandard) }
    static var time: Self { .product(name: "StandardTime", package: "swift-standards") }
    static var standards: Self { .product(name: "Standards", package: "swift-standards") }
    static var iso8601: Self { .product(name: "ISO 8601", package: "swift-iso-8601") }
    static var rfc5322: Self { .product(name: "RFC 5322", package: "swift-rfc-5322") }
    static var rfc3339: Self { .product(name: "RFC 3339", package: "swift-rfc-3339") }
    static var standardsTestSupport: Self { .product(name: "StandardsTestSupport", package: "swift-standards") }
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
        .library(name: .clocks, targets: [.clocks]),
        .library(name: .timeStandard, targets: [.timeStandard])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.21.0"),
        .package(url: "https://github.com/swift-standards/swift-iso-8601", from: "0.2.2"),
        .package(url: "https://github.com/swift-standards/swift-rfc-5322", from: "0.7.1"),
        .package(url: "https://github.com/swift-standards/swift-rfc-3339", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: .clocks,
            dependencies: [
                .time
            ]
        ),
        .target(
            name: .timeStandard,
            dependencies: [
                .time,
                .standards,
                .iso8601,
                .rfc5322,
                .rfc3339
            ]
        ),
        .testTarget(
            name: .timeStandard.tests,
            dependencies: [
                .timeStandard,
                .standardsTestSupport
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
