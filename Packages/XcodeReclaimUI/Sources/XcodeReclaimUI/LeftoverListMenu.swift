import SwiftUI
import XcodeReclaimPresentation

public struct LeftoverListMenu {
    public let model: LeftoverListUIModel
    public let onRefresh: () -> Void
    public let onAskAboutDeleting: () -> Void

    public init(model: LeftoverListUIModel, onRefresh: @escaping () -> Void, onAskAboutDeleting: @escaping () -> Void) {
        self.model = model
        self.onRefresh = onRefresh
        self.onAskAboutDeleting = onAskAboutDeleting
    }

    public var deletion: MenuCommand {
        MenuCommand(
            title: "Delete Immediately…",
            shortcut: KeyboardShortcut(.delete, modifiers: [.command, .option]),
            isOffered: model.canDeleteSelection,
            perform: onAskAboutDeleting)
    }

    public var refresh: MenuCommand {
        MenuCommand(title: "Refresh", shortcut: KeyboardShortcut("r"), isOffered: !model.isMeasuring, perform: onRefresh)
    }
}
