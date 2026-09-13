import SwiftUI

@main
struct XcodeReclaimApp: App {
    @State private var leftoverList = DIContainer().xcodeLeftovers.leftoverList()

    var body: some Scene {
        WindowGroup {
            leftoverList
        }
        .windowResizability(.contentMinSize)
    }
}
