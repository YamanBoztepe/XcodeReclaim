import Foundation
import XcodeReclaimEngine

final class WorldSpy: FolderSizer, FolderLister, RemovalChecker, ItemRemover {
    enum Message: Hashable {
        case announced(String)
        case sizeRead(URL)
        case foldersListed(URL)
        case removed(URL)
        case removalAsked(URL)
    }

    private(set) var messages: [Message] = []

    var sizes: [URL: Int] = [:]
    var folders: [URL: [URL]] = [:]
    var removal: Result<Bool, any Error> = .success(true)
    var whatCanBeRemoved: [URL: Bool] = [:]

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

    func canRemoveItem(at url: URL) -> Bool {
        messages.append(.removalAsked(url))
        return whatCanBeRemoved[url, default: true]
    }

    func removeItem(at url: URL) throws -> Bool {
        messages.append(.removed(url))
        return try removal.get()
    }
}
