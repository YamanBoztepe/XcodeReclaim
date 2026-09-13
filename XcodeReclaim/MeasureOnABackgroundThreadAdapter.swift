import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

@MainActor
final class MeasureOnABackgroundThreadAdapter {
    private let places: WhereXcodeLeavesThings

    init(in places: WhereXcodeLeavesThings) {
        self.places = places
    }

    func measure(announcing announce: @escaping (String) -> Void, delivering deliver: @escaping ([Leftover]) -> Void) {
        let announced = MainThreadDecorator<String>(announce)
        let delivered = MainThreadDecorator<[LeftoverCrossing]> { measured in deliver(measured.map(\.leftover)) }
        let whereThingsAre = places

        Task.detached(priority: .userInitiated) {
            delivered(whatXcodeLeft(in: whereThingsAre, announcing: { announced($0) }))
        }
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
