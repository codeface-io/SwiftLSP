// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SwiftLSP",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(
            name: "SwiftLSP",
            targets: ["SwiftLSP"]),
    ],
    dependencies: [
//        .package(path: "../FoundationToolz"),
        .package(
            url: "https://github.com/flowtoolz/FoundationToolz.git",
            exact: "0.4.1"
        ),
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            exact: "0.5.1"
        )
    ],
    targets: [
        .target(
            name: "SwiftLSP",
            dependencies: ["FoundationToolz", "SwiftyToolz"],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftLSPTests",
            dependencies: ["SwiftLSP", "FoundationToolz", "SwiftyToolz"],
            path: "Tests"
        ),
    ]
)
