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

private func folder(_ kind: Leftover.Kind, at relativePath: String, taking bytes: Int, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
    Leftover(kind: kind, bytes: bytes, place: .folder(URL(filePath: "/developer").appending(path: relativePath)), refusal: refusal)
}

func runtime(
    named name: String = "iOS 26.2",
    build: String = "23C54",
    lastUsed: Date? = nil,
    identified identifier: String = "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E",
    taking bytes: Int,
    refusedFor refusal: Leftover.Refusal? = nil
) -> Leftover {
    Leftover(kind: .runtime(name: name, build: build, lastUsed: lastUsed), bytes: bytes, place: .runtime(identifier), refusal: refusal)
}

func archive(
    named name: String = "Communite Test",
    version: String? = "2.0.0",
    build: String? = "676",
    created: Date? = nil,
    inFolderNamed folderName: String = "Communite Test 676",
    taking bytes: Int
) -> Leftover {
    folder(
        .archive(name: name, version: version, build: build, created: created), at: "Xcode/Archives/2026-09-16/\(folderName).xcarchive",
        taking: bytes)
}

func swiftPackageCache(taking bytes: Int) -> Leftover {
    Leftover(kind: .swiftPackageCache, bytes: bytes, place: .folder(URL(filePath: "/caches/org.swift.swiftpm")))
}

func toolchain(named name: String = "Swift 6.2.4 Release 2026-02-24 (a)", taking bytes: Int, refusedFor refusal: Leftover.Refusal? = nil) -> Leftover {
    folder(.toolchain(name: name), at: "Toolchains/\(name).xctoolchain", taking: bytes, refusedFor: refusal)
}

func calendar(in timeZone: TimeZone = .gmt) -> Calendar {
    var days = Calendar(identifier: .gregorian)
    days.locale = Locale(identifier: "en_US_POSIX")
    days.timeZone = timeZone
    return days
}

func moment(_ written: String) -> Date {
    (try? Date(written, strategy: .iso8601)) ?? .distantPast
}
