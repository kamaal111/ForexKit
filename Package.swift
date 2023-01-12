// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ForexKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "ForexKit",
            targets: ["ForexKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kamaal111/XiphiasNet.git", "7.0.0" ..< "8.0.0"),
        .package(url: "https://github.com/Kamaalio/ShrimpExtensions.git", "3.1.0" ..< "4.0.0"),
        .package(url: "https://github.com/kamaal111/MockURLProtocol.git", "0.1.1" ..< "0.2.0"),
    ],
    targets: [
        .target(
            name: "ForexKit",
            dependencies: [
                "XiphiasNet",
                "ShrimpExtensions",
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
