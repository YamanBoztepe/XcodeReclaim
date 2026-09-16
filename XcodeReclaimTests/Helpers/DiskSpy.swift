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
        let minimumConcurrentReads = 2
        let readCount = asked.withLock {
            $0.append(url)
            return $0.count
        }
        if readCount >= minimumConcurrentReads {
            answerNow()
        }

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

    func canRemoveItem(at url: URL) -> Bool { true }

    func removeItem(at url: URL) throws -> Bool { true }
}
