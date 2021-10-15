// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewExtensions",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ViewExtensions",
            targets: ["ViewExtensions"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ViewExtensions",
            dependencies: []),
        .testTarget(
            name: "ViewExtensionsTests",
            dependencies: ["ViewExtensions"]),
    ]
)
