import Foundation
import Synchronization
import XcodeReclaim
import XcodeReclaimEngine

let developerFolder = URL(filePath: "/developer")
let derivedDataFolder = developerFolder.appending(path: "Xcode/DerivedData")
let previewsFolder = developerFolder.appending(path: "Xcode/UserData/Previews")

@MainActor
func appMeasuring(
    foldersHolding folders: [URL: Int] = [:],
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = []
) -> LeftoverListContainerView {
    appMeasuring(withDisk: DiskStub(holding: folders), simulatorsTaking: simulators, copiesOfXcodeTaking: copies)
}

@MainActor
func appMeasuring(
    withDisk disk: any Disk & Sendable,
    simulatorsTaking simulators: [Int] = [],
    copiesOfXcodeTaking copies: [Int] = []
) -> LeftoverListContainerView {
    let anythingIsWorthDeleting = 1

    return XcodeLeftovers(
        developerFolder: developerFolder,
        worthDeleting: anythingIsWorthDeleting,
        disk: { disk },
        simulatorService: { SimulatorServiceStub(eachTaking: simulators) },
        xcodeCopies: { XcodeCopiesStub(eachTaking: copies) }
    )
    .leftoverList()
}

struct DiskStub: Disk, Sendable {
    let holding: [URL: Int]

    func bytesUsedByFolder(at url: URL) -> Int {
        holding[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}

struct SimulatorServiceStub: SimulatorService, Sendable {
    let eachTaking: [Int]

    func simulators() throws -> [Simulator] {
        eachTaking.map {
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
    let eachTaking: [Int]

    func copies() -> [XcodeCopy] {
        eachTaking.map {
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
