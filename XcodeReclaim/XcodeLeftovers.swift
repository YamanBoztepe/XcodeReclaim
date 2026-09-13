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

        MainThreadDecorator(deliver)
            .answer(from: { whatXcodeLeft(in: whereThingsAre, announcing: { announced($0) }) })
    }

    func delete(_ leftover: Leftover, reporting report: @escaping (Deletion) -> Void) {
        let whereThingsAre = places

        MainThreadDecorator(report)
            .answer(from: { whatCameBack(from: $0, in: whereThingsAre) }, given: leftover)
    }
}

private func whatXcodeLeft(in places: WhereXcodeLeavesThings, announcing announce: @Sendable (String) -> Void) -> [Leftover] {
    let disk = FileManagerDisk()
    let tool = ProcessTool()
    let measure = MeasureLeftovers(
        developerFolder: places.developerFolder,
        disk: disk,
        simulatorService: SimctlSimulatorService(tool: tool, disk: disk, devicesFolder: places.devicesFolder),
        xcodeCopies: SystemXcodeCopies(tool: tool, disk: disk, applicationsFolder: places.applicationsFolder),
        worthDeleting: places.worthDeleting)

    return measure.leftovers(announcing: announce)
}

private func whatCameBack(from leftover: Leftover, in places: WhereXcodeLeavesThings) -> Deletion {
    let disk = FileManagerDisk()
    let simulatorService = SimctlSimulatorService(tool: ProcessTool(), disk: disk, devicesFolder: places.devicesFolder)

    return DeleteLeftover(disk: disk, simulatorService: simulatorService).delete(leftover)
}
