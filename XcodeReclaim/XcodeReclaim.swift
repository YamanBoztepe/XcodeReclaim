import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine

public struct XcodeReclaim: Sendable {
    public typealias DiskFactory = @Sendable () -> any MeasureLeftovers.Disk & DeleteLeftover.Disk
    public typealias SimulatorServiceFactory = @Sendable () -> any SimulatorService
    public typealias RuntimeServiceFactory = @Sendable () -> any RuntimeService
    public typealias XcodeCopyLoaderFactory = @Sendable () -> any XcodeCopyLoader
    public typealias ArchiveLoaderFactory = @Sendable () -> any ArchiveLoader
    public typealias ToolchainLoaderFactory = @Sendable () -> any ToolchainLoader

    private let developerFolder: URL
    private let cachesFolder: URL
    private let worthDeleting: Int
    private let disk: DiskFactory
    private let simulatorService: SimulatorServiceFactory
    private let runtimeService: RuntimeServiceFactory
    private let xcodeCopyLoader: XcodeCopyLoaderFactory
    private let archiveLoader: ArchiveLoaderFactory
    private let toolchainLoader: ToolchainLoaderFactory
    private let calendar: Calendar

    public init(
        developerFolder: URL,
        cachesFolder: URL,
        worthDeleting: Int,
        disk: @escaping DiskFactory,
        simulatorService: @escaping SimulatorServiceFactory,
        runtimeService: @escaping RuntimeServiceFactory,
        xcodeCopyLoader: @escaping XcodeCopyLoaderFactory,
        archiveLoader: @escaping ArchiveLoaderFactory,
        toolchainLoader: @escaping ToolchainLoaderFactory,
        calendar: Calendar
    ) {
        self.developerFolder = developerFolder
        self.cachesFolder = cachesFolder
        self.worthDeleting = worthDeleting
        self.disk = disk
        self.simulatorService = simulatorService
        self.runtimeService = runtimeService
        self.xcodeCopyLoader = xcodeCopyLoader
        self.archiveLoader = archiveLoader
        self.toolchainLoader = toolchainLoader
        self.calendar = calendar
    }

    @MainActor public func leftoverList() -> LeftoverListContainerView {
        LeftoverListUIComposer.screen(measuring: measuring, deleting: deleting, calendar: calendar)
    }
}

private extension XcodeReclaim {
    var measureLeftovers: MeasureLeftovers {
        MeasureLeftovers(
            developerFolder: developerFolder,
            cachesFolder: cachesFolder,
            disk: disk(),
            simulatorService: simulatorService(),
            runtimeService: runtimeService(),
            xcodeCopyLoader: xcodeCopyLoader(),
            archiveLoader: archiveLoader(),
            toolchainLoader: toolchainLoader(),
            worthDeleting: worthDeleting)
    }

    var measuring: LeftoverListUIComposer.Measuring {
        { [self] announce in measureLeftovers.leftovers(from: await everySourceAtOnce(announcing: announce)) }
    }

    var deleting: LeftoverListUIComposer.Deleting {
        { [self] leftover in DeleteLeftover(disk: disk(), simulatorService: simulatorService(), runtimeService: runtimeService()).delete(leftover) }
    }

    func everySourceAtOnce(announcing announce: @escaping @Sendable (Leftover.Kind, Leftover.Place) -> Void) async -> [[Leftover]] {
        await withTaskGroup(of: (Int, [Leftover]).self) { measurings in
            for source in MeasureLeftovers.Offered.allCases.indices {
                measurings.addTask { [self] in (source, measureLeftovers.leftovers(of: MeasureLeftovers.Offered.allCases[source], announcing: announce)) }
            }

            var found = Array(repeating: [Leftover](), count: MeasureLeftovers.Offered.allCases.count)
            for await (source, leftovers) in measurings {
                found[source] = leftovers
            }

            return found
        }
    }
}
