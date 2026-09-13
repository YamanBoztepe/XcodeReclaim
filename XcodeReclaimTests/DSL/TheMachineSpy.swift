import XcodeReclaimCore

@MainActor
final class TheMachineSpy {
    private(set) var announcings: [(String) -> Void] = []
    private(set) var deliverings: [([Leftover]) -> Void] = []
    private(set) var deletions: [Leftover] = []
    private(set) var reportings: [(Deletion) -> Void] = []

    var measurings: Int { deliverings.count }

    func measuring(_ announce: @escaping (String) -> Void, _ deliver: @escaping ([Leftover]) -> Void) {
        announcings.append(announce)
        deliverings.append(deliver)
    }

    func deleting(_ leftover: Leftover, _ report: @escaping (Deletion) -> Void) {
        deletions.append(leftover)
        reportings.append(report)
    }

    func announce(_ name: String, from measuring: Int) {
        announcings[measuring](name)
    }

    func deliver(_ leftovers: [Leftover], from measuring: Int) {
        deliverings[measuring](leftovers)
    }

    func report(_ deletion: Deletion, from deletionRequest: Int) {
        reportings[deletionRequest](deletion)
    }
}
