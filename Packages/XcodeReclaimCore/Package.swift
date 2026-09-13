// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "XcodeReclaimCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "XcodeReclaimCore", targets: ["XcodeReclaimCore"])
    ],
    targets: [
        .target(
            name: "XcodeReclaimCore",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility"),
                .treatAllWarnings(as: .error),
            ])
    ])
