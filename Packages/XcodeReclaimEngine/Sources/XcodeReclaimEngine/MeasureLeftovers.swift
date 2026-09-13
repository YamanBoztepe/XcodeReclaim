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

    public func leftovers(of offered: Offered, announcing announce: (String) -> Void = { _ in }) -> [Leftover] {
        source(for: offered).leftovers(announcing: announce)
    }

    public func leftovers(from found: [[Leftover]]) -> [Leftover] {
        biggestFirst(found.flatMap(\.self).filter { $0.bytes >= worthDeleting })
    }
}

private extension MeasureLeftovers {
    func source(for offered: Offered) -> any LeftoverSource {
        switch offered {
        case .derivedData: OfferedFolder(offered: .derivedData, developerFolder: developerFolder, disk: disk)
        case .interfaceBuilderCache: OfferedFolder(offered: .interfaceBuilderCache, developerFolder: developerFolder, disk: disk)
        case .previews: OfferedFolder(offered: .previews, developerFolder: developerFolder, disk: disk)
        case .documentationCache: OfferedFolder(offered: .documentationCache, developerFolder: developerFolder, disk: disk)
        case .deviceSupport: DeviceSupportVersions(developerFolder: developerFolder, disk: disk)
        case .simulators: Simulators(simulatorService: simulatorService)
        case .copiesOfXcode: CopiesOfXcode(xcodeCopies: xcodeCopies)
        }
    }

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
