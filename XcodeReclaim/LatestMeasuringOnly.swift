import XcodeReclaimCore

@MainActor
final class LatestMeasuringOnly {
    private let announcing: (String) -> Void
    private let delivering: ([Leftover]) -> Void
    private var latestMeasuring = 0

    init(announcing: @escaping (String) -> Void, delivering: @escaping ([Leftover]) -> Void) {
        self.announcing = announcing
        self.delivering = delivering
    }

    func beginMeasuring() -> Int {
        latestMeasuring += 1
        return latestMeasuring
    }

    func announce(_ name: String, from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        announcing(name)
    }

    func deliver(_ leftovers: [Leftover], from measuring: Int) {
        guard measuring == latestMeasuring else { return }

        delivering(leftovers)
    }
}
