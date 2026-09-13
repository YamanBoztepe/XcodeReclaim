import Foundation
import XcodeReclaimCore

public struct MeasureLeftovers {
    private let sources: [any LeftoverSource]
    private let worthDeleting: Int

    public init(
        developerFolder: URL,
        disk: any Disk,
        simulatorService: any SimulatorService,
        xcodeCopies: any XcodeCopies,
        worthDeleting: Int
    ) {
        self.init(
            sources: [
                OfferedFolders(developerFolder: developerFolder, disk: disk),
                DeviceSupportVersions(developerFolder: developerFolder, disk: disk),
                Simulators(simulatorService: simulatorService),
                CopiesOfXcode(xcodeCopies: xcodeCopies),
            ],
            worthDeleting: worthDeleting)
    }

    init(sources: [any LeftoverSource], worthDeleting: Int) {
        self.sources = sources
        self.worthDeleting = worthDeleting
    }

    public func leftovers(announcing announce: (String) -> Void = { _ in }) -> [Leftover] {
        let found = sources.flatMap { $0.leftovers(announcing: announce) }

        return biggestFirst(found.filter { $0.bytes >= worthDeleting })
    }
}

private extension MeasureLeftovers {
    func biggestFirst(_ found: [Leftover]) -> [Leftover] {
        found
            .enumerated()
            .sorted { offered, other in
                offered.element.bytes == other.element.bytes
                    ? offered.offset < other.offset
                    : offered.element.bytes > other.element.bytes
            }
            .map(\.element)
    }
}
