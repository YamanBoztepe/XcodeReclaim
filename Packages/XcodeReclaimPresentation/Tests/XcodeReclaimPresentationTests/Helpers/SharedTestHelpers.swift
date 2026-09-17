import Foundation
import XcodeReclaimCore

func derivedData(taking bytes: Int) -> Leftover {
    folder(.derivedData, at: "Xcode/DerivedData", taking: bytes)
}

func interfaceBuilderCache(taking bytes: Int) -> Leftover {
    folder(.interfaceBuilderCache, at: "Xcode/UserData/IB Support", taking: bytes)
}

func previews(taking bytes: Int) -> Leftover {
    folder(.previews, at: "Xcode/UserData/Previews", taking: bytes)
}

func documentationCache(taking bytes: Int) -> Leftover {
    folder(.documentationCache, at: "Xcode/DocumentationCache", taking: bytes)
}

func deviceSupport(for systemVersion: String, taking bytes: Int) -> Leftover {
    folder(.deviceSupport(systemVersion: systemVersion), at: "Xcode/iOS DeviceSupport/iPhone15,2 \(systemVersion) (22A1)", taking: bytes)
}

func deviceSupport(inFolderNamed folderName: String, taking bytes: Int) -> Leftover {
    folder(.deviceSupport(systemVersion: nil), at: "Xcode/iOS DeviceSupport/\(folderName)", taking: bytes)
}

func simulator(
    named name: String = "iPhone 17",
    on runtime: String = "iOS 26.4",
    identified identifier: String = "21B507D3-909E-465B-957C-4B370278399F",
    taking bytes: Int,
    refusedFor refusal: Leftover.Refusal? = nil
) -> Leftover {
    Leftover(kind: .simulator(name: name, runtime: runtime), bytes: bytes, place: .simulator(identifier), refusal: refusal)
}

func copyOfXcode(
    carrying version: Leftover.XcodeVersion? = Leftover.XcodeVersion(number: "26.2", build: "17C51"),
    sittingIn folderName: String = "Applications",
    canBeRemovedWhereItStands: Bool = true,
    taking bytes: Int,
    refusedFor refusal: Leftover.Refusal? = nil
) -> Leftover {
    Leftover(
        kind: .xcodeCopy(version: version, canBeRemovedWhereItStands: canBeRemovedWhereItStands),
        bytes: bytes,
        place: .xcodeCopy(URL(filePath: "/\(folderName)/Xcode.app")),
        refusal: refusal)
}

private func folder(_ kind: Leftover.Kind, at relativePath: String, taking bytes: Int) -> Leftover {
    Leftover(kind: kind, bytes: bytes, place: .folder(URL(filePath: "/developer").appending(path: relativePath)))
}
