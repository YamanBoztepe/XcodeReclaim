import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
public enum LeftoverListUIComposer {
    public typealias Measuring = @MainActor (_ announcing: @escaping (String) -> Void, _ delivering: @escaping ([Leftover]) -> Void) -> Void
    public typealias Deleting = @MainActor (_ leftover: Leftover, _ reporting: @escaping (Deletion) -> Void) -> Void

    public static func screen(measuring: @escaping Measuring, deleting: @escaping Deleting) -> LeftoverListContainerView {
        let latestOnly = LatestMeasuringOnlyDecorator(decorating: measuring)
        let measure = LeftoverListViewModelMeasureAdapter(measuring: latestOnly.measure)
        let delete = LeftoverListViewModelDeleteAdapter(deleting: deleting)
        let model = LeftoverListViewModel(measure: measure.measure, delete: delete.delete)

        measure.screen = model
        delete.screen = model
        return LeftoverListContainerView(model: model)
    }
}
