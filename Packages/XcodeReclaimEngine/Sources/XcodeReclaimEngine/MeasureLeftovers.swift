import Foundation
import XcodeReclaimCore

public struct MeasureLeftovers {
    public typealias Running = ([() -> [Leftover]]) -> [[Leftover]]

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
            sources: OfferedFolder.everyOne.map { OfferedFolder(offered: $0, developerFolder: developerFolder, disk: disk) }
                + [
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

    public func leftovers(
        announcing announce: (String) -> Void = { _ in },
        running: Running = { work in work.map { $0() } }
    ) -> [Leftover] {
        let found = withoutActuallyEscaping(announce) { announce in
            running(sources.map { source in { source.leftovers(announcing: announce) } }).flatMap(\.self)
        }

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
