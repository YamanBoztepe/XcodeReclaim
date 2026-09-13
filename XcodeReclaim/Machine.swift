import Foundation
import XcodeReclaimEngine
import XcodeReclaimInfra

public struct Machine: Sendable {
    public typealias MakingADisk = @Sendable () -> any Disk
    public typealias MakingASimulatorService = @Sendable () -> any SimulatorService
    public typealias MakingXcodeCopies = @Sendable () -> any XcodeCopies

    let developerFolder: URL
    let worthDeleting: Int
    let disk: MakingADisk
    let simulatorService: MakingASimulatorService
    let xcodeCopies: MakingXcodeCopies

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
}

extension Machine {
    static func onThisMachine(_ places: WhereXcodeLeavesThings) -> Machine {
        Machine(
            developerFolder: places.developerFolder,
            worthDeleting: places.worthDeleting,
            disk: { FileManagerDisk() },
            simulatorService: { SimctlSimulatorService(tool: ProcessTool()) },
            xcodeCopies: { SystemXcodeCopies(tool: ProcessTool(), disk: FileManagerDisk(), applicationsFolder: places.applicationsFolder) })
    }
}
