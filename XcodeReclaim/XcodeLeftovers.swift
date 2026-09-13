import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

@MainActor
public final class XcodeLeftovers {
    public private(set) lazy var screen = LeftoverListUIComposer.screen(measuring: measure, deleting: delete)

    private let places: WhereXcodeLeavesThings

    public init() {
        places = .onThisMachine
    }
}

private extension XcodeLeftovers {
    func measure(announcing announce: @escaping (String) -> Void, delivering deliver: @escaping ([Leftover]) -> Void) {
        let announced = MainThreadDecorator(announce)
        let whereThingsAre = places

        MainThreadDecorator<[LeftoverCrossing]> { measured in deliver(measured.map(\.leftover)) }
            .answer(from: { whatXcodeLeft(in: whereThingsAre, announcing: { announced($0) }) })
    }

    func delete(_ leftover: Leftover, reporting report: @escaping (Deletion) -> Void) {
        let crossing = LeftoverCrossing(leftover)
        let whereThingsAre = places

        MainThreadDecorator<DeletionCrossing> { deletion in report(deletion.deletion) }
            .answer(from: { whatCameBack(from: crossing, in: whereThingsAre) })
    }
}

private func whatXcodeLeft(in places: WhereXcodeLeavesThings, announcing announce: @Sendable (String) -> Void) -> [LeftoverCrossing] {
    let disk = FileManagerDisk()
    let tool = ProcessTool()
    let measure = MeasureLeftovers(
        developerFolder: places.developerFolder,
        disk: disk,
        simulatorService: SimctlSimulatorService(tool: tool, disk: disk, devicesFolder: places.devicesFolder),
        xcodeCopies: SystemXcodeCopies(tool: tool, disk: disk, applicationsFolder: places.applicationsFolder),
        worthDeleting: places.worthDeleting)

    return measure.leftovers(announcing: announce).map(LeftoverCrossing.init)
}

private func whatCameBack(from crossing: LeftoverCrossing, in places: WhereXcodeLeavesThings) -> DeletionCrossing {
    let disk = FileManagerDisk()
    let simulatorService = SimctlSimulatorService(tool: ProcessTool(), disk: disk, devicesFolder: places.devicesFolder)

    return DeletionCrossing(DeleteLeftover(disk: disk, simulatorService: simulatorService).delete(crossing.leftover))
}
