// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForexKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "ForexKit",
            targets: ["ForexKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kamaalio/KamaalSwift.git", .upToNextMajor(from: "1.4.1")),
        .package(url: "https://github.com/kamaal111/MockURLProtocol.git", "0.1.1" ..< "0.2.0"),
    ],
    targets: [
        .target(
            name: "ForexKit",
            dependencies: [
                .product(name: "KamaalNetworker", package: "KamaalSwift"),
                .product(name: "KamaalExtensions", package: "KamaalSwift"),
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
