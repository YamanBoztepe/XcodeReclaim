import Foundation
import Synchronization
import XcodeReclaimCore

final class MachineThreadSpy: Sendable {
    private let ranOnTheScreensThread = Mutex<[Bool]>([])

    var whereEachMeasuringRan: [String] {
        ranOnTheScreensThread.withLock { $0 }.map { $0 ? "the screen's thread" : "away from the screen's thread" }
    }

    func measuring(announcing _: @Sendable (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        ranOnTheScreensThread.withLock { $0.append(Thread.isMainThread) }

        return []
    }
}
