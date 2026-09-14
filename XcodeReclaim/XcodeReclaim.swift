import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine

public struct XcodeReclaim: Sendable {
    public typealias MakingADisk = @Sendable () -> any Disk
    public typealias MakingASimulatorService = @Sendable () -> any SimulatorService
    public typealias MakingXcodeCopies = @Sendable () -> any XcodeCopies

    private let developerFolder: URL
    private let worthDeleting: Int
    private let disk: MakingADisk
    private let simulatorService: MakingASimulatorService
    private let xcodeCopies: MakingXcodeCopies

    public init(
        developerFolder: URL,
        worthDeleting: Int,
        disk: @escaping MakingADisk,
        simulatorService: @escaping MakingASimulatorService,
        xcodeCopies: @escaping MakingXcodeCopies
    ) {
        self.developerFolder = developerFolder
        self.worthDeleting = worthDeleting
        self.disk = disk
        self.simulatorService = simulatorService
        self.xcodeCopies = xcodeCopies
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
            xcodeCopies: xcodeCopies(),
            worthDeleting: worthDeleting)
    }

    var measuring: LeftoverListUIComposer.Measuring {
        { [self] announce in measureLeftovers.leftovers(from: await everySourceAtOnce(announcing: announce)) }
    }

    var deleting: LeftoverListUIComposer.Deleting {
        { [self] leftover in DeleteLeftover(disk: disk(), simulatorService: simulatorService()).delete(leftover) }
    }

    func everySourceAtOnce(announcing announce: @escaping @Sendable (String) -> Void) async -> [[Leftover]] {
        let measured = await withTaskGroup(of: (Int, [Leftover]).self) { measurings in
            for source in MeasureLeftovers.Offered.allCases.indices {
                measurings.addTask { [self] in (source, measureLeftovers.leftovers(of: MeasureLeftovers.Offered.allCases[source], announcing: announce)) }
            }

            return await measurings.reduce(into: [Int: [Leftover]]()) { measured, each in measured[each.0] = each.1 }
        }

        return measured.sorted { $0.key < $1.key }.map(\.value)
    }
}
