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
        XcodeReclaim(places: places, disk: { FileManagerDisk() }, commandRunner: { ProcessCommandRunner() })
    }
}
