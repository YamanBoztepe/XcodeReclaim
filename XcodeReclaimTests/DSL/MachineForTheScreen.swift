import Foundation
import XcodeReclaim
import Synchronization
import XcodeReclaimCore

@MainActor
func screenMeasuring(_ machine: MachineStub) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
}

@MainActor
func screenMeasuring(_ machine: SlowMachineStub) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
}

@MainActor
func screenMeasuring(_ machine: MachineThreadSpy) -> LeftoverListContainerView {
    LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: MachineStub().deleting)
}

struct MachineStub: Sendable {
    private let announces: [String]
    private let finds: [Leftover]

    init(announcing announces: [String] = [], finding finds: [Leftover] = []) {
        self.announces = announces
        self.finds = finds
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        for name in announces {
            announce(name)
        }
        return finds
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}

final class SlowMachineStub: Sendable {
    private let measurings: [MachineStub]
    private let finished = Mutex<Set<Int>>([])
    private let howManyHaveBegun = Atomic(0)

    init(eachMeasuring measurings: [MachineStub]) {
        self.measurings = measurings
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.wrappingAdd(1, ordering: .relaxed).oldValue
        let found = measurings[thisMeasuring].measuring(announcing: announce)

        while !finished.withLock({ $0.contains(thisMeasuring) }) {
            sched_yield()
        }
        return found
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }

    func letMeasuringFinish(_ measuring: Int) {
        finished.withLock { _ = $0.insert(measuring) }
    }

    func letEveryMeasuringFinish() {
        finished.withLock { $0.formUnion(measurings.indices) }
    }
}

final class MachineThreadSpy: Sendable {
    private let ranOnTheScreensThread = Mutex<[Bool]>([])

    var whereEachMeasuringRan: [String] {
        ranOnTheScreensThread.withLock { $0 }.map { $0 ? "the screen's thread" : "away from the screen's thread" }
    }

    func measuring(announcing _: @Sendable (String) -> Void) -> [Leftover] {
        ranOnTheScreensThread.withLock { $0.append(Thread.isMainThread) }

        return []
    }
}

func derivedData(taking bytes: Int) -> Leftover {
    Leftover(name: "Derived data", bytes: bytes, place: .folder(developerFolder.appending(path: "Xcode/DerivedData")))
}

func previews(taking bytes: Int) -> Leftover {
    Leftover(name: "Previews", bytes: bytes, place: .folder(developerFolder.appending(path: "Xcode/UserData/Previews")))
}

func simulator(taking bytes: Int) -> Leftover {
    Leftover(
        name: "iPhone 17 (iOS 26.4, 21B507D3)",
        bytes: bytes,
        place: .simulator("21B507D3-909E-465B-957C-4B370278399F"),
        cost: "the apps inside it and their data are gone")
}

func copyOfXcode(taking bytes: Int) -> Leftover {
    Leftover(
        name: "Xcode 26.2 (17C51) — Applications",
        bytes: bytes,
        place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")),
        cost: "that version has to be downloaded again")
}
