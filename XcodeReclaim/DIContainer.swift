import XcodeReclaimEngine
import XcodeReclaimInfra

struct DIContainer {
    private let places: WhereXcodeLeavesThings

    init(in places: WhereXcodeLeavesThings = .onThisMachine) {
        self.places = places
    }

    var xcodeLeftovers: XcodeLeftovers {
        XcodeLeftovers(
            developerFolder: places.developerFolder,
            worthDeleting: places.worthDeleting,
            disk: { FileManagerDisk() },
            simulatorService: { SimctlSimulatorService(tool: ProcessTool()) },
            xcodeCopies: { SystemXcodeCopies(tool: ProcessTool(), disk: FileManagerDisk(), applicationsFolder: places.applicationsFolder) })
    }
}
