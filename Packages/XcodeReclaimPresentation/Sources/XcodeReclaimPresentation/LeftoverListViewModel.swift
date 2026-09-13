import Observation
import XcodeReclaimCore

@Observable
public final class LeftoverListViewModel {
    public private(set) var uiModel = LeftoverList().uiModel

    private var list = LeftoverList()
    private var beingConfirmed: Leftover?
    private let measure: () -> Void
    private let delete: (Leftover) -> Void

    public init(measure: @escaping () -> Void, delete: @escaping (Leftover) -> Void) {
        self.measure = measure
        self.delete = delete
    }

    public func open() {
        measure()
    }

    public func announced(_ name: String) {
        list.beingMeasured = name
        redraw()
    }

    public func measuringEnded(with measured: [Leftover]) {
        list.held = measured
        list.isMeasuring = false
        list.beingMeasured = nil
        redraw()
    }

    public func refresh() {
        list.isMeasuring = true
        list.beingMeasured = nil
        list.held = []
        list.deletionMessage = nil
        redraw()
        measure()
    }

    public func askAboutDeleting(_ row: LeftoverRow) {
        guard let leftover = list.leftover(shownAs: row.id), leftover.refusal == nil else { return }

        beingConfirmed = leftover
        list.confirmation = list.confirmationOver(leftover)
        redraw()
    }

    public func backOut() {
        beingConfirmed = nil
        list.confirmation = nil
        redraw()
    }

    public func confirm() {
        guard let leftover = beingConfirmed else { return }

        beingConfirmed = nil
        list.confirmation = nil
        list.beingDeleted = leftover
        redraw()
        delete(leftover)
    }

    public func deletionEnded(with deletion: Deletion) {
        guard let deleted = list.beingDeleted else { return }

        list.beingDeleted = nil
        list.deletionMessage = list.deletionSentence(for: deletion, about: deleted)

        if case .freed = deletion {
            list.held.removeAll { $0 == deleted }
        }
        redraw()
    }
}

private extension LeftoverListViewModel {
    func redraw() {
        uiModel = list.uiModel
    }
}
