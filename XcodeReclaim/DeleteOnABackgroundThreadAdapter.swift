import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

@MainActor
final class DeleteOnABackgroundThreadAdapter {
    private let places: WhereXcodeLeavesThings

    init(in places: WhereXcodeLeavesThings) {
        self.places = places
    }

    func delete(_ leftover: Leftover, reporting report: @escaping (Deletion) -> Void) {
        let reported = MainThreadDecorator<DeletionCrossing> { deletion in report(deletion.deletion) }
        let crossing = LeftoverCrossing(leftover)
        let whereThingsAre = places

        Task.detached(priority: .userInitiated) {
            reported(whatCameBack(from: crossing, in: whereThingsAre))
        }
    }
}

private func whatCameBack(from crossing: LeftoverCrossing, in places: WhereXcodeLeavesThings) -> DeletionCrossing {
    let disk = FileManagerDisk()
    let simulatorService = SimctlSimulatorService(tool: ProcessTool(), disk: disk, devicesFolder: places.devicesFolder)

    return DeletionCrossing(DeleteLeftover(disk: disk, simulatorService: simulatorService).delete(crossing.leftover))
}
