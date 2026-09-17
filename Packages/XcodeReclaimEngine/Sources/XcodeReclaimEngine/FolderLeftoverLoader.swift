import Foundation
import XcodeReclaimCore

struct FolderLeftoverLoader {
    struct Folder {
        static let derivedData = Folder(kind: .derivedData, name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil)
        static let interfaceBuilderCache = Folder(
            kind: .interfaceBuilderCache,
            name: "Interface builder cache",
            relativePath: "Xcode/UserData/IB Support",
            cost: nil)
        static let previews = Folder(kind: .previews, name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again")
        static let documentationCache = Folder(
            kind: .documentationCache,
            name: "Documentation cache",
            relativePath: "Xcode/DocumentationCache",
            cost: "the documentation is downloaded again")

        let kind: Leftover.Kind
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

        return [Leftover(kind: folder.kind, name: folder.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: folder.cost)]
    }
}
