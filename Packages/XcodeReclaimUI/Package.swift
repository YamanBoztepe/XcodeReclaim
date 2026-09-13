// swift-tools-version: 6.2
import PackageDescription

let strictness: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "XcodeReclaimUI",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "XcodeReclaimUI", targets: ["XcodeReclaimUI"])
    ],
    dependencies: [
        .package(path: "../XcodeReclaimPresentation")
    ],
    targets: [
        .target(
            name: "XcodeReclaimUI",
            dependencies: [.product(name: "XcodeReclaimPresentation", package: "XcodeReclaimPresentation")],
            swiftSettings: strictness),
        .testTarget(
            name: "XcodeReclaimUITests",
            dependencies: ["XcodeReclaimUI"],
            swiftSettings: strictness),
    ])
