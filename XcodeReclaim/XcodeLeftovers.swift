import Foundation
import XcodeReclaimCore
import XcodeReclaimEngine

public struct XcodeLeftovers: Sendable {
    private let machine: Machine

    public init(measuring machine: Machine) {
        self.machine = machine
    }

    public init(in places: WhereXcodeLeavesThings = .onThisMachine) {
        self.init(measuring: .onThisMachine(places))
    }

    @MainActor public func leftoverList() -> LeftoverListContainerView {
        LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
    }
}

private extension Machine {
    var measureLeftovers: MeasureLeftovers {
        MeasureLeftovers(
            developerFolder: developerFolder,
            disk: disk(),
            simulatorService: simulatorService(),
            xcodeCopies: xcodeCopies(),
            worthDeleting: worthDeleting)
    }

    var measuring: LeftoverListUIComposer.Measuring {
        { [self] announce in
            let found = await everySourceAtOnce(announcing: announce)

            return LeftoversWorthDeleting(atLeast: worthDeleting).biggestFirst(from: found)
        }
    }

    var deleting: LeftoverListUIComposer.Deleting {
        { [self] leftover in DeleteLeftover(disk: disk(), simulatorService: simulatorService()).delete(leftover) }
    }

    func everySourceAtOnce(announcing announce: @escaping @Sendable (String) -> Void) async -> [[Leftover]] {
        let measured = await withTaskGroup(of: (Int, [Leftover]).self) { measurings in
            for source in MeasureLeftovers.Offered.allCases.indices {
                measurings.addTask { [self] in (source, measureLeftovers.leftovers(of: MeasureLeftovers.Offered.allCases[source], announcing: announce)) }
            }

            return await measurings.reduce(into: [Int: [Leftover]]()) { measured, each in measured[each.0] = each.1 }
        }

        return measured.sorted { $0.key < $1.key }.map(\.value)
    }
}
