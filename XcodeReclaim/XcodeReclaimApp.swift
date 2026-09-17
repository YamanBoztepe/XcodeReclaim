import SwiftUI
import XcodeReclaimInfra

@main
struct XcodeReclaimApp: App {
    @State private var leftoverList = XcodeReclaimApp.xcodeReclaim.leftoverList()

    var body: some Scene {
        Window("XcodeReclaim", id: "leftovers") {
            leftoverList
        }
        .windowResizability(.contentMinSize)
        .commands { leftoverList.commands }
    }
}

private extension XcodeReclaimApp {
    static var places: XcodeLocations { .forUser(at: URL(filePath: NSHomeDirectory())) }

    static var xcodeReclaim: XcodeReclaim {
        let applicationsFolder = places.applicationsFolder

        return XcodeReclaim(
            developerFolder: places.developerFolder,
            worthDeleting: places.worthDeleting,
            disk: { FileManagerDisk() },
            simulatorService: { SimctlSimulatorService(commandRunner: ProcessCommandRunner()) },
            xcodeCopyLoader: { SystemXcodeCopyLoader(commandRunner: ProcessCommandRunner(), disk: FileManagerDisk(), applicationsFolder: applicationsFolder) })
    }
}
