import Foundation
import XcodeReclaimCore

struct XcodeCopyLeftoverLoader {
    let xcodeCopyLoader: any XcodeCopyLoader

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        xcodeCopyLoader.load().map { copy in
            let kind = kind(of: copy)
            let place = Leftover.Place.xcodeCopy(copy.path)
            announce(kind, place)

            return Leftover(kind: kind, bytes: copy.bytes, place: place, refusal: refusal(for: copy))
        }
    }

    private func kind(of copy: XcodeCopy) -> Leftover.Kind {
        .xcodeCopy(
            version: copy.version.map { Leftover.XcodeVersion(number: $0.number, build: $0.build) },
            canBeRemovedWhereItStands: copy.canBeRemoved)
    }

    private func refusal(for copy: XcodeCopy) -> Leftover.Refusal? {
        switch (copy.isOpen, copy.isPointedAtByCommandLineTools) {
        case (true, _): .xcodeIsOpen
        case (false, true): .commandLineToolsPointAtIt
        case (false, false): nil
        }
    }
}
