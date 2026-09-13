import Foundation
import Synchronization
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimEngine

let developerFolder = URL(filePath: "/developer")
let derivedDataFolder = developerFolder.appending(path: "Xcode/DerivedData")
let previewsFolder = developerFolder.appending(path: "Xcode/UserData/Previews")

enum LeftoverOnTheMachine: Sendable {
    case folder(URL, Int)
    case simulator(Int)
    case copyOfXcode(Int)

    static func derivedData(taking bytes: Int) -> Self { .folder(derivedDataFolder, bytes) }
    static func previews(taking bytes: Int) -> Self { .folder(previewsFolder, bytes) }
    static func simulator(taking bytes: Int) -> Self { .simulator(bytes) }
    static func copyOfXcode(taking bytes: Int) -> Self { .copyOfXcode(bytes) }
}

extension XcodeLeftovers {
    init(machineHolding held: LeftoverOnTheMachine...) {
        self.init(
            disk: DiskStub(sizes: foldersHeld(in: held)),
            simulatorService: SimulatorServiceStub(taking: simulatorsHeld(in: held)),
            xcodeCopies: XcodeCopiesStub(taking: copiesHeld(in: held)))
    }

    init(theFoldersMeasuredBy disk: DiskSpy) {
        self.init(disk: disk, simulatorService: SimulatorServiceStub(taking: []), xcodeCopies: XcodeCopiesStub(taking: []))
    }

    private init(disk: any Disk & Sendable, simulatorService: any SimulatorService & Sendable, xcodeCopies: any XcodeCopies & Sendable) {
        let anythingIsWorthDeleting = 1

        self.init(
            developerFolder: developerFolder,
            worthDeleting: anythingIsWorthDeleting,
            disk: { disk },
            simulatorService: { simulatorService },
            xcodeCopies: { xcodeCopies })
    }
}

private func foldersHeld(in held: [LeftoverOnTheMachine]) -> [URL: Int] {
    held.reduce(into: [:]) { folders, leftover in
        if case .folder(let folder, let bytes) = leftover { folders[folder] = bytes }
    }
}

private func simulatorsHeld(in held: [LeftoverOnTheMachine]) -> [Int] {
    held.compactMap { if case .simulator(let bytes) = $0 { bytes } else { nil } }
}

private func copiesHeld(in held: [LeftoverOnTheMachine]) -> [Int] {
    held.compactMap { if case .copyOfXcode(let bytes) = $0 { bytes } else { nil } }
}

struct DiskStub: Disk, Sendable {
    let sizes: [URL: Int]

    func bytesUsedByFolder(at url: URL) -> Int {
        sizes[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}

struct SimulatorServiceStub: SimulatorService, Sendable {
    let taking: [Int]

    func simulators() throws -> [Simulator] {
        taking.map {
            Simulator(
                identifier: "21B507D3-909E-465B-957C-4B370278399F",
                name: "iPhone 17",
                runtime: "iOS 26.4",
                isShutDown: true,
                bytes: $0)
        }
    }

    func delete(simulatorWithIdentifier identifier: String) throws {}
}

struct XcodeCopiesStub: XcodeCopies, Sendable {
    let taking: [Int]

    func copies() -> [XcodeCopy] {
        taking.map {
            XcodeCopy(
                path: URL(filePath: "/Applications/Xcode 26.2.app"),
                version: XcodeCopy.Version(number: "26.2", build: "17C51"),
                bytes: $0,
                isOpen: false,
                isPointedAtByCommandLineTools: false)
        }
    }
}

final class DiskSpy: Disk, Sendable {
    private let asked = Mutex<[URL]>([])
    private let answering = Atomic(false)

    var foldersAskedAbout: [URL] {
        asked.withLock { $0 }
    }

    func answerNow() {
        answering.store(true, ordering: .releasing)
    }

    func bytesUsedByFolder(at url: URL) -> Int {
        asked.withLock { $0.append(url) }

        while !answering.load(ordering: .acquiring) {
            sched_yield()
        }
        return 0
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}
