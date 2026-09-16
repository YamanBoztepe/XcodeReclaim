import Foundation
import XcodeReclaimEngine

public struct SystemXcodeCopyLoader: XcodeCopyLoader {
    private let commandRunner: any CommandRunner
    private let disk: any Disk
    private let applicationsFolder: URL

    public init(commandRunner: any CommandRunner, disk: any Disk, applicationsFolder: URL) {
        self.commandRunner = commandRunner
        self.disk = disk
        self.applicationsFolder = applicationsFolder
    }

    public func load() -> [XcodeCopy] {
        let reported = searchedCopies()
        let found = (reported.isEmpty ? copiesInTheApplicationsFolder() : reported).map(withoutATrailingSlash)
        let running = runningProcesses()
        let pointedAt = commandLineToolsPath()

        return found.map { app in
            XcodeCopy(
                path: app,
                version: bundleInformation(in: app)?.version,
                bytes: disk.bytesUsedByFolder(at: app),
                isOpen: running.contains { $0.hasPrefix(pathInside(app)) },
                isPointedAtByCommandLineTools: pointedAt.hasPrefix(pathInside(app)),
                canBeRemoved: disk.canRemoveItem(at: app))
        }
    }
}

private struct BundleInformation {
    let identifier: String?
    let version: XcodeCopy.Version?
}

private extension SystemXcodeCopyLoader {
    var xcodeBundleIdentifier: String { "com.apple.dt.Xcode" }

    func searchedCopies() -> [URL] {
        let carryingTheIdentifier = "kMDItemCFBundleIdentifier == '\(xcodeBundleIdentifier)'"
        let answered = (try? commandRunner.run(executable: URL(fileURLWithPath: "/usr/bin/mdfind"), arguments: [carryingTheIdentifier])) ?? ""
        return lines(of: answered).map { URL(fileURLWithPath: $0) }
    }

    func copiesInTheApplicationsFolder() -> [URL] {
        disk.foldersInside(applicationsFolder).filter { bundleInformation(in: $0)?.identifier == xcodeBundleIdentifier }
    }

    func runningProcesses() -> [String] {
        lines(of: (try? commandRunner.run(executable: URL(fileURLWithPath: "/bin/ps"), arguments: ["-Ao", "comm="])) ?? "")
    }

    func commandLineToolsPath() -> String {
        let answered = (try? commandRunner.run(executable: URL(fileURLWithPath: "/usr/bin/xcode-select"), arguments: ["-p"])) ?? ""
        return lines(of: answered).first ?? ""
    }

    func lines(of answered: String) -> [String] {
        answered.split(whereSeparator: \.isNewline).map(String.init)
    }

    func withoutATrailingSlash(_ app: URL) -> URL {
        URL(filePath: app.path(percentEncoded: false), directoryHint: .notDirectory)
    }

    func pathInside(_ app: URL) -> String {
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
