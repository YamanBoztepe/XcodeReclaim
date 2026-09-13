import XcodeReclaimCore

final class ScreenRequestsSpy {
    private(set) var measurings = 0
    private(set) var deletions: [Leftover] = []

    func measure() {
        measurings += 1
    }

    func delete(_ leftover: Leftover) {
        deletions.append(leftover)
    }
}
