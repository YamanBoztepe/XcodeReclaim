import Foundation
import XcodeReclaimCore

func folder(named name: String = "Derived data", taking bytes: Int, costing cost: String? = nil) -> Leftover {
    Leftover(name: name, bytes: bytes, place: .folder(URL(fileURLWithPath: "/developer/\(name)")), cost: cost)
}

func simulator(
    named name: String = "iPhone 17 (iOS 26.4, 21B507D3)",
    taking bytes: Int,
    refusedFor refusal: Leftover.Refusal? = nil
) -> Leftover {
    Leftover(
        name: name,
        bytes: bytes,
        place: .simulator(name),
        cost: "the apps inside it and their data are gone",
        refusal: refusal)
}

func copyOfXcode(
    named name: String = "Xcode 26.2 (17C51) — Applications",
    taking bytes: Int,
    refusedFor refusal: Leftover.Refusal? = nil
) -> Leftover {
    Leftover(
        name: name,
        bytes: bytes,
        place: .xcodeCopy(URL(fileURLWithPath: "/Applications/\(name).app")),
        cost: "that version has to be downloaded again",
        refusal: refusal)
}
