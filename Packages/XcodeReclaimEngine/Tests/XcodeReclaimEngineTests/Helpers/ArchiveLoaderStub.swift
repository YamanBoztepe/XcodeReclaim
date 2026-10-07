import XcodeReclaimEngine

final class ArchiveLoaderStub: ArchiveLoader {
    var reported: [Archive] = []

    func load() -> [Archive] {
        reported
    }
}
