import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
public enum LeftoverListUIComposer {
    public typealias Measuring = @Sendable (_ announcing: @escaping @Sendable (Leftover.Kind, Leftover.Place) -> Void) async -> [Leftover]
    public typealias Deleting = @Sendable (Leftover) -> Deletion

    public static func screen(measuring: @escaping Measuring, deleting: @escaping Deleting) -> LeftoverListContainerView {
        let screen = WeakReference<LeftoverListViewModel>()
        let latestMeasuring = latestMeasuring(reaching: screen)

        let model = LeftoverListViewModel(
            measure: { measureInTheBackground(measuring, reaching: latestMeasuring) },
            delete: { deleteInTheBackground($0, with: deleting, reaching: screen) })
        screen.object = model

        return LeftoverListContainerView(model: model)
    }
}

private extension LeftoverListUIComposer {
    typealias Screen = WeakReference<LeftoverListViewModel>

    static func latestMeasuring(reaching screen: Screen) -> LatestMeasuringDecorator {
        LatestMeasuringDecorator(
            announcing: { screen.object?.announced($0, at: $1) },
            delivering: { screen.object?.measuringEnded(with: $0) })
    }

    static func measureInTheBackground(_ measuring: @escaping Measuring, reaching latestMeasuring: LatestMeasuringDecorator) {
        let thisMeasuring = latestMeasuring.beginMeasuring()
        let announceOnTheMainThread = announcingOnTheMainThread(to: latestMeasuring, from: thisMeasuring)

        BackgroundDecorator { await measuring(announceOnTheMainThread) }
            .handle(then: deliveringOnTheMainThread(to: latestMeasuring, from: thisMeasuring))
    }

    static func deleteInTheBackground(_ leftover: Leftover, with deleting: @escaping Deleting, reaching screen: Screen) {
        BackgroundDecorator { deleting(leftover) }
            .handle(then: endingTheDeletionOnTheMainThread(reaching: screen))
    }

    static func announcingOnTheMainThread(
        to latestMeasuring: LatestMeasuringDecorator,
        from measuring: Int
    ) -> @Sendable (Leftover.Kind, Leftover.Place) -> Void {
        let announce = MainThreadDecorator<(Leftover.Kind, Leftover.Place)> { latestMeasuring.announce($0.0, at: $0.1, from: measuring) }

        return { announce.handle(($0, $1)) }
    }

    static func deliveringOnTheMainThread(to latestMeasuring: LatestMeasuringDecorator, from measuring: Int) -> @Sendable ([Leftover]) -> Void {
        MainThreadDecorator<[Leftover]> { latestMeasuring.deliver($0, from: measuring) }.handle
    }

    static func endingTheDeletionOnTheMainThread(reaching screen: Screen) -> @Sendable (Deletion) -> Void {
        MainThreadDecorator<Deletion> { screen.object?.deletionEnded(with: $0) }.handle
    }
}
