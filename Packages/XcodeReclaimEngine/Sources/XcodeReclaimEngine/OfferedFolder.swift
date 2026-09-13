import Foundation
import XcodeReclaimCore

struct OfferedFolder: LeftoverSource {
    struct Offered {
        static let derivedData = Offered(name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil)
        static let interfaceBuilderCache = Offered(name: "Interface builder cache", relativePath: "Xcode/UserData/IB Support", cost: nil)
        static let previews = Offered(name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again")
        static let documentationCache = Offered(
            name: "Documentation cache",
            relativePath: "Xcode/DocumentationCache",
            cost: "the documentation is downloaded again")

        let name: String
        let relativePath: String
        let cost: String?
    }

    let offered: Offered
    let developerFolder: URL
    let disk: any Disk

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        announce(offered.name)
        let url = developerFolder.appending(path: offered.relativePath)

        return [Leftover(name: offered.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: offered.cost)]
    }
}
