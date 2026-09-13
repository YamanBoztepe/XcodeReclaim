import Foundation
import XcodeReclaimCore

struct TheMachine: Sendable {
    let finds: [Leftover]
    let announces: [String]

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        for name in announces {
            announce(name)
        }
        return finds
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}

struct TheMachineThatSaysWhereItRan: Sendable {
    static let roomItSaysTheLeftoverTakes = 300

    func measuring(announcing announce: @Sendable (String) -> Void) -> [Leftover] {
        let whereItRan = Thread.isMainThread ? "the screen's thread" : "away from the screen's thread"
        let place = Leftover.Place.folder(URL(filePath: "/developer/\(whereItRan)"))

        return [Leftover(name: whereItRan, bytes: Self.roomItSaysTheLeftoverTakes, place: place)]
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}
