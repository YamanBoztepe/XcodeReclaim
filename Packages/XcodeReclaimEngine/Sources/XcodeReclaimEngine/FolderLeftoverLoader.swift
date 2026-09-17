import Foundation
import XcodeReclaimCore

struct FolderLeftoverLoader {
    struct Folder {
        static let derivedData = Folder(kind: .derivedData, relativePath: "Xcode/DerivedData")
        static let interfaceBuilderCache = Folder(kind: .interfaceBuilderCache, relativePath: "Xcode/UserData/IB Support")
        static let previews = Folder(kind: .previews, relativePath: "Xcode/UserData/Previews")
        static let documentationCache = Folder(kind: .documentationCache, relativePath: "Xcode/DocumentationCache")

        let kind: Leftover.Kind
        let relativePath: String
    }

    let folder: Folder
    let developerFolder: URL
    let disk: any FolderSizer

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        let url = developerFolder.appending(path: folder.relativePath)
        announce(folder.kind, .folder(url))

        return [Leftover(kind: folder.kind, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url))]
    }
}
