import Foundation
import XcodeReclaimEngine

final class DiskStub: Disk {
    var sizes: [URL: Int] = [:]
    var folders: [URL: [URL]] = [:]
    var whatCanBeRemoved: [URL: Bool] = [:]

    private(set) var removed: [URL] = []

    func bytesUsedByFolder(at url: URL) -> Int {
        sizes[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        folders[url, default: []]
    }

    func canRemoveItem(at url: URL) -> Bool {
        whatCanBeRemoved[url, default: true]
    }

    func removeItem(at url: URL) throws -> Bool {
        removed.append(url)
        return true
    }
}
