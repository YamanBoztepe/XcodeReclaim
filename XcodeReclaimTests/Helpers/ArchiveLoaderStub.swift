import Foundation
import XcodeReclaimEngine

struct ArchiveLoaderStub: ArchiveLoader, Sendable {
    let eachTaking: [Int]

    func load() -> [Archive] {
        eachTaking.map {
            Archive(
                path: URL(filePath: "/developer/Xcode/Archives/2026-09-16/Communite Test 676.xcarchive"),
                name: "Communite Test",
                version: "2.0.0",
                build: "676",
                created: nil,
                bytes: $0)
        }
    }
}
