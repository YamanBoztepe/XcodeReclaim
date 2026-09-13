import SwiftUI
import XcodeReclaimPresentation
import XcodeReclaimUI

public struct LeftoverListContainerView: View {
    public let model: LeftoverListViewModel

    init(model: LeftoverListViewModel) {
        self.model = model
    }

    public var body: some View {
        LeftoverListView(
            model: model.uiModel,
            onAppear: model.open,
            onRefresh: model.refresh,
            onAskAboutDeleting: model.askAboutDeleting,
            onConfirm: model.confirm,
            onBackOut: model.backOut)
    }
}
