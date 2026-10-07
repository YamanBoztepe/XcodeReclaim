import SwiftUI

public struct MenuCommandButton: View {
    public let command: MenuCommand

    public init(_ command: MenuCommand) {
        self.command = command
    }

    public var body: some View {
        Button(command.title, action: command.perform)
            .keyboardShortcut(command.shortcut)
            .disabled(!command.isOffered)
    }
}
