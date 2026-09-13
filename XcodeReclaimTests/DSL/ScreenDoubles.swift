import Foundation
import Synchronization
import XcodeReclaimCore

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
