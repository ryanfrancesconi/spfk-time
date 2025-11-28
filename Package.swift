// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

private let name: String = "SPFKTime" // Swift target
private let dependencyNames: [String] = ["SPFKBase", "SPFKUtils", "SPFKTesting"]
private let dependencyBranch: String = "development"
private let useLocalDependencies: Bool = false
private let platforms: [PackageDescription.SupportedPlatform]? = [
    .macOS(.v12),
    .iOS(.v15)
]

let remoteDependencies: [RemoteDependency] = [
    .init(package: .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0"),
          product: .product(name: "SwiftTimecode", package: "swift-timecode"))
]

// MARK: - Reusable Code for a Swift package

struct RemoteDependency {
    let package: PackageDescription.Package.Dependency
    let product: PackageDescription.Target.Dependency
}

private let nameTests: String = "\(name)Tests" // Test target
private let githubBase = "https://github.com/ryanfrancesconi"

private let products: [PackageDescription.Product] = [
    .library(
        name: name,
        targets: [name]
    )
]

private var packageDependencies: [PackageDescription.Package.Dependency] {
    let local: [PackageDescription.Package.Dependency] =
        dependencyNames.map {
            .package(name: "\($0)", path: "../\($0)")
        }

    let remote: [PackageDescription.Package.Dependency] =
        dependencyNames.map {
            .package(url: "\(githubBase)/\($0)", branch: dependencyBranch)
        }

    var value = useLocalDependencies ? local : remote
    value.append(contentsOf: remoteDependencies.map { $0.package })
    return value
}

private var swiftTargetDependencies: [PackageDescription.Target.Dependency] {
    let names = dependencyNames.filter { $0 != "SPFKTesting" }

    var value: [PackageDescription.Target.Dependency] = names.map {
        .byNameItem(name: "\($0)", condition: nil)
    }

    value.append(contentsOf: remoteDependencies.map { $0.product })

    return value
}

private let swiftTarget: PackageDescription.Target = .target(
    name: name,
    dependencies: swiftTargetDependencies,
    resources: nil
)

private var testTargetDependencies: [PackageDescription.Target.Dependency] {
    var array: [PackageDescription.Target.Dependency] = [
        .byNameItem(name: name, condition: nil)
    ]

    if dependencyNames.contains("SPFKTesting") {
        array.append(.byNameItem(name: "SPFKTesting", condition: nil))
    }

    return array
}

private let testTarget: PackageDescription.Target = .testTarget(
    name: nameTests,
    dependencies: testTargetDependencies,
    resources: nil
)

private let targets: [PackageDescription.Target] = [
    swiftTarget, testTarget
]

let package = Package(
    name: name,
    defaultLocalization: "en",
    platforms: platforms,
    products: products,
    dependencies: packageDependencies,
    targets: targets,
    cxxLanguageStandard: .cxx20
)
