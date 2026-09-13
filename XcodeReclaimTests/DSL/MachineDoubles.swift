import Foundation
import Synchronization
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimEngine

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

final class DiskWhoseFoldersWaitForEachOther: Disk, Sendable {
    private static let secondsAnOverlapShowsItselfIn = 2
    private static let longerThanAnOverlapNeedsToShowItself = DispatchTimeInterval.seconds(secondsAnOverlapShowsItselfIn)

    private let folders: Int
    private let arrived = Atomic(0)
    private let everyFolderHasArrived = DispatchSemaphore(value: 0)
    private let waits = Mutex<[DispatchTimeoutResult]>([])

    init(folders: Int) {
        self.folders = folders
    }

    var howEachFolderWaited: [DispatchTimeoutResult] {
        waits.withLock { $0 }
    }

    func bytesUsedByFolder(at url: URL) -> Int {
        if arrived.wrappingAdd(1, ordering: .relaxed).newValue == folders {
            for _ in 0..<folders {
                everyFolderHasArrived.signal()
            }
        }

        let waited = everyFolderHasArrived.wait(timeout: .now() + Self.longerThanAnOverlapNeedsToShowItself)
        waits.withLock { $0.append(waited) }

        return 0
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}

let anythingIsWorthDeleting = 1

func machine(holding held: [LeftoverOnTheMachine]) -> Machine {
    let folders: [URL: Int] = held.reduce(into: [:]) { folders, leftover in
        if case .folder(let path, let bytes) = leftover { folders[developerFolder.appending(path: path)] = bytes }
    }
    let simulators = held.compactMap { if case .simulator(let bytes) = $0 { bytes } else { nil } }
    let copies = held.compactMap { if case .copyOfXcode(let bytes) = $0 { bytes } else { nil } }

    return Machine(
        developerFolder: developerFolder,
        worthDeleting: anythingIsWorthDeleting,
        disk: { DiskStub(sizes: folders) },
        simulatorService: { SimulatorServiceStub(taking: simulators) },
        xcodeCopies: { XcodeCopiesStub(taking: copies) })
}
