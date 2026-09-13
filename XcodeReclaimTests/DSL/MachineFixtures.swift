import Foundation

let developerFolder = URL(filePath: "/developer")
let derivedDataFolder = developerFolder.appending(path: "Xcode/DerivedData")
let previewsFolder = developerFolder.appending(path: "Xcode/UserData/Previews")

enum LeftoverOnTheMachine: Sendable {
    case folder(URL, Int)
    case simulator(Int)
    case copyOfXcode(Int)

    static func derivedData(taking bytes: Int) -> Self { .folder(derivedDataFolder, bytes) }
    static func previews(taking bytes: Int) -> Self { .folder(previewsFolder, bytes) }
    static func simulator(taking bytes: Int) -> Self { .simulator(bytes) }
    static func copyOfXcode(taking bytes: Int) -> Self { .copyOfXcode(bytes) }
}
