// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-time",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SPFKTime",
            targets: [
                "SPFKTime",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-base", branch: "development"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-utils", branch: "development"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", branch: "development"),

        .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "SPFKTime",
            dependencies: [
                .product(name: "SPFKBase", package: "spfk-base"),
                .product(name: "SPFKUtils", package: "spfk-utils"),

                .product(name: "SwiftTimecode", package: "swift-timecode")
            ]
        ),
        .testTarget(
            name: "SPFKTimeTests",
            dependencies: [
                "SPFKTime",
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ]
)
