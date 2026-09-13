import Foundation
import Synchronization
import XcodeReclaimCore

struct TheMachine: Sendable {
    let announces: [String]
    let finds: [Leftover]

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

final class AMachineHeldUntilLetGo: Sendable {
    private let measurings: [TheMachine]
    private let gates: [DispatchSemaphore]
    private let howManyHaveBegun = Atomic(0)

    init(eachMeasuring measurings: [TheMachine]) {
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

    func theMeasuringFinishes(_ measuring: Int) {
        gates[measuring].signal()
    }

    func everyMeasuringFinishes() {
        for gate in gates {
            gate.signal()
        }
    }
}

struct AMachineThatSaysWhereItRan: Sendable {
    static let roomItSaysTheLeftoverTakes = 300

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let whereItRan = Thread.isMainThread ? "the screen's thread" : "away from the screen's thread"

        return [Leftover(name: whereItRan, bytes: Self.roomItSaysTheLeftoverTakes, place: .folder(URL(filePath: "/developer/\(whereItRan)")))]
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}
