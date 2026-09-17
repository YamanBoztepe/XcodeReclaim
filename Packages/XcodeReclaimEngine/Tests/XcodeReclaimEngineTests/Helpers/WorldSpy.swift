import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine

final class WorldSpy: FolderSizer, FolderLister, RemovalChecker, ItemRemover {
    enum Message: Hashable {
        case announced(Leftover.Kind)
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

    var announcements: [Leftover.Kind] {
        messages.compactMap { message in
            if case .announced(let kind) = message { kind } else { nil }
        }
    }

    func announce(_ kind: Leftover.Kind, at place: Leftover.Place) {
        messages.append(.announced(kind))
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
