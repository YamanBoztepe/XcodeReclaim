import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

struct WhereXcodeLeavesThings: Sendable {
    let developerFolder: URL
    let devicesFolder: URL
    let applicationsFolder: URL
    let worthDeleting: Int

    static let whatIsWorthDeleting = 100_000_000

    static let onThisMachine = WhereXcodeLeavesThings(
        developerFolder: URL(filePath: NSHomeDirectory()).appending(path: "Library/Developer"),
        devicesFolder: URL(filePath: NSHomeDirectory()).appending(path: "Library/Developer/CoreSimulator/Devices"),
        applicationsFolder: URL(filePath: "/Applications"),
        worthDeleting: whatIsWorthDeleting)
}

@MainActor
enum TheMachine {
    static func measuring(_ announce: @escaping XcodeLeftovers.Announcing, _ deliver: @escaping XcodeLeftovers.Delivering) {
        let places = WhereXcodeLeavesThings.onThisMachine
        Task.detached(priority: .userInitiated) {
            let measured = whatXcodeLeft(in: places, announcing: { name in Task { @MainActor in announce(name) } })
            await MainActor.run { deliver(measured) }
        }
    }

    static func deleting(_ crossing: LeftoverCrossing, _ report: @escaping XcodeLeftovers.Reporting) {
        let places = WhereXcodeLeavesThings.onThisMachine
        Task.detached(priority: .userInitiated) {
            let deletion = whatCameBack(from: crossing, in: places)
            await MainActor.run { report(deletion) }
        }
    }
}

private extension TheMachine {
    nonisolated static func whatXcodeLeft(in places: WhereXcodeLeavesThings, announcing announce: @Sendable (String) -> Void) -> [LeftoverCrossing] {
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

    nonisolated static func whatCameBack(from crossing: LeftoverCrossing, in places: WhereXcodeLeavesThings) -> DeletionCrossing {
        let disk = FileManagerDisk()
        let deleter = DeleteLeftover(disk: disk, simulatorService: SimctlSimulatorService(tool: ProcessTool(), disk: disk, devicesFolder: places.devicesFolder))
        return DeletionCrossing(deleter.delete(crossing.leftover))
    }
}
