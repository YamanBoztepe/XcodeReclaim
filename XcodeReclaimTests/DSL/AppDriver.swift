import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct AppDriver {
    private let leftovers: XcodeLeftovers
    private let container: LeftoverListContainerView

    init(machineFinds finds: [Leftover] = []) {
        let machine = MachineStub(finding: finds)

        leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
        container = leftovers.leftoverList()
    }
}

extension AppDriver {
    func open() {
        leftoverList.onAppear()
    }

    func refresh() {
        leftoverList.onRefresh()
    }

    func askToDelete(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let row = try #require(rows.first(where: { $0.name == name }), "no row named \(name)", sourceLocation: sourceLocation)

        leftoverList.onAskAboutDeleting(row)
    }

    func confirm() {
        leftoverList.onConfirm()
    }

    func backOut() {
        leftoverList.onBackOut()
    }

    func waitForMeasuringToEnd() async {
        await wait { !$0.isMeasuring }
    }

    func waitForDeletionToEnd() async {
        await wait { $0.whatTheDeletionSaid != nil }
    }
}

extension AppDriver {
    var shownLeftovers: [String] {
        rows.map { "\($0.name) — \($0.size)" }
    }

    var isMeasuring: Bool {
        leftoverList.model.isMeasuring
    }

    var leftoverAwaitingConfirmation: String? {
        leftoverList.model.confirmation?.name
    }

    var confirmationMessage: String? {
        leftoverList.model.confirmation?.sentence
    }

    var deletionMessage: String? {
        leftoverList.model.whatTheDeletionSaid
    }

    var rowsBeingDeleted: [String] {
        rows.compactMap { $0.deletionUnderWay == nil ? nil : $0.name }
    }

    var deletableRows: [String] {
        rows.filter(\.canBeDeleted).map(\.name)
    }
}

private extension AppDriver {
    var leftoverList: LeftoverListView {
        container.screen
    }

    var rows: [LeftoverRow] {
        leftoverList.model.sections.flatMap(\.rows)
    }

    func wait(for settled: (LeftoverListUIModel) -> Bool) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settled(leftoverList.model) {
            await Task.yield()
        }
    }
}
