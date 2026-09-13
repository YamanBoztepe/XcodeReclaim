import XcodeReclaimCore

public struct LeftoversWorthDeleting {
    private let worthDeleting: Int

    public init(atLeast worthDeleting: Int) {
        self.worthDeleting = worthDeleting
    }

    public func biggestFirst(from found: [[Leftover]]) -> [Leftover] {
        found
            .flatMap(\.self)
            .filter { $0.bytes >= worthDeleting }
            .enumerated()
            .sorted { offered, other in
                offered.element.bytes == other.element.bytes
                    ? offered.offset < other.offset
                    : offered.element.bytes > other.element.bytes
            }
            .map(\.element)
    }
}
