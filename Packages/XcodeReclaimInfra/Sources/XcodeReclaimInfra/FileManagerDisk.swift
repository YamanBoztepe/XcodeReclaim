import Foundation
import XcodeReclaimEngine

public struct FileManagerDisk: Disk {
    public init() {}

    public func bytesUsedByFolder(at url: URL) -> Int {
        let wanted: [URLResourceKey] = [.isRegularFileKey, .totalFileAllocatedSizeKey, .linkCountKey, .fileResourceIdentifierKey]
        guard let walk = FileManager.default.enumerator(at: url, includingPropertiesForKeys: wanted, options: [], errorHandler: { _, _ in true }) else {
            return 0
        }

        var used = 0
        var alreadyCounted = Set<NSObject>()
        for case let file as URL in walk {
            guard let read = try? file.resourceValues(forKeys: Set(wanted)), read.isRegularFile == true else { continue }
            guard countsOnce(read, keeping: &alreadyCounted) else { continue }

            used += read.totalFileAllocatedSize ?? 0
        }
        return used
    }

    public func foldersInside(_ url: URL) -> [URL] {
        let wanted: [URLResourceKey] = [.isDirectoryKey]
        let held = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: wanted, options: [])) ?? []
        return held.filter { (try? $0.resourceValues(forKeys: Set(wanted)))?.isDirectory == true }
    }

    public func removeItem(at url: URL) throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let refusal as CocoaError where refusal.code == .fileNoSuchFile {
            return
        }
    }
}

private extension FileManagerDisk {
    func countsOnce(_ read: URLResourceValues, keeping alreadyCounted: inout Set<NSObject>) -> Bool {
        guard let paths = read.linkCount, paths > 1, let file = read.fileResourceIdentifier as? NSObject else { return true }

        return alreadyCounted.insert(file).inserted
    }
}
