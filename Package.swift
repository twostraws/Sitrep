// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Target.Dependency] = [
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
    "Yams",
    .product(name: "ArgumentParser", package: "swift-argument-parser")
]

let package = Package(
    name: "Sitrep",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "SitrepCore", targets: ["SitrepCore"]),
        .executable(name: "Sitrep", targets: ["Sitrep"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "508.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "Sitrep",
            dependencies: [
                "SitrepCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(name: "SitrepCore", dependencies: dependencies),
        .testTarget(name: "SitrepCoreTests", dependencies: ["SitrepCore"], exclude: ["Inputs"])
    ]
)
