import Foundation
import Synchronization
import XcodeReclaimEngine

final class DiskSpy: Disk, Sendable {
    private let asked = Mutex<[URL]>([])
    private let answering = Atomic(false)
    private let toldToAnswer = NSCondition()

    var foldersAskedAbout: [URL] {
        asked.withLock { $0 }
    }

    func answerNow() {
        toldToAnswer.lock()
        answering.store(true, ordering: .releasing)
        toldToAnswer.broadcast()
        toldToAnswer.unlock()
    }

    func bytesUsedByFolder(at url: URL) -> Int {
        asked.withLock { $0.append(url) }

        toldToAnswer.lock()
        while !answering.load(ordering: .acquiring) {
            toldToAnswer.wait()
        }
        toldToAnswer.unlock()

        return 0
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func removeItem(at url: URL) throws {}
}
