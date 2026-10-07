import SwiftUI
import XcodeReclaimUI

public struct LeftoverListCommands: Commands {
    public let menu: LeftoverListMenu

    public var body: some Commands {
        CommandGroup(after: .newItem) {
            MenuCommandButton(menu.deletion)
        }

        CommandGroup(after: .toolbar) {
            MenuCommandButton(menu.refresh)
        }
    }
}
