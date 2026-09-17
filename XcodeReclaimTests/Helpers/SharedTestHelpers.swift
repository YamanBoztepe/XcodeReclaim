import Foundation
import XcodeReclaimCore

let developerFolder = URL(filePath: "/developer")
let derivedDataFolder = developerFolder.appending(path: "Xcode/DerivedData")
let previewsFolder = developerFolder.appending(path: "Xcode/UserData/Previews")
let interfaceBuilderCacheFolder = developerFolder.appending(path: "Xcode/UserData/IB Support")
let documentationCacheFolder = developerFolder.appending(path: "Xcode/DocumentationCache")

func derivedData(taking bytes: Int) -> Leftover {
    Leftover(kind: .derivedData, bytes: bytes, place: .folder(derivedDataFolder))
}

func previews(taking bytes: Int) -> Leftover {
    Leftover(kind: .previews, bytes: bytes, place: .folder(previewsFolder))
}

func simulator(taking bytes: Int) -> Leftover {
    Leftover(
        kind: .simulator(name: "iPhone 17", runtime: "iOS 26.4"),
        bytes: bytes,
        place: .simulator("21B507D3-909E-465B-957C-4B370278399F"))
}

func copyOfXcode(taking bytes: Int) -> Leftover {
    Leftover(
        kind: .xcodeCopy(version: Leftover.XcodeVersion(number: "26.2", build: "17C51"), canBeRemovedWhereItStands: true),
        bytes: bytes,
        place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")))
}
