import Foundation
import XcodeReclaimCore

struct CopiesOfXcode {
    let xcodeCopies: any XcodeCopies

    func leftovers(announcing announce: (String) -> Void) -> [Leftover] {
        let cost = "that version has to be downloaded again"

        return xcodeCopies.copies().map { copy in
            let name = name(of: copy)
            announce(name)

            return Leftover(name: name, bytes: copy.bytes, place: .xcodeCopy(copy.path), cost: cost, refusal: refusal(for: copy))
        }
    }

    private func name(of copy: XcodeCopy) -> String {
        let whereItSits = copy.path.deletingLastPathComponent().lastPathComponent
        guard let version = copy.version else { return "Xcode — \(whereItSits)" }

        return "Xcode \(version.number) (\(version.build)) — \(whereItSits)"
    }

    private func refusal(for copy: XcodeCopy) -> Leftover.Refusal? {
        switch (copy.isOpen, copy.isPointedAtByCommandLineTools) {
        case (true, _): .xcodeIsOpen
        case (false, true): .commandLineToolsPointAtIt
        case (false, false): nil
        }
    }
}
