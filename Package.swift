// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "SwiftMsgPack",
    products: [
        .executable(
            name: "Example",
            targets: ["Example"]

        ),
        .library(
            name: "SwiftMsgPack",
            targets: ["SwiftMsgPack"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: ["SwiftMsgPack"],
            swiftSettings: [
                .enableExperimentalFeature("SwiftConcurrency")
            ]
        ),
        .target(
            name: "SwiftMsgPack",
            swiftSettings: [
                .enableExperimentalFeature("SwiftConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftMsgPackTests",
            dependencies: ["SwiftMsgPack"],
            swiftSettings: [
                .enableExperimentalFeature("SwiftConcurrency")
            ]
        ),
    ]
)
