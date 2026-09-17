import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
public enum LeftoverListUIComposer {
    public typealias Measuring = @Sendable (_ announcing: @escaping @Sendable (Leftover.Kind, Leftover.Place) -> Void) async -> [Leftover]
    public typealias Deleting = @Sendable (Leftover) -> Deletion

    public static func screen(measuring: @escaping Measuring, deleting: @escaping Deleting) -> LeftoverListContainerView {
        LeftoverListContainerView(model: viewModel(measuring: measuring, deleting: deleting))
    }

    private static func viewModel(measuring: @escaping Measuring, deleting: @escaping Deleting) -> LeftoverListViewModel {
        let screen = WeakReference<LeftoverListViewModel>()
        let onlyTheLatest = LatestMeasuringDecorator(
            announcing: { screen.object?.announced($0, at: $1) },
            delivering: { screen.object?.measuringEnded(with: $0) })

        let model = LeftoverListViewModel(
            measure: { measureAwayFromTheScreen(measuring, reaching: onlyTheLatest) },
            delete: { leftover in
                MainThreadDecorator<Deletion> { screen.object?.deletionEnded(with: $0) }
                    .answer(from: { deleting(leftover) })
            })

        screen.object = model
        return model
    }

    private static func measureAwayFromTheScreen(_ measuring: @escaping Measuring, reaching onlyTheLatest: LatestMeasuringDecorator) {
        let thisMeasuring = onlyTheLatest.beginMeasuring()
        let announced = MainThreadDecorator<(Leftover.Kind, Leftover.Place)> { onlyTheLatest.announce($0.0, at: $0.1, from: thisMeasuring) }

        MainThreadDecorator<[Leftover]> { onlyTheLatest.deliver($0, from: thisMeasuring) }
            .answer(from: { await measuring({ announced(($0, $1)) }) })
    }
}
