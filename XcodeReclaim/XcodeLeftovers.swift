import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

public struct XcodeLeftovers: Sendable {
    private let measuring: LeftoverListUIComposer.Measuring
    private let deleting: LeftoverListUIComposer.Deleting

    public init(measuring: @escaping LeftoverListUIComposer.Measuring, deleting: @escaping LeftoverListUIComposer.Deleting) {
        self.measuring = measuring
        self.deleting = deleting
    }

    public init(in places: WhereXcodeLeavesThings = .onThisMachine) {
        self.init(measuring: places.measuring, deleting: places.deleting)
    }

    @MainActor public func leftoverList() -> LeftoverListContainerView {
        LeftoverListUIComposer.screen(measuring: measuring, deleting: deleting)
    }
}

private extension WhereXcodeLeavesThings {
    var disk: any Disk { FileManagerDisk() }

    var tool: any Tool { ProcessTool() }

    var simulatorService: any SimulatorService { SimctlSimulatorService(tool: tool) }

    var xcodeCopies: any XcodeCopies { SystemXcodeCopies(tool: tool, disk: disk, applicationsFolder: applicationsFolder) }

    var measureLeftovers: MeasureLeftovers {
        MeasureLeftovers(
            developerFolder: developerFolder,
            disk: disk,
            simulatorService: simulatorService,
            xcodeCopies: xcodeCopies,
            worthDeleting: worthDeleting)
    }

    var deleteLeftover: DeleteLeftover {
        DeleteLeftover(disk: disk, simulatorService: simulatorService)
    }

    var measuring: LeftoverListUIComposer.Measuring {
        { [self] announce in
            let found = await withTaskGroup(of: (Int, [Leftover]).self) { measurings in
                for place in MeasureLeftovers.Offered.allCases.indices {
                    measurings.addTask {
                        (place, measureLeftovers.leftovers(of: MeasureLeftovers.Offered.allCases[place], announcing: announce))
                    }
                }

                return await measurings.reduce(into: [:]) { found, each in found[each.0] = each.1 }
            }

            return measureLeftovers.leftovers(from: found.sorted { $0.key < $1.key }.map(\.value))
        }
    }

    var deleting: LeftoverListUIComposer.Deleting {
        { [self] leftover in deleteLeftover.delete(leftover) }
    }
}
