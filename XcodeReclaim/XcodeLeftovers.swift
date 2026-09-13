@MainActor
public final class XcodeLeftovers {
    public private(set) lazy var screen = LeftoverListUIComposer.screen(
        measuring: MeasureOnABackgroundThreadAdapter(in: places).measure,
        deleting: DeleteOnABackgroundThreadAdapter(in: places).delete)

    private let places: WhereXcodeLeavesThings

    public init() {
        places = .onThisMachine
    }
}
