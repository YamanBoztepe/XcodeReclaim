import Foundation
import XcodeReclaimCore

struct OfferedFolder {
    static let everyOne = [
        OfferedFolder(name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil),
        OfferedFolder(name: "Interface builder cache", relativePath: "Xcode/UserData/IB Support", cost: nil),
        OfferedFolder(name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again"),
        OfferedFolder(name: "Documentation cache", relativePath: "Xcode/DocumentationCache", cost: "the documentation is downloaded again"),
    ]

    let name: String
    let relativePath: String
    let cost: String?
}

struct OfferedFolders: LeftoverSource {
    let offered: OfferedFolder
    let developerFolder: URL
    let disk: any Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        announce(offered.name)
        let url = developerFolder.appending(path: offered.relativePath)

        return [Leftover(name: offered.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: offered.cost)]
    }
}
