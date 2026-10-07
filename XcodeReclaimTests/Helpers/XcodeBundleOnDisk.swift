import Foundation

enum XcodeBundleOnDisk {
    static func made(carryingVersion version: String, build: String, inFolderNamed folderName: String) -> URL {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString).appending(path: folderName)
        let app = folder.appending(path: "Xcode.app")
        try? FileManager.default.createDirectory(at: app.appending(path: "Contents"), withIntermediateDirectories: true)
        let record: [String: Any] = ["CFBundleIdentifier": "com.apple.dt.Xcode", "CFBundleShortVersionString": version, "DTXcodeBuild": build]
        let written = (try? PropertyListSerialization.data(fromPropertyList: record, format: .xml, options: 0)) ?? Data()
        try? written.write(to: app.appending(path: "Contents/Info.plist"))
        return app
    }

    static func throwAway(_ app: URL) {
        try? FileManager.default.removeItem(at: app.deletingLastPathComponent().deletingLastPathComponent())
    }
}
