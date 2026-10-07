import Foundation
import XcodeReclaimCore

public struct MeasureLeftovers {
    public typealias Disk = FolderSizer & FolderLister

    public enum Offered: CaseIterable {
        case derivedData
        case interfaceBuilderCache
        case previews
        case documentationCache
        case deviceSupport
        case simulators
        case copiesOfXcode
        case runtimes
        case archives
        case swiftPackageCache
        case toolchains
    }

    private let developerFolder: URL
    private let cachesFolder: URL
    private let disk: any Disk
    private let simulatorService: any SimulatorService
    private let runtimeService: any RuntimeService
    private let xcodeCopyLoader: any XcodeCopyLoader
    private let archiveLoader: any ArchiveLoader
    private let toolchainLoader: any ToolchainLoader
    private let worthDeleting: Int

    public init(
        developerFolder: URL,
        cachesFolder: URL,
        disk: any Disk,
        simulatorService: any SimulatorService,
        runtimeService: any RuntimeService,
        xcodeCopyLoader: any XcodeCopyLoader,
        archiveLoader: any ArchiveLoader,
        toolchainLoader: any ToolchainLoader,
        worthDeleting: Int
    ) {
        self.developerFolder = developerFolder
        self.cachesFolder = cachesFolder
        self.disk = disk
        self.simulatorService = simulatorService
        self.runtimeService = runtimeService
        self.xcodeCopyLoader = xcodeCopyLoader
        self.archiveLoader = archiveLoader
        self.toolchainLoader = toolchainLoader
        self.worthDeleting = worthDeleting
    }

    public func leftovers(from found: [[Leftover]]) -> [Leftover] {
        biggestFirst(found.flatMap(\.self).filter { $0.bytes >= worthDeleting })
    }

    public func leftovers(of offered: Offered, announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        switch offered {
        case .derivedData, .interfaceBuilderCache, .previews, .documentationCache, .swiftPackageCache:
            folderLeftovers(of: offered, announcing: announce)
        case .deviceSupport: DeviceSupportLeftoverLoader(developerFolder: developerFolder, disk: disk).leftovers(announcing: announce)
        case .simulators: SimulatorLeftoverLoader(simulatorService: simulatorService).leftovers(announcing: announce)
        case .copiesOfXcode: XcodeCopyLeftoverLoader(xcodeCopyLoader: xcodeCopyLoader).leftovers(announcing: announce)
        case .runtimes: RuntimeLeftoverLoader(runtimeService: runtimeService, simulatorService: simulatorService).leftovers(announcing: announce)
        case .archives: ArchiveLeftoverLoader(archiveLoader: archiveLoader).leftovers(announcing: announce)
        case .toolchains: ToolchainLeftoverLoader(toolchainLoader: toolchainLoader).leftovers(announcing: announce)
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

    func folderLeftovers(of offered: Offered, announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        switch offered {
        case .derivedData: folderLeftoverLoader(.derivedData, under: developerFolder).leftovers(announcing: announce)
        case .interfaceBuilderCache: folderLeftoverLoader(.interfaceBuilderCache, under: developerFolder).leftovers(announcing: announce)
        case .previews: folderLeftoverLoader(.previews, under: developerFolder).leftovers(announcing: announce)
        case .documentationCache: folderLeftoverLoader(.documentationCache, under: developerFolder).leftovers(announcing: announce)
        case .swiftPackageCache: folderLeftoverLoader(.swiftPackageCache, under: cachesFolder).leftovers(announcing: announce)
        case .deviceSupport, .simulators, .copiesOfXcode, .runtimes, .archives, .toolchains: []
        }
    }

    func folderLeftoverLoader(_ folder: FolderLeftoverLoader.Folder, under root: URL) -> FolderLeftoverLoader {
        FolderLeftoverLoader(folder: folder, root: root, disk: disk)
    }
}
