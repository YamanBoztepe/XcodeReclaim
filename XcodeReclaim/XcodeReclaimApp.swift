import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftoverList = XcodeLeftovers().leftoverList()

    var body: some Scene {
        WindowGroup {
            leftoverList
        }
        .windowResizability(.contentMinSize)
    }
}
