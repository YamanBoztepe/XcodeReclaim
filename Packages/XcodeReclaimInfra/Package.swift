// swift-tools-version: 6.2
import PackageDescription

let strictness: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility"),
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "XcodeReclaimInfra",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "XcodeReclaimInfra", targets: ["XcodeReclaimInfra"])
    ],
    dependencies: [
        .package(path: "../XcodeReclaimEngine")
    ],
    targets: [
        .target(
            name: "XcodeReclaimInfra",
            dependencies: [.product(name: "XcodeReclaimEngine", package: "XcodeReclaimEngine")],
            swiftSettings: strictness),
        .testTarget(
            name: "XcodeReclaimInfraTests",
            dependencies: ["XcodeReclaimInfra"],
            swiftSettings: strictness),
    ])
