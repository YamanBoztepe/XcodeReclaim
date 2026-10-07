import Foundation

enum ArchiveOnDisk {
    static func made(named name: String, recording record: [String: Any], onDay day: String, inside archives: URL) -> URL {
        let archive = madeWithNoRecord(named: name, onDay: day, inside: archives)
        let written = (try? PropertyListSerialization.data(fromPropertyList: record, format: .xml, options: 0)) ?? Data()
        try? written.write(to: archive.appending(path: "Info.plist"))
        return archive
    }

    static func madeWithNoRecord(named name: String, onDay day: String, inside archives: URL) -> URL {
        let archive = archives.appending(path: day).appending(path: "\(name).xcarchive")
        try? FileManager.default.createDirectory(at: archive, withIntermediateDirectories: true)
        return archive
    }

    static func record(name: String, version: String, build: String, created: Date) -> [String: Any] {
        [
            "Name": name,
            "CreationDate": created,
            "ApplicationProperties": ["CFBundleShortVersionString": version, "CFBundleVersion": build],
        ]
    }
}
