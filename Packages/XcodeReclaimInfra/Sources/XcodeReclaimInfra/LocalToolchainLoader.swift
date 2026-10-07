import Foundation
import XcodeReclaimEngine

public struct LocalToolchainLoader: ToolchainLoader {
    public typealias Disk = FolderSizer & FolderLister

    private let disk: any Disk
    private let toolchainsFolder: URL

    public init(disk: any Disk, toolchainsFolder: URL) {
        self.disk = disk
        self.toolchainsFolder = toolchainsFolder
    }

    public func load() -> [Toolchain] {
        let pointedAt = pathSwiftLatestPointsAt()

        return disk.foldersInside(toolchainsFolder).filter { $0.pathExtension == "xctoolchain" }.map { toolchain in
            Toolchain(
                path: withoutATrailingSlash(toolchain),
                name: displayName(of: toolchain) ?? toolchain.deletingPathExtension().lastPathComponent,
                isPointedAtBySwiftLatest: standardizedPath(of: toolchain) == pointedAt,
                bytes: disk.bytesUsedByFolder(at: toolchain))
        }
    }
}

private extension LocalToolchainLoader {
    func pathSwiftLatestPointsAt() -> String? {
        let link = toolchainsFolder.appending(path: "swift-latest.xctoolchain").path(percentEncoded: false)
        guard let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: link) else { return nil }

        let linkSitsIn = URL(filePath: toolchainsFolder.path(percentEncoded: false), directoryHint: .isDirectory)
        return standardizedPath(of: URL(filePath: destination, relativeTo: linkSitsIn))
    }

    func standardizedPath(of toolchain: URL) -> String {
        withoutATrailingSlash(toolchain.standardizedFileURL).path(percentEncoded: false)
    }

    func withoutATrailingSlash(_ toolchain: URL) -> URL {
        URL(filePath: toolchain.path(percentEncoded: false), directoryHint: .notDirectory)
    }

    func displayName(of toolchain: URL) -> String? {
        guard let written = try? Data(contentsOf: toolchain.appending(path: "Info.plist")),
            let read = try? PropertyListSerialization.propertyList(from: written, format: nil) as? [String: Any]
        else { return nil }

        return read["DisplayName"] as? String
    }
}
