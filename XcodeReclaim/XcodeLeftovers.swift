import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
public final class XcodeLeftovers {
    public typealias Announcing = @MainActor @Sendable (String) -> Void
    public typealias Delivering = @MainActor @Sendable ([LeftoverCrossing]) -> Void
    public typealias Reporting = @MainActor @Sendable (DeletionCrossing) -> Void
    public typealias Measuring = @MainActor (@escaping Announcing, @escaping Delivering) -> Void
    public typealias Deleting = @MainActor (LeftoverCrossing, @escaping Reporting) -> Void

    private let measuring: Measuring
    private let deleting: Deleting
    private var latestMeasuring = 0

    private lazy var model = LeftoverListViewModel(
        measure: { [weak self] in self?.startMeasuring() },
        delete: { [weak self] leftover in self?.startDeleting(leftover) })

    public init(measuring: @escaping Measuring, deleting: @escaping Deleting) {
        self.measuring = measuring
        self.deleting = deleting
    }

    public var screen: LeftoverListView {
        LeftoverListUIComposer.screen(showing: model)
    }
}

private extension XcodeLeftovers {
    func startMeasuring() {
        latestMeasuring += 1
        let thisMeasuring = latestMeasuring
        measuring(
            { [weak self] name in self?.announced(name, from: thisMeasuring) },
            { [weak self] measured in self?.measuringEnded(with: measured, from: thisMeasuring) })
    }

    func announced(_ name: String, from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        model.announced(name)
    }

    func measuringEnded(with measured: [LeftoverCrossing], from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        model.measuringEnded(with: measured.map(\.leftover))
    }

    func startDeleting(_ leftover: Leftover) {
        deleting(LeftoverCrossing(leftover)) { [weak self] deletion in self?.model.deletionEnded(with: deletion.deletion) }
    }
}
