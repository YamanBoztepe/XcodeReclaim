import XcodeReclaimPresentation

@MainActor
final class LeftoverListViewModelMeasureAdapter {
    weak var screen: LeftoverListViewModel?

    private let measuring: LeftoverListUIComposer.Measuring

    init(measuring: @escaping LeftoverListUIComposer.Measuring) {
        self.measuring = measuring
    }

    func measure() {
        measuring(
            { [weak self] name in self?.screen?.announced(name) },
            { [weak self] measured in self?.screen?.measuringEnded(with: measured) })
    }
}
