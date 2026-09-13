import Foundation

public protocol Disk {
    func bytesUsedByFolder(at url: URL) -> Int
    func foldersInside(_ url: URL) -> [URL]
    func removeItem(at url: URL) throws
}
