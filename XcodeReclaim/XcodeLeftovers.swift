import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimInfra

@MainActor
public final class XcodeLeftovers {
    public typealias Measuring = @Sendable (_ announcing: @Sendable (String) -> Void) -> [Leftover]
    public typealias Deleting = @Sendable (Leftover) -> Deletion

    public private(set) lazy var screen = LeftoverListUIComposer.screen(measuring: measure, deleting: delete)

    private let measuring: Measuring
    private let deleting: Deleting

    public init(measuring: @escaping Measuring, deleting: @escaping Deleting) {
        self.measuring = measuring
        self.deleting = deleting
    }

    public convenience init() {
        let places = WhereXcodeLeavesThings.onThisMachine
        self.init(
            measuring: { announce in whatXcodeLeft(in: places, announcing: announce) },
            deleting: { leftover in whatCameBack(from: leftover, in: places) })
    }
}

private extension XcodeLeftovers {
    func measure(announcing announce: @escaping (String) -> Void, delivering deliver: @escaping ([Leftover]) -> Void) {
        let announced = MainThreadDecorator(announce)
        let measuring = measuring

        MainThreadDecorator(deliver).answer(from: { measuring({ announced($0) }) })
    }

    func delete(_ leftover: Leftover, reporting report: @escaping (Deletion) -> Void) {
        let deleting = deleting

        MainThreadDecorator(report).answer(from: { deleting(leftover) })
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
