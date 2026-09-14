import Observation
import XcodeReclaimCore

@Observable
public final class LeftoverListViewModel {
    public private(set) var uiModel = LeftoverList().uiModel

    private var list = LeftoverList()
    private var beingConfirmed: [Leftover] = []
    private var roomThatCameBack = 0
    private var whatWentWrong: [String] = []
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
        list.selected = []
        redraw()
    }

    public func refresh() {
        list.isMeasuring = true
        list.beingMeasured = nil
        list.held = []
        list.selected = []
        list.deletionMessage = nil
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
        let asked = list.leftovers(shownAs: shown)
        let offered = list.beingDeleted.isEmpty ? list.offered(shownAs: shown) : []

        list.selected = shown
        beingConfirmed = offered
        list.confirmation = offered.isEmpty ? nil : list.confirmationOver(offered, keeping: asked.count - offered.count)
        redraw()
    }

    public func askAboutDeletingWhatIsChosen() {
        askAboutDeleting(list.selected)
    }

    public func backOut() {
        beingConfirmed = []
        list.confirmation = nil
        redraw()
    }

    public func confirm() {
        guard let first = beingConfirmed.first else { return }

        list.beingDeleted = beingConfirmed
        beingConfirmed = []
        list.confirmation = nil
        roomThatCameBack = 0
        whatWentWrong = []
        redraw()
        delete(first)
    }

    public func deletionEnded(with deletion: Deletion) {
        guard !list.beingDeleted.isEmpty else { return }

        record(deletion, about: list.beingDeleted.removeFirst())

        guard let next = list.beingDeleted.first else {
            list.deletionMessage = list.deletionSentence(over: roomThatCameBack, andWhatWentWrong: whatWentWrong)
            redraw()
            return
        }

        redraw()
        delete(next)
    }
}

private extension LeftoverListViewModel {
    func record(_ deletion: Deletion, about deleted: Leftover) {
        switch deletion {
        case .freed(let bytes):
            roomThatCameBack += bytes
            list.drop(deleted)
        case .partlyFreed(let bytes, let stillThere, let why):
            roomThatCameBack += bytes
            list.resize(deleted, to: stillThere)
            whatWentWrong.append(list.partialSentence(about: deleted, why: why))
        case .refused(let refusal):
            whatWentWrong.append(list.refusalSentence(for: refusal))
        case .failed(let why):
            whatWentWrong.append(list.failureSentence(about: deleted, why: why))
        }
    }

    func redraw() {
        uiModel = list.uiModel
    }
}
