import XcodeReclaimCore
import XcodeReclaimEngine

extension MeasureLeftovers {
    func leftovers(measuring sources: [Offered], announcing announce: (Leftover.Kind, Leftover.Place) -> Void) -> [Leftover] {
        leftovers(from: sources.map { leftovers(of: $0, announcing: announce) })
    }
}
