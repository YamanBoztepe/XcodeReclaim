import XcodeReclaimCore

struct MachineStub: Sendable {
    private let announces: [Leftover]
    private let finds: [Leftover]

    init(announcing announces: [Leftover] = [], finding finds: [Leftover] = []) {
        self.announces = announces
        self.finds = finds
    }

    func measuring(announcing announce: @Sendable (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        for leftover in announces {
            announce(leftover.kind, leftover.place)
        }
        return finds
    }

    func deleting(_ leftover: Leftover) -> Deletion {
        .freed(leftover.bytes)
    }
}
