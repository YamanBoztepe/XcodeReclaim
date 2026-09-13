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
    private let gates: [DispatchSemaphore]
    private let howManyHaveBegun = Atomic(0)

    init(eachMeasuring measurings: [MachineStub]) {
        self.measurings = measurings
        gates = measurings.map { _ in DispatchSemaphore(value: 0) }
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.wrappingAdd(1, ordering: .relaxed).oldValue
        let found = measurings[thisMeasuring].measuring(announcing: announce)
        gates[thisMeasuring].wait()

        return found
    }

    func letMeasuringFinish(_ measuring: Int) {
        gates[measuring].signal()
    }

    func letEveryMeasuringFinish() {
        for gate in gates {
            gate.signal()
        }
    }
}

final class MachineThreadSpy: Sendable {
    private let ranOn = Mutex<[String]>([])

    var whereEachMeasuringRan: [String] {
        ranOn.withLock { $0 }
    }

    func measuring(announcing _: @Sendable (String) -> Void) -> [Leftover] {
        ranOn.withLock { $0.append(Thread.isMainThread ? "the screen's thread" : "away from the screen's thread") }

        return []
    }
}
