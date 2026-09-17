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
    private let xcodeCopyLoader: any XcodeCopyLoader
    private let worthDeleting: Int

    public init(
        developerFolder: URL,
        disk: any Disk,
        simulatorService: any SimulatorService,
        xcodeCopyLoader: any XcodeCopyLoader,
        worthDeleting: Int
    ) {
        self.developerFolder = developerFolder
        self.disk = disk
        self.simulatorService = simulatorService
        self.xcodeCopyLoader = xcodeCopyLoader
        self.worthDeleting = worthDeleting
    }

    public func leftovers(from found: [[Leftover]]) -> [Leftover] {
        biggestFirst(found.flatMap(\.self).filter { $0.bytes >= worthDeleting })
    }

    public func leftovers(of offered: Offered, announcing announce: (String) -> Void) -> [Leftover] {
        switch offered {
        case .derivedData: folderLeftoverLoader(.derivedData).leftovers(announcing: announce)
        case .interfaceBuilderCache: folderLeftoverLoader(.interfaceBuilderCache).leftovers(announcing: announce)
        case .previews: folderLeftoverLoader(.previews).leftovers(announcing: announce)
        case .documentationCache: folderLeftoverLoader(.documentationCache).leftovers(announcing: announce)
        case .deviceSupport: DeviceSupportLeftoverLoader(developerFolder: developerFolder, disk: disk).leftovers(announcing: announce)
        case .simulators: SimulatorLeftoverLoader(simulatorService: simulatorService).leftovers(announcing: announce)
        case .copiesOfXcode: XcodeCopyLeftoverLoader(xcodeCopyLoader: xcodeCopyLoader).leftovers(announcing: announce)
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

    func folderLeftoverLoader(_ offered: FolderLeftoverLoader.Offered) -> FolderLeftoverLoader {
        FolderLeftoverLoader(offered: offered, developerFolder: developerFolder, disk: disk)
    }
}
