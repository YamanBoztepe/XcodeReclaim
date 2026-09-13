import Foundation
import Synchronization
import XcodeReclaimCore

enum AllAtOnce {
    static func running(_ work: [() -> [Leftover]]) -> [[Leftover]] {
        nonisolated(unsafe) let together = work
        let found = Mutex<[Int: [Leftover]]>([:])

        DispatchQueue.concurrentPerform(iterations: together.count) { each in
            let answered = together[each]()
            found.withLock { $0[each] = answered }
        }

        return found.withLock { answers in (0..<together.count).map { answers[$0] ?? [] } }
    }
}
