// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_local_notifications",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "flutter-local-notifications", targets: ["flutter_local_notifications"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_local_notifications",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_local_notifications")
            ]
        )
    ]
)
