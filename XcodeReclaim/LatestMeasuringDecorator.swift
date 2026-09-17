import XcodeReclaimCore

@MainActor
final class LatestMeasuringDecorator {
    private let announcing: (Leftover.Kind, Leftover.Place) -> Void
    private let delivering: ([Leftover]) -> Void
    private var latestMeasuring = 0

    init(
        announcing: @escaping (Leftover.Kind, Leftover.Place) -> Void,
        delivering: @escaping ([Leftover]) -> Void
    ) {
        self.announcing = announcing
        self.delivering = delivering
    }

    func beginMeasuring() -> Int {
        latestMeasuring += 1
        return latestMeasuring
    }

    func announce(_ kind: Leftover.Kind, at place: Leftover.Place, from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        announcing(kind, place)
    }

    func deliver(_ leftovers: [Leftover], from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        delivering(leftovers)
    }
}
