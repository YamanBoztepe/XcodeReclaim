import XcodeReclaimCore

struct ArchiveLeftoverLoader {
    let archiveLoader: any ArchiveLoader

    func leftovers(announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        archiveLoader.load().map { archive in
            let kind = Leftover.Kind.archive(name: archive.name, version: archive.version, build: archive.build, created: archive.created)
            let place = Leftover.Place.folder(archive.path)
            announce(kind, place)

            return Leftover(kind: kind, bytes: archive.bytes, place: place)
        }
    }
}
