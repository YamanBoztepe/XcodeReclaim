import Foundation
import XcodeReclaimCore

struct OfferedFolder: LeftoverSource {
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

    let offered: Offered
    let developerFolder: URL
    let disk: any Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        announce(offered.name)
        let url = developerFolder.appending(path: offered.relativePath)

        return [Leftover(name: offered.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: offered.cost)]
    }
}
