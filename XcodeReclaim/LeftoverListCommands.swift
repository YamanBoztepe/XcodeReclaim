import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListCommands: Commands {
    public let model: LeftoverListUIModel
    public let onRefresh: () -> Void
    public let onAskAboutDeleting: () -> Void

    public var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Delete Immediately…", action: onAskAboutDeleting)
                .keyboardShortcut(.delete, modifiers: [.command, .option])
                .disabled(!model.canDeleteSelection)
        }

        CommandGroup(after: .toolbar) {
            Button("Refresh", action: onRefresh)
                .keyboardShortcut("r")
                .disabled(model.isMeasuring)
        }
    }
}
