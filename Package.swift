// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForexKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "ForexKit",
            targets: ["ForexKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift", .upToNextMajor(from: "3.3.1")),
        .package(url: "https://github.com/kamaal111/MockURLProtocol", .upToNextMinor(from: "0.3.0")),
    ],
    targets: [
        .target(
            name: "ForexKit",
            dependencies: [
                .product(name: "KamaalNetworker", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
                .product(name: "KamaalUI", package: "KamaalSwift"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "ForexKitTests",
            dependencies: [
                "ForexKit",
                "MockURLProtocol",
            ]),
    ]
)
