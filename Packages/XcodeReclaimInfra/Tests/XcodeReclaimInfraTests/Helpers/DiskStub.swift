import Foundation
import XcodeReclaimEngine

final class DiskStub: Disk {
    var sizes: [URL: Int] = [:]
    var folders: [URL: [URL]] = [:]

    private(set) var removed: [URL] = []

    func bytesUsedByFolder(at url: URL) -> Int {
        sizes[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        folders[url, default: []]
    }

    func removeItem(at url: URL) throws -> Bool {
        removed.append(url)
        return true
    }
}
