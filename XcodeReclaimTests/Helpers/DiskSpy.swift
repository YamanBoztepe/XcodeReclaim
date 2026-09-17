import Foundation
import Synchronization
import XcodeReclaimEngine

final class DiskSpy: Disk, Sendable {
    private let asked = Mutex<[URL]>([])
    private let held: [URL: ReadGate]
    private let neverHeld = ReadGate(isOpen: true)

    init(holding folders: [URL]) {
        held = Dictionary(uniqueKeysWithValues: folders.map { ($0, ReadGate(isOpen: false)) })
    }

    var foldersAskedAbout: [URL] {
        asked.withLock { $0 }
    }

    func answerNow() {
        for gate in held.values {
            gate.open()
        }
    }

    func bytesUsedByFolder(at url: URL) -> Int {
        asked.withLock { $0.append(url) }
        held[url, default: neverHeld].pass()

        return 0
    }

    func foldersInside(_ url: URL) -> [URL] {
        []
    }

    func canRemoveItem(at url: URL) -> Bool { true }

    func removeItem(at url: URL) throws -> Bool { true }

    private final class ReadGate: Sendable {
        private let isOpen: Atomic<Bool>
        private let opened = NSCondition()

        init(isOpen: Bool) {
            self.isOpen = Atomic(isOpen)
        }

        func pass() {
            opened.lock()
            while !isOpen.load(ordering: .acquiring) {
                opened.wait()
            }
            opened.unlock()
        }

        func open() {
            opened.lock()
            isOpen.store(true, ordering: .releasing)
            opened.broadcast()
            opened.unlock()
        }
    }
}
