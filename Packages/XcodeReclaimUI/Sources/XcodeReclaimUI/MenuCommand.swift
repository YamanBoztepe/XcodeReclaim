import SwiftUI

public struct MenuCommand {
    public let title: String
    public let shortcut: KeyboardShortcut
    public let isOffered: Bool
    public let perform: () -> Void

    public init(title: String, shortcut: KeyboardShortcut, isOffered: Bool, perform: @escaping () -> Void) {
        self.title = title
        self.shortcut = shortcut
        self.isOffered = isOffered
        self.perform = perform
    }
}
