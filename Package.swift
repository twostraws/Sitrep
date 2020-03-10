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
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(name: "Sitrep", dependencies: ["SitrepCore", "ArgumentParser"]),
        .target(name: "SitrepCore", dependencies: ["SwiftSyntax", "Yams", "ArgumentParser"]),
        .testTarget(name: "SitrepCoreTests", dependencies: ["SitrepCore"], exclude: ["Inputs"])
    ]
)
