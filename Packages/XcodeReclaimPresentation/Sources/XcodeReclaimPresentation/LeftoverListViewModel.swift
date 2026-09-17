import Observation
import XcodeReclaimCore

@Observable
public final class LeftoverListViewModel {
    public private(set) var uiModel = LeftoverList().uiModel

    private var list = LeftoverList()
    private let measure: () -> Void
    private let delete: (Leftover) -> Void

    public init(measure: @escaping () -> Void, delete: @escaping (Leftover) -> Void) {
        self.measure = measure
        self.delete = delete
    }

    public func open() {
        measure()
    }

    public func announced(_ kind: Leftover.Kind, at place: Leftover.Place) {
        list.beingMeasured = (kind, place)
        redraw()
    }

    public func measuringEnded(with measured: [Leftover]) {
        list.endMeasuring(with: measured)
        redraw()
    }

    public func refresh() {
        list.beginMeasuring()
        redraw()
        measure()
    }

    public func select(_ shown: Set<String>) {
        list.selected = shown
        redraw()
    }

    public func sort(by sorting: LeftoverListUIModel.Sorting) {
        list.sorting = sorting
        redraw()
    }

    public func askAboutDeleting(_ shown: Set<String>) {
        list.askAboutDeleting(shown)
        redraw()
    }

    public func askAboutDeletingWhatIsChosen() {
        askAboutDeleting(list.selected)
    }

    public func cancel() {
        list.cancelDeletion()
        redraw()
    }

    public func confirm() {
        guard let first = list.beingConfirmed.first else { return }

        list.confirmDeletion()
        redraw()
        delete(first)
    }

    public func deletionEnded(with deletion: Deletion) {
        list.endDeletion(with: deletion)
        redraw()

        guard let next = list.beingDeleted.first else { return }

        delete(next)
    }
}

private extension LeftoverListViewModel {
    func redraw() {
        uiModel = list.uiModel
    }
}
