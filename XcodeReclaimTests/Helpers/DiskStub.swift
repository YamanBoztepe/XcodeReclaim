import Foundation
import XcodeReclaimEngine

struct DiskStub: FolderSizer, FolderLister, RemovalChecker, ItemRemover, Sendable {
    let holding: [URL: Int]
    var removesAnything = true

    func bytesUsedByFolder(at url: URL) -> Int {
        holding[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func canRemoveItem(at url: URL) -> Bool { true }

    func removeItem(at url: URL) throws -> Bool { removesAnything }
}
