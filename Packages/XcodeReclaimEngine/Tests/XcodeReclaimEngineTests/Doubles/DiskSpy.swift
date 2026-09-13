import Foundation
import XcodeReclaimEngine

final class DiskSpy: Disk {
    enum Message: Hashable {
        case announced(String)
        case sizeRead(URL)
        case foldersListed(URL)
        case removed(URL)
    }

    private(set) var messages: [Message] = []

    var sizes: [URL: Int] = [:]
    var folders: [URL: [URL]] = [:]
    var removal: Result<Void, any Error> = .success(())

    var announcements: [String] {
        messages.compactMap { message in
            if case .announced(let name) = message { name } else { nil }
        }
    }

    func announce(_ name: String) {
        messages.append(.announced(name))
    }

    func bytesUsedByFolder(at url: URL) -> Int {
        messages.append(.sizeRead(url))
        return sizes[url, default: 0]
    }

    func foldersInside(_ url: URL) -> [URL] {
        messages.append(.foldersListed(url))
        return folders[url, default: []]
    }

    func removeItem(at url: URL) throws {
        messages.append(.removed(url))
        try removal.get()
    }
}
