import Foundation
import XcodeReclaimCore

func derivedData(taking bytes: Int) -> Leftover {
    Leftover(name: "Derived data", bytes: bytes, place: .folder(developerFolder.appending(path: "Xcode/DerivedData")))
}

func previews(taking bytes: Int) -> Leftover {
    Leftover(name: "Previews", bytes: bytes, place: .folder(developerFolder.appending(path: "Xcode/UserData/Previews")))
}

func simulator(taking bytes: Int) -> Leftover {
    Leftover(
        name: "iPhone 17 (iOS 26.4, 21B507D3)",
        bytes: bytes,
        place: .simulator("21B507D3-909E-465B-957C-4B370278399F"),
        cost: "the apps inside it and their data are gone")
}

func copyOfXcode(taking bytes: Int) -> Leftover {
    Leftover(
        name: "Xcode 26.2 (17C51) — Applications",
        bytes: bytes,
        place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")),
        cost: "that version has to be downloaded again")
}
