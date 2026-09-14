import Foundation
import XcodeReclaimEngine

struct DiskStub: Disk, Sendable {
    let holding: [URL: Int]

    func bytesUsedByFolder(at url: URL) -> Int {
        holding[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}
