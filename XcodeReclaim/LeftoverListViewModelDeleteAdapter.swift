import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
final class LeftoverListViewModelDeleteAdapter {
    weak var screen: LeftoverListViewModel?

    private let deleting: LeftoverListUIComposer.Deleting

    init(deleting: @escaping LeftoverListUIComposer.Deleting) {
        self.deleting = deleting
    }

    func delete(_ leftover: Leftover) {
        deleting(leftover) { [weak self] deletion in self?.screen?.deletionEnded(with: deletion) }
    }
}
