// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sitrep",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .executable(name: "sitrep", targets: ["Sitrep"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0"))
    ],
    targets: [
        .target(name: "Sitrep", dependencies: ["SitrepCore"]),
        .target(name: "SitrepCore", dependencies: ["SwiftSyntax"]),
        .testTarget(name: "SitrepCoreTests", dependencies: ["SitrepCore"], exclude: ["Inputs"])
    ]
)
