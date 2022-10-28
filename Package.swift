// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Target.Dependency] = [
    "SwiftSyntax", "Yams", .product(name: "ArgumentParser", package: "swift-argument-parser")
]

// IMPORTANT: IF YOU CHANGE THE BELOW, PLEASE ALSO CHANGE THE LARGE FATALERROR()
// MESSAGE IN FILE.SWIFT TO MATCH THE NEW SWIFT VERSION.
#if swift(>=5.6)
dependencies.append(.product(name: "SwiftSyntaxParser", package: "SwiftSyntax"))
#endif
#if swift(>=5.7)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50700.1")
#elseif swift(>=5.6)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50600.1")
#elseif swift(>=5.5)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50500.0")
#else
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50400.0")
#endif

let package = Package(
    name: "Sitrep",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "SitrepCore", targets: ["SitrepCore"])
    ],
    dependencies: [
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", swiftSyntaxVersion),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.4")
    ],
    targets: [
        .executableTarget(name: "Sitrep", dependencies: ["SitrepCore",
                                               .product(name: "ArgumentParser",
                                                        package: "swift-argument-parser")]),
        .target(name: "SitrepCore", dependencies: dependencies),
        .testTarget(name: "SitrepCoreTests", dependencies: ["SitrepCore"], exclude: ["Inputs"])
    ]
)
