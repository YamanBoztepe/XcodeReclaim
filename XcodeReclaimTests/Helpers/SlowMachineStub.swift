import Foundation
import Synchronization
import XcodeReclaimCore

final class SlowMachineStub: Sendable {
    private let measurings: [MachineStub]
    private let finished = Mutex<Set<Int>>([])
    private let howManyHaveBegun = Atomic(0)
    private let toldToFinish = NSCondition()

    init(eachMeasuring measurings: [MachineStub]) {
        self.measurings = measurings
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.wrappingAdd(1, ordering: .relaxed).oldValue
        let found = measurings[thisMeasuring].measuring(announcing: announce)

        toldToFinish.lock()
        while !finished.withLock({ $0.contains(thisMeasuring) }) {
            toldToFinish.wait()
        }
        toldToFinish.unlock()

        return found
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }

    func letMeasuringFinish(_ measuring: Int) {
        toldToFinish.lock()
        finished.withLock { _ = $0.insert(measuring) }
        toldToFinish.broadcast()
        toldToFinish.unlock()
    }

    func letEveryMeasuringFinish() {
        toldToFinish.lock()
        finished.withLock { $0.formUnion(measurings.indices) }
        toldToFinish.broadcast()
        toldToFinish.unlock()
    }
}
