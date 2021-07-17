// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewExtensions",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ViewExtensions",
            targets: ["ViewExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.2.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", .exact("5.0.1"))
    ],
    targets: [
        .target(
            name: "ViewExtensions",
            dependencies: ["RxSwift", "RxDataSources"]),
        .testTarget(
            name: "ViewExtensionsTests",
            dependencies: ["ViewExtensions"]),
    ]
)
