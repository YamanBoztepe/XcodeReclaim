import Foundation
import XcodeReclaimEngine

public struct LocalArchiveLoader: ArchiveLoader {
    public typealias Disk = FolderSizer & FolderLister

    private let disk: any Disk
    private let archivesFolder: URL

    public init(disk: any Disk, archivesFolder: URL) {
        self.disk = disk
        self.archivesFolder = archivesFolder
    }

    public func load() -> [Archive] {
        archivesInEveryDay().map { archive in
            let record = record(of: archive)

            return Archive(
                path: archive,
                name: record?.name ?? archive.deletingPathExtension().lastPathComponent,
                version: record?.version,
                build: record?.build,
                created: record?.created,
                bytes: disk.bytesUsedByFolder(at: archive))
        }
    }
}

private struct ArchiveRecord {
    let name: String?
    let version: String?
    let build: String?
    let created: Date?
}

private extension LocalArchiveLoader {
    func archivesInEveryDay() -> [URL] {
        disk.foldersInside(archivesFolder).flatMap(disk.foldersInside).filter { $0.pathExtension == "xcarchive" }.map(withoutATrailingSlash)
    }

    func withoutATrailingSlash(_ archive: URL) -> URL {
        URL(filePath: archive.path(percentEncoded: false), directoryHint: .notDirectory)
    }

    func record(of archive: URL) -> ArchiveRecord? {
        guard let written = try? Data(contentsOf: archive.appending(path: "Info.plist")),
            let read = try? PropertyListSerialization.propertyList(from: written, format: nil) as? [String: Any]
        else { return nil }

        let application = read["ApplicationProperties"] as? [String: Any]
        return ArchiveRecord(
            name: read["Name"] as? String,
            version: application?["CFBundleShortVersionString"] as? String,
            build: application?["CFBundleVersion"] as? String,
            created: read["CreationDate"] as? Date)
    }
}
