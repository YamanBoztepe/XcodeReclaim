import Foundation

public protocol FolderSizer {
    func bytesUsedByFolder(at url: URL) -> Int
}
