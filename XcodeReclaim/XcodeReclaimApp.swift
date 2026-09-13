import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftovers = XcodeLeftovers()

    var body: some Scene {
        WindowGroup {
            leftovers.screen
        }
        .windowResizability(.contentMinSize)
    }
}
