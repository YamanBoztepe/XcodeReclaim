import Foundation
import XcodeReclaimCore

struct FolderLeftoverLoader {
    struct Folder {
        static let derivedData = Folder(name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil)
        static let interfaceBuilderCache = Folder(name: "Interface builder cache", relativePath: "Xcode/UserData/IB Support", cost: nil)
        static let previews = Folder(name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again")
        static let documentationCache = Folder(
            name: "Documentation cache",
            relativePath: "Xcode/DocumentationCache",
            cost: "the documentation is downloaded again")

        let name: String
        let relativePath: String
        let cost: String?
    }

    let folder: Folder
    let developerFolder: URL
    let disk: any FolderSizer

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        announce(folder.name)
        let url = developerFolder.appending(path: folder.relativePath)

        return [Leftover(name: folder.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: folder.cost)]
    }
}
