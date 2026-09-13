import Foundation
import XcodeReclaimCore

public struct MeasureLeftovers {
    private let developerFolder: URL
    private let disk: any Disk
    private let simulatorService: any SimulatorService
    private let xcodeCopies: any XcodeCopies
    private let worthDeleting: Int

    public init(
        developerFolder: URL,
        disk: any Disk,
        simulatorService: any SimulatorService,
        xcodeCopies: any XcodeCopies,
        worthDeleting: Int
    ) {
        self.developerFolder = developerFolder
        self.disk = disk
        self.simulatorService = simulatorService
        self.xcodeCopies = xcodeCopies
        self.worthDeleting = worthDeleting
    }

    public func leftovers(announcing announce: (String) -> Void = { _ in }) -> [Leftover] {
        var found: [Leftover] = []
        found += offeredFolders(announcing: announce)
        found += deviceSupportVersions(announcing: announce)
        found += simulators(announcing: announce)
        found += copiesOfXcode(announcing: announce)
        return biggestFirst(found.filter { $0.bytes >= worthDeleting })
    }
}

private struct OfferedFolder {
    let name: String
    let relativePath: String
    let cost: String?
}

private extension MeasureLeftovers {
    func offeredFolders(announcing announce: (String) -> Void) -> [Leftover] {
        let offered = [
            OfferedFolder(name: "Derived data", relativePath: "Xcode/DerivedData", cost: nil),
            OfferedFolder(name: "Interface builder cache", relativePath: "Xcode/UserData/IB Support", cost: nil),
            OfferedFolder(name: "Previews", relativePath: "Xcode/UserData/Previews", cost: "the previews are built again"),
            OfferedFolder(name: "Documentation cache", relativePath: "Xcode/DocumentationCache", cost: "the documentation is downloaded again"),
        ]

        var found: [Leftover] = []
        for folder in offered {
            announce(folder.name)
            let url = developerFolder.appending(path: folder.relativePath)
            found.append(Leftover(name: folder.name, bytes: disk.bytesUsedByFolder(at: url), place: .folder(url), cost: folder.cost))
        }
        return found
    }

    func deviceSupportVersions(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "the symbols are put back the next time that device is plugged in"
        let deviceSupport = developerFolder.appending(path: "Xcode/iOS DeviceSupport")

        var found: [Leftover] = []
        for version in disk.foldersInside(deviceSupport) {
            let name = "Device support (\(systemVersionHeldBy(version.lastPathComponent)))"
            announce(name)
            found.append(Leftover(name: name, bytes: disk.bytesUsedByFolder(at: version), place: .folder(version), cost: cost))
        }
        return found
    }

    func systemVersionHeldBy(_ folderName: String) -> String {
        let modelVersionAndBuild = /^\S+ (\S+) \(\S+\)$/
        guard let read = try? modelVersionAndBuild.wholeMatch(in: folderName) else { return folderName }

        return "iOS \(read.1)"
    }

    func simulators(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "the apps inside it and their data are gone"

        var found: [Leftover] = []
        for simulator in reportedSimulators() {
            let name = "\(simulator.name) (\(simulator.runtime), \(startOf(simulator.identifier)))"
            announce(name)
            found.append(
                Leftover(
                    name: name,
                    bytes: simulator.bytes,
                    place: .simulator(simulator.identifier),
                    cost: cost,
                    refusal: simulator.isShutDown ? nil : .theSimulatorIsRunning))
        }
        return found
    }

    func reportedSimulators() -> [Simulator] {
        (try? simulatorService.simulators()) ?? []
    }

    func startOf(_ identifier: String) -> String {
        String(identifier.prefix { $0 != "-" })
    }

    func copiesOfXcode(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "that version has to be downloaded again"

        var found: [Leftover] = []
        for copy in xcodeCopies.copies() {
            let name = nameOf(copy)
            announce(name)
            found.append(Leftover(name: name, bytes: copy.bytes, place: .xcodeCopy(copy.path), cost: cost, refusal: refusal(for: copy)))
        }
        return found
    }

    func nameOf(_ copy: XcodeCopy) -> String {
        let whereItSits = copy.path.deletingLastPathComponent().lastPathComponent
        guard let version = copy.version else { return "Xcode — \(whereItSits)" }

        return "Xcode \(version.number) (\(version.build)) — \(whereItSits)"
    }

    func refusal(for copy: XcodeCopy) -> Leftover.Refusal? {
        switch (copy.isOpen, copy.isPointedAtByTheCommandLineTools) {
        case (true, _): .xcodeIsOpen
        case (false, true): .theCommandLineToolsPointAtIt
        case (false, false): nil
        }
    }

    func biggestFirst(_ found: [Leftover]) -> [Leftover] {
        found
            .enumerated()
            .sorted { offered, other in
                offered.element.bytes == other.element.bytes
                    ? offered.offset < other.offset
                    : offered.element.bytes > other.element.bytes
            }
            .map(\.element)
    }
}
