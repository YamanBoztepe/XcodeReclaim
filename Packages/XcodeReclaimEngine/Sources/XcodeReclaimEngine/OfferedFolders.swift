import Foundation
import XcodeReclaimCore

struct OfferedFolders: LeftoverSource {
    struct Offered {
        let name: String
        let relativePath: String
        let cost: String?
    }

    static let everyOne = [
        Offered(name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil),
        Offered(name: "Interface builder cache", relativePath: "Xcode/UserData/IB Support", cost: nil),
        Offered(name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again"),
        Offered(name: "Documentation cache", relativePath: "Xcode/DocumentationCache", cost: "the documentation is downloaded again"),
    ]

    let developerFolder: URL
    let disk: any Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        Self.everyOne.map { folder in
            announce(folder.name)
            let url = developerFolder.appending(path: folder.relativePath)

            return Leftover(name: folder.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: folder.cost)
        }
    }
}
