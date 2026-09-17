import Synchronization
import XcodeReclaimCore

final class SlowMachineStub: Sendable {
    private let measurings: [MachineStub]
    private let howManyHaveBegun = Atomic(0)
    private let pendingMeasurings = Mutex(PendingMeasurings())

    init(eachMeasuring measurings: [MachineStub]) {
        self.measurings = measurings
    }

    func measuring(announcing announce: @Sendable (Leftover.Kind, Leftover.Place) -> Void) async -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.wrappingAdd(1, ordering: .relaxed).oldValue
        let found = measurings[thisMeasuring].measuring(announcing: announce)

        await withCheckedContinuation { continuation in
            pendingMeasurings.withLock { $0.resume(continuation, whenFinished: thisMeasuring) }
        }

        return found
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }

    func letMeasuringFinish(_ measuring: Int) {
        pendingMeasurings.withLock { $0.finish([measuring]) }
    }

    func letEveryMeasuringFinish() {
        pendingMeasurings.withLock { $0.finish(Set(measurings.indices)) }
    }
}

private struct PendingMeasurings {
    private var finishedMeasurings: Set<Int> = []
    private var continuations: [Int: CheckedContinuation<Void, Never>] = [:]

    mutating func resume(_ continuation: CheckedContinuation<Void, Never>, whenFinished measuring: Int) {
        guard !finishedMeasurings.contains(measuring) else {
            continuation.resume()
            return
        }

        continuations[measuring] = continuation
    }

    mutating func finish(_ measurings: Set<Int>) {
        finishedMeasurings.formUnion(measurings)
        for measuring in measurings {
            continuations.removeValue(forKey: measuring)?.resume()
        }
    }
}
