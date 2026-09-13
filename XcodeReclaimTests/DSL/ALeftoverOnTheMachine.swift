import Foundation
import XcodeReclaimCore

enum ALeftoverOnTheMachine {
    static func derivedData(taking bytes: Int) -> Leftover {
        Leftover(name: "Derived data", bytes: bytes, place: .folder(URL(filePath: "/developer/Xcode/DerivedData")))
    }

    static func previews(taking bytes: Int) -> Leftover {
        Leftover(name: "Previews", bytes: bytes, place: .folder(URL(filePath: "/developer/Xcode/UserData/Previews")))
    }

    static func aSimulator(taking bytes: Int) -> Leftover {
        Leftover(
            name: "iPhone 17 (iOS 26.4, 21B507D3)",
            bytes: bytes,
            place: .simulator("21B507D3-909E-465B-957C-4B370278399F"),
            cost: "the apps inside it and their data are gone")
    }

    static func aCopyOfXcode(taking bytes: Int) -> Leftover {
        Leftover(
            name: "Xcode 26.2 (17C51) — Applications",
            bytes: bytes,
            place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")),
            cost: "that version has to be downloaded again")
    }
}
