import Foundation
import XcodeReclaimEngine

struct XcodeCopiesStub: XcodeCopies, Sendable {
    let eachTaking: [Int]

    func copies() -> [XcodeCopy] {
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
