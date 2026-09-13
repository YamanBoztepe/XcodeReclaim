import XcodeReclaim
import XcodeReclaimCore

@MainActor
final class TheMachineSpy {
    private(set) var announcings: [XcodeLeftovers.Announcing] = []
    private(set) var deliverings: [XcodeLeftovers.Delivering] = []
    private(set) var deletions: [LeftoverCrossing] = []
    private(set) var reportings: [XcodeLeftovers.Reporting] = []

    var measurings: Int { deliverings.count }

    func measuring(_ announce: @escaping XcodeLeftovers.Announcing, _ deliver: @escaping XcodeLeftovers.Delivering) {
        announcings.append(announce)
        deliverings.append(deliver)
    }

    func deleting(_ crossing: LeftoverCrossing, _ report: @escaping XcodeLeftovers.Reporting) {
        deletions.append(crossing)
        reportings.append(report)
    }

    func announce(_ name: String, from measuring: Int) {
        announcings[measuring](name)
    }

    func deliver(_ leftovers: [Leftover], from measuring: Int) {
        deliverings[measuring](leftovers.map(LeftoverCrossing.init))
    }

    func report(_ deletion: Deletion, from deletionRequest: Int) {
        reportings[deletionRequest](DeletionCrossing(deletion))
    }
}
