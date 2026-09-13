import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftovers = XcodeLeftovers(measuring: TheMachine.measuring, deleting: TheMachine.deleting)

    var body: some Scene {
        WindowGroup {
            leftovers.screen
        }
        .windowResizability(.contentMinSize)
    }
}
