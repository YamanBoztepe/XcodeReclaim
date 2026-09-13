import Foundation

enum XcodeBundle {
    static let xcode = "com.apple.dt.Xcode"

    static func made(named name: String, carrying version: String, build: String, inside folder: URL) -> URL {
        made(
            named: name,
            declaring: ["CFBundleIdentifier": xcode, "CFBundleShortVersionString": version, "DTXcodeBuild": build],
            inside: folder)
    }

    static func madeCarryingNoBuild(named name: String, carrying version: String, inside folder: URL) -> URL {
        made(named: name, declaring: ["CFBundleIdentifier": xcode, "CFBundleShortVersionString": version], inside: folder)
    }

    static func madeForSomethingElse(named name: String, inside folder: URL) -> URL {
        made(named: name, declaring: ["CFBundleIdentifier": "com.apple.Safari", "CFBundleShortVersionString": "26.0"], inside: folder)
    }

    static func made(named name: String, declaring information: [String: String], inside folder: URL) -> URL {
        let app = folder.appending(path: name)
        let contents = app.appending(path: "Contents")
        try? FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let written = (try? PropertyListSerialization.data(fromPropertyList: information, format: .binary, options: 0)) ?? Data()
        try? written.write(to: contents.appending(path: "Info.plist"))
        return app
    }
}
