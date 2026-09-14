import Foundation
import XcodeReclaimInfra

struct DIContainer {
    let disk: XcodeReclaim.MakingADisk
    let simulatorService: XcodeReclaim.MakingASimulatorService
    let xcodeCopies: XcodeReclaim.MakingXcodeCopies

    init(applicationsFolder: URL) {
        disk = { FileManagerDisk() }
        simulatorService = { SimctlSimulatorService(tool: ProcessTool()) }
        xcodeCopies = { SystemXcodeCopies(tool: ProcessTool(), disk: FileManagerDisk(), applicationsFolder: applicationsFolder) }
    }
}
