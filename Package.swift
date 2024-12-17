// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPackageWriter",
    platforms: [.macOS(.v11)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", .upToNextMajor(from: "510.0.0")),
        .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SwiftPackageWriter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftPackage"
            ],
            linkerSettings: [
                
            ]
        ),
        .target(
            name: "SwiftPackage",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                "PathKit"
            ]
        )
    ]
)
