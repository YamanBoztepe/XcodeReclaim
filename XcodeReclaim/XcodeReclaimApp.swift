import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftoverList = XcodeReclaimApp.xcodeReclaim.leftoverList()

    var body: some Scene {
        WindowGroup {
            leftoverList
        }
        .windowResizability(.contentMinSize)
    }
}

private extension XcodeReclaimApp {
    static var places: WhereXcodeLeavesThings { .onThisMachine }

    static var xcodeReclaim: XcodeReclaim {
        let dependencies = DIContainer(applicationsFolder: places.applicationsFolder)

        return XcodeReclaim(
            developerFolder: places.developerFolder,
            worthDeleting: places.worthDeleting,
            disk: dependencies.disk,
            simulatorService: dependencies.simulatorService,
            xcodeCopies: dependencies.xcodeCopies)
    }
}
