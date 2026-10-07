import Foundation
import XcodeReclaimEngine

struct ToolchainLoaderStub: ToolchainLoader, Sendable {
    let eachTaking: [Int]

    func load() -> [Toolchain] {
        eachTaking.map {
            Toolchain(
                path: URL(filePath: "/developer/Toolchains/swift-6.2.4-RELEASE.xctoolchain"),
                name: "Swift 6.2.4 Release 2026-02-24 (a)",
                isPointedAtBySwiftLatest: false,
                bytes: $0)
        }
    }
}
