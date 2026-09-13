import Foundation
import XcodeReclaimInfra

struct DIContainer {
    let disk: XcodeLeftovers.MakingADisk
    let simulatorService: XcodeLeftovers.MakingASimulatorService
    let xcodeCopies: XcodeLeftovers.MakingXcodeCopies

    init(applicationsFolder: URL) {
        disk = { FileManagerDisk() }
        simulatorService = { SimctlSimulatorService(tool: ProcessTool()) }
        xcodeCopies = { SystemXcodeCopies(tool: ProcessTool(), disk: FileManagerDisk(), applicationsFolder: applicationsFolder) }
    }
}
