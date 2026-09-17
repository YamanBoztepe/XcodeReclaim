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
            onCancel: model.cancel)
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
