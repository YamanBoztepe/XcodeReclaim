import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine

public struct XcodeReclaim: Sendable {
    public typealias DiskFactory = @Sendable () -> any Disk
    public typealias SimulatorServiceFactory = @Sendable () -> any SimulatorService
    public typealias XcodeCopyLoaderFactory = @Sendable () -> any XcodeCopyLoader

    private let developerFolder: URL
    private let worthDeleting: Int
    private let disk: DiskFactory
    private let simulatorService: SimulatorServiceFactory
    private let xcodeCopyLoader: XcodeCopyLoaderFactory

    public init(
        developerFolder: URL,
        worthDeleting: Int,
        disk: @escaping DiskFactory,
        simulatorService: @escaping SimulatorServiceFactory,
        xcodeCopyLoader: @escaping XcodeCopyLoaderFactory
    ) {
        self.developerFolder = developerFolder
        self.worthDeleting = worthDeleting
        self.disk = disk
        self.simulatorService = simulatorService
        self.xcodeCopyLoader = xcodeCopyLoader
    }

    @MainActor public func leftoverList() -> LeftoverListContainerView {
        LeftoverListUIComposer.screen(measuring: measuring, deleting: deleting)
    }
}

private extension XcodeReclaim {
    var measureLeftovers: MeasureLeftovers {
        MeasureLeftovers(
            developerFolder: developerFolder,
            disk: disk(),
            simulatorService: simulatorService(),
            xcodeCopyLoader: xcodeCopyLoader(),
            worthDeleting: worthDeleting)
    }

    var measuring: LeftoverListUIComposer.Measuring {
        { [self] announce in measureLeftovers.leftovers(from: await everySourceAtOnce(announcing: announce)) }
    }

    var deleting: LeftoverListUIComposer.Deleting {
        { [self] leftover in DeleteLeftover(disk: disk(), simulatorService: simulatorService()).delete(leftover) }
    }

    func everySourceAtOnce(announcing announce: @escaping @Sendable (String) -> Void) async -> [[Leftover]] {
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
