import Foundation
import XcodeReclaimEngine

public struct SystemXcodeCopies: XcodeCopies {
    private let tool: any Tool
    private let disk: any Disk
    private let applicationsFolder: URL

    public init(tool: any Tool, disk: any Disk, applicationsFolder: URL) {
        self.tool = tool
        self.disk = disk
        self.applicationsFolder = applicationsFolder
    }

    public func copies() -> [XcodeCopy] {
        let reported = whatTheSearchReports()
        let found = (reported.isEmpty ? whatTheApplicationsFolderHolds() : reported).map(spelledOneWay)
        let running = whatIsRunning()
        let pointedAt = whereTheCommandLineToolsPoint()

        return found.map { app in
            XcodeCopy(
                path: app,
                version: bundleInformation(in: app)?.version,
                bytes: disk.bytesUsedByFolder(at: app),
                isOpen: running.contains { $0.hasPrefix(inside(app)) },
                isPointedAtByTheCommandLineTools: pointedAt.hasPrefix(inside(app)))
        }
    }
}

private struct BundleInformation {
    let identifier: String?
    let version: XcodeCopy.Version?
}

private extension SystemXcodeCopies {
    var xcodeBundleIdentifier: String { "com.apple.dt.Xcode" }

    func whatTheSearchReports() -> [URL] {
        let carryingTheIdentifier = "kMDItemCFBundleIdentifier == '\(xcodeBundleIdentifier)'"
        let answered = (try? tool.run(executable: URL(fileURLWithPath: "/usr/bin/mdfind"), arguments: [carryingTheIdentifier])) ?? ""
        return lines(of: answered).map { URL(fileURLWithPath: $0) }
    }

    func whatTheApplicationsFolderHolds() -> [URL] {
        disk.foldersInside(applicationsFolder).filter { bundleInformation(in: $0)?.identifier == xcodeBundleIdentifier }
    }

    func whatIsRunning() -> [String] {
        lines(of: (try? tool.run(executable: URL(fileURLWithPath: "/bin/ps"), arguments: ["-Ao", "comm="])) ?? "")
    }

    func whereTheCommandLineToolsPoint() -> String {
        let answered = (try? tool.run(executable: URL(fileURLWithPath: "/usr/bin/xcode-select"), arguments: ["-p"])) ?? ""
        return lines(of: answered).first ?? ""
    }

    func lines(of answered: String) -> [String] {
        answered.split(whereSeparator: \.isNewline).map(String.init)
    }

    func spelledOneWay(_ app: URL) -> URL {
        URL(filePath: app.path(percentEncoded: false), directoryHint: .notDirectory)
    }

    func inside(_ app: URL) -> String {
        app.path(percentEncoded: false) + "/"
    }

    func bundleInformation(in app: URL) -> BundleInformation? {
        guard let written = try? Data(contentsOf: app.appending(path: "Contents/Info.plist")),
            let read = try? PropertyListSerialization.propertyList(from: written, format: nil) as? [String: Any]
        else { return nil }

        return BundleInformation(identifier: read["CFBundleIdentifier"] as? String, version: version(in: read))
    }

    func version(in read: [String: Any]) -> XcodeCopy.Version? {
        guard let number = read["CFBundleShortVersionString"] as? String, let build = read["DTXcodeBuild"] as? String else { return nil }

        return XcodeCopy.Version(number: number, build: build)
    }
}
