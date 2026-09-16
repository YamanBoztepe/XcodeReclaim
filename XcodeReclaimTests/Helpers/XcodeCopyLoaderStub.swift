import Foundation
import XcodeReclaimEngine

struct XcodeCopyLoaderStub: XcodeCopyLoader, Sendable {
    let eachTaking: [Int]

    func load() -> [XcodeCopy] {
        eachTaking.map {
            XcodeCopy(
                path: URL(filePath: "/Applications/Xcode 26.2.app"),
                version: XcodeCopy.Version(number: "26.2", build: "17C51"),
                bytes: $0,
                isOpen: false,
                isPointedAtByCommandLineTools: false,
                canBeRemoved: true)
        }
    }
}
