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

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
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

struct ThreadReportingMachineStub: Sendable {
    private let roomItSaysTheLeftoverTakes = 300

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let whereItRan = Thread.isMainThread ? "the screen's thread" : "away from the screen's thread"

        return [Leftover(name: whereItRan, bytes: roomItSaysTheLeftoverTakes, place: .folder(URL(filePath: "/developer/\(whereItRan)")))]
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}
