import Foundation

enum AFolderOnTheDisk {
    static let oneBlock = 4096

    static func made() -> URL {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func put(_ blocks: Int, named name: String, inside folder: URL) {
        try? Data(count: blocks * oneBlock).write(to: folder.appending(path: name))
    }

    static func putAFileOf(_ bytes: Int, named name: String, inside folder: URL) {
        try? Data(count: bytes).write(to: folder.appending(path: name))
    }

    static func putAFolder(named name: String, inside folder: URL) -> URL {
        let made = folder.appending(path: name)
        try? FileManager.default.createDirectory(at: made, withIntermediateDirectories: true)
        return made
    }

    static func putASecondPathTo(_ name: String, named second: String, inside folder: URL) {
        try? FileManager.default.linkItem(at: folder.appending(path: name), to: folder.appending(path: second))
    }

    static func makeUnreadable(_ folder: URL) {
        try? FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: folder.path(percentEncoded: false))
    }

    static func makeUnwritable(_ folder: URL) {
        try? FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: folder.path(percentEncoded: false))
    }

    static func throwAway(_ folder: URL) {
        try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: folder.path(percentEncoded: false))
        for held in (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? [] {
            try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: held.path(percentEncoded: false))
        }
        try? FileManager.default.removeItem(at: folder)
    }
}
