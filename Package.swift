// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgeTechSupportAndSharing",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(
            name: "BridgeTechSupportAndSharing",
            targets: ["BridgeTechSupportAndSharing"]),
    ],
    targets: [
        .target(
            name: "BridgeTechSupportAndSharing",
            dependencies: []),
    ]
)
