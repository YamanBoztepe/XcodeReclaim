import Synchronization
import XcodeReclaimCore

final class LateAnnouncingMachineStub: Sendable {
    private let measurings: [MachineStub]
    private let howManyHaveBegun = Atomic(0)
    private let howManyHaveAnswered = Atomic(0)
    private let pendingMeasurings = Mutex(PendingMeasurings())

    init(eachMeasuring measurings: [MachineStub]) {
        self.measurings = measurings
    }

    var measuringsBegun: Int {
        howManyHaveBegun.load(ordering: .acquiring)
    }

    var measuringsAnswered: Int {
        howManyHaveAnswered.load(ordering: .acquiring)
    }

    func measuring(announcing announce: @Sendable (Leftover.Kind, Leftover.Place) -> Void) async -> [Leftover] {
        let thisMeasuring = howManyHaveBegun.wrappingAdd(1, ordering: .acquiringAndReleasing).oldValue

        await withCheckedContinuation { continuation in
            pendingMeasurings.withLock { $0.resume(continuation, whenFinished: thisMeasuring) }
        }

        let found = measurings[thisMeasuring].measuring(announcing: announce)
        howManyHaveAnswered.wrappingAdd(1, ordering: .acquiringAndReleasing)
        return found
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }

    func letMeasuringFinish(_ measuring: Int) {
        pendingMeasurings.withLock { $0.finish([measuring]) }
    }
}
