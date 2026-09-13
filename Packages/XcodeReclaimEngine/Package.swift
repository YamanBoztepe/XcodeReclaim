// swift-tools-version: 6.2
import PackageDescription

let strictness: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "XcodeReclaimEngine",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "XcodeReclaimEngine", targets: ["XcodeReclaimEngine"])
    ],
    dependencies: [
        .package(path: "../XcodeReclaimCore")
    ],
    targets: [
        .target(
            name: "XcodeReclaimEngine",
            dependencies: [.product(name: "XcodeReclaimCore", package: "XcodeReclaimCore")],
            swiftSettings: strictness),
        .testTarget(
            name: "XcodeReclaimEngineTests",
            dependencies: ["XcodeReclaimEngine"],
            swiftSettings: strictness),
    ])
