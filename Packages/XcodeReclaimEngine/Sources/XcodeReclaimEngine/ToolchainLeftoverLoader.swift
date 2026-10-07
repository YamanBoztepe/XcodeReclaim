import XcodeReclaimCore

struct ToolchainLeftoverLoader {
    let toolchainLoader: any ToolchainLoader

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        toolchainLoader.load().map { toolchain in
            let kind = Leftover.Kind.toolchain(name: toolchain.name)
            let place = Leftover.Place.folder(toolchain.path)
            announce(kind, place)

            return Leftover(kind: kind, bytes: toolchain.bytes, place: place, refusal: toolchain.isPointedAtBySwiftLatest ? .swiftLatestPointsAtIt : nil)
        }
    }
}
