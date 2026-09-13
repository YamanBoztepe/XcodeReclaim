import Foundation
import Synchronization
import XcodeReclaimCore

struct TheMachine: Sendable {
    let finds: [Leftover]
    let announces: [String]

    init(finds: [Leftover] = [], announces: [String] = []) {
        self.finds = finds
        self.announces = announces
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

final class AMeasuringThatAnnouncesThenWaits: Sendable {
    private let held = DispatchSemaphore(value: 0)
    private let finds: [Leftover]
    private let announces: [String]

    init(finds: [Leftover] = [], announces: [String] = []) {
        self.finds = finds
        self.announces = announces
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        for name in announces {
            announce(name)
        }
        held.wait()
        return finds
    }

    func itFinishes() {
        held.signal()
    }
}

final class AMeasuringThatWaitsThenAnnounces: Sendable {
    private let gates = [DispatchSemaphore(value: 0), DispatchSemaphore(value: 0)]
    private let howManyHaveBegun = Mutex(0)
    private let finds: [[Leftover]]
    private let announces: [[String]]

    init(finds: [[Leftover]], announces: [[String]]) {
        self.finds = finds
        self.announces = announces
    }

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.withLock { begun in
            begun += 1
            return begun - 1
        }
        gates[thisMeasuring].wait()

        for name in announces[thisMeasuring] {
            announce(name)
        }
        return finds[thisMeasuring]
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

final class AMachineThatSaysWhereItRan: Sendable {
    static let roomItSaysTheLeftoverTakes = 300

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let whereItRan = Thread.isMainThread ? "the screen's thread" : "away from the screen's thread"
        let place = Leftover.Place.folder(URL(filePath: "/developer/\(whereItRan)"))

        announce(whereItRan)
        return [Leftover(name: whereItRan, bytes: Self.roomItSaysTheLeftoverTakes, place: place)]
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}
