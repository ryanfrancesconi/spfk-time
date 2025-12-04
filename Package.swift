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

/*
 let name: String = "SPFKTime" // Swift target
 var localDependencies: [RemoteDependency] { [
     .init(package: .package(url: "\(githubBase)/spfk-base", from: "0.0.1"),
           product: .product(name: "SPFKBase", package: "spfk-base")),
     .init(package: .package(url: "\(githubBase)/spfk-utils", from: "0.0.1"),
           product: .product(name: "SPFKUtils", package: "spfk-utils")),
     .init(package: .package(url: "\(githubBase)/spfk-testing", from: "0.0.1"),
           product: .product(name: "SPFKTesting", package: "spfk-testing")),
 ] }

 let remoteDependencies: [RemoteDependency] = [
     .init(package: .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0"),
           product: .product(name: "SwiftTimecode", package: "swift-timecode"))
 ]
 let resources: [PackageDescription.Resource]? = nil

 let nameC: String? = nil
 let dependencyNamesC: [String] = []
 let remoteDependenciesC: [RemoteDependency] = []
 var cSettings: [PackageDescription.CSetting]? { [
     .headerSearchPath("include_private")
 ] }
 var cxxSettings: [PackageDescription.CXXSetting]? { [
     .headerSearchPath("include_private")
 ] }
 let platforms: [PackageDescription.SupportedPlatform]? = [
     .macOS(.v12),
     .iOS(.v15),
 ]

 */
