import XcodeReclaimEngine

final class ToolchainLoaderStub: ToolchainLoader {
    var reported: [Toolchain] = []

    func load() -> [Toolchain] {
        reported
    }
}
