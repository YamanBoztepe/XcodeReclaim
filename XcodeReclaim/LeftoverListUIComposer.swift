import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
public enum LeftoverListUIComposer {
    public static func screen(showing model: LeftoverListViewModel) -> LeftoverListView {
        LeftoverListView(model: model)
    }
}
