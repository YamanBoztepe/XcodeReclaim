import Foundation

public protocol FolderLister {
    func foldersInside(_ url: URL) -> [URL]
}
