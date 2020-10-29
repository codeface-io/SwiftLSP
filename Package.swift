// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftLSP",
    products: [
        .library(
            name: "SwiftLSP",
            targets: ["SwiftLSP"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/FoundationToolz.git",
            .branch("master")),
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            .branch("master"))
    ],
    targets: [
        .target(
            name: "SwiftLSP",
            dependencies: ["FoundationToolz", "SwiftyToolz"]),
        .testTarget(
            name: "SwiftLSPTests",
            dependencies: ["SwiftLSP"]),
    ]
)
