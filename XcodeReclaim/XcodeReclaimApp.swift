import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftoverList = XcodeReclaimApp.xcodeLeftovers.leftoverList()

    var body: some Scene {
        WindowGroup {
            leftoverList
        }
        .windowResizability(.contentMinSize)
    }
}

private extension XcodeReclaimApp {
    static var places: WhereXcodeLeavesThings { .onThisMachine }

    static var xcodeLeftovers: XcodeLeftovers {
        let dependencies = DIContainer(applicationsFolder: places.applicationsFolder)

        return XcodeLeftovers(
            developerFolder: places.developerFolder,
            worthDeleting: places.worthDeleting,
            disk: dependencies.disk,
            simulatorService: dependencies.simulatorService,
            xcodeCopies: dependencies.xcodeCopies)
    }
}
