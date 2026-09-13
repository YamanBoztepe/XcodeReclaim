import XcodeReclaimCore

@MainActor
final class LatestMeasuringOnlyDecorator {
    private let decoratee: LeftoverListUIComposer.Measuring
    private var latestMeasuring = 0

    init(decorating decoratee: @escaping LeftoverListUIComposer.Measuring) {
        self.decoratee = decoratee
    }

    func measure(announcing announce: @escaping (String) -> Void, delivering deliver: @escaping ([Leftover]) -> Void) {
        latestMeasuring += 1
        let thisMeasuring = latestMeasuring

        decoratee(
            { [weak self] name in
                guard self?.latestMeasuring == thisMeasuring else { return }

                announce(name)
            },
            { [weak self] measured in
                guard self?.latestMeasuring == thisMeasuring else { return }

                deliver(measured)
            })
    }
}
