import SwiftUI
import XcodeReclaimPresentation
import XcodeReclaimUI

public struct LeftoverListContainerView: View {
    public let model: LeftoverListViewModel

    init(model: LeftoverListViewModel) {
        self.model = model
    }

    public var screen: LeftoverListView {
        LeftoverListView(
            model: model.uiModel,
            onAppear: model.open,
            onRefresh: model.refresh,
            onSelect: model.select,
            onSort: model.sort(by:),
            onAskAboutDeleting: model.askAboutDeleting,
            onConfirm: model.confirm,
            onBackOut: model.backOut)
    }

    public var commands: LeftoverListCommands {
        LeftoverListCommands(
            model: model.uiModel,
            onRefresh: model.refresh,
            onAskAboutDeleting: model.askAboutDeletingWhatIsChosen)
    }

    public var body: some View {
        screen
    }
}

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
