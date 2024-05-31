// swift-tools-version: 5.4

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
            dependencies: ["SwiftMsgPack"]
        ),
        .target(
            name: "SwiftMsgPack"
        ),
        .testTarget(
            name: "SwiftMsgPackTests",
            dependencies: ["SwiftMsgPack"]
        ),
    ]
)
