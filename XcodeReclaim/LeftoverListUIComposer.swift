import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
public enum LeftoverListUIComposer {
    public typealias Measuring = @MainActor (_ announcing: @escaping (String) -> Void, _ delivering: @escaping ([Leftover]) -> Void) -> Void
    public typealias Deleting = @MainActor (_ leftover: Leftover, _ reporting: @escaping (Deletion) -> Void) -> Void

    public static func screen(measuring: @escaping Measuring, deleting: @escaping Deleting) -> LeftoverListContainerView {
        let latestOnly = LatestMeasuringOnlyDecorator(decorating: measuring)
        let screen = WeakReference<LeftoverListViewModel>()
        let model = LeftoverListViewModel(
            measure: {
                latestOnly.measure(
                    announcing: { screen.object?.announced($0) },
                    delivering: { screen.object?.measuringEnded(with: $0) })
            },
            delete: { leftover in
                deleting(leftover) { screen.object?.deletionEnded(with: $0) }
            })

        screen.object = model
        return LeftoverListContainerView(model: model)
    }
}
