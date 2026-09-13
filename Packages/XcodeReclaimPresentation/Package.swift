// swift-tools-version: 6.2
import PackageDescription

let strictness: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "XcodeReclaimPresentation",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "XcodeReclaimPresentation", targets: ["XcodeReclaimPresentation"])
    ],
    dependencies: [
        .package(path: "../XcodeReclaimCore")
    ],
    targets: [
        .target(
            name: "XcodeReclaimPresentation",
            dependencies: [.product(name: "XcodeReclaimCore", package: "XcodeReclaimCore")],
            swiftSettings: strictness),
        .testTarget(
            name: "XcodeReclaimPresentationTests",
            dependencies: ["XcodeReclaimPresentation"],
            swiftSettings: strictness),
    ])
