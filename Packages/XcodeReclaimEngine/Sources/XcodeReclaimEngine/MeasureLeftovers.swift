import Foundation
import XcodeReclaimCore

public struct MeasureLeftovers {
    public enum Offered: CaseIterable {
        case derivedData
        case interfaceBuilderCache
        case previews
        case documentationCache
        case deviceSupport
        case simulators
        case copiesOfXcode
    }

    private let developerFolder: URL
    private let disk: any Disk
    private let simulatorService: any SimulatorService
    private let xcodeCopies: any XcodeCopies
    private let worthDeleting: Int

    public init(
        developerFolder: URL,
        disk: any Disk,
        simulatorService: any SimulatorService,
        xcodeCopies: any XcodeCopies,
        worthDeleting: Int
    ) {
        self.developerFolder = developerFolder
        self.disk = disk
        self.simulatorService = simulatorService
        self.xcodeCopies = xcodeCopies
        self.worthDeleting = worthDeleting
    }

    public func leftovers(announcing announce: (String) -> Void = { _ in }) -> [Leftover] {
        leftovers(from: Offered.allCases.map { leftovers(of: $0, announcing: announce) })
    }

    public func leftovers(from found: [[Leftover]]) -> [Leftover] {
        biggestFirst(found.flatMap(\.self).filter { $0.bytes >= worthDeleting })
    }

    public func leftovers(of offered: Offered, announcing announce: (String) -> Void = { _ in }) -> [Leftover] {
        switch offered {
        case .derivedData: offeredFolder(.derivedData).leftovers(announcing: announce)
        case .interfaceBuilderCache: offeredFolder(.interfaceBuilderCache).leftovers(announcing: announce)
        case .previews: offeredFolder(.previews).leftovers(announcing: announce)
        case .documentationCache: offeredFolder(.documentationCache).leftovers(announcing: announce)
        case .deviceSupport: DeviceSupportVersions(developerFolder: developerFolder, disk: disk).leftovers(announcing: announce)
        case .simulators: Simulators(simulatorService: simulatorService).leftovers(announcing: announce)
        case .copiesOfXcode: CopiesOfXcode(xcodeCopies: xcodeCopies).leftovers(announcing: announce)
        }
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

    func offeredFolder(_ offered: OfferedFolder.Offered) -> OfferedFolder {
        OfferedFolder(offered: offered, developerFolder: developerFolder, disk: disk)
    }
}
