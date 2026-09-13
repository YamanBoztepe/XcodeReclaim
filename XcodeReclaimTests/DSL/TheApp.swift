import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheApp {
    private let leftovers: XcodeLeftovers
    private lazy var container = leftovers.leftoverList()

    init(theMachineFinds finds: [Leftover] = [], announcing announces: [String] = []) {
        let machine = TheMachine(announcing: announces, finding: finds)
        leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
    }
}

extension TheApp {
    func theDeveloperOpensIt() {
        leftoverList.onAppear()
    }

    func theDeveloperAsksToRefresh() {
        leftoverList.onRefresh()
    }

    func theDeveloperAsksToDelete(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let row = try #require(everyRow.first(where: { $0.name == name }), "no row named \(name)", sourceLocation: sourceLocation)

        leftoverList.onAskAboutDeleting(row)
    }

    func theDeveloperConfirms() {
        leftoverList.onConfirm()
    }

    func theDeveloperBacksOut() {
        leftoverList.onBackOut()
    }
}

extension TheApp {
    func untilTheMeasuringEnds() async {
        await untilTheLeftoverList { !$0.isMeasuring }
    }

    func untilTheDeletionEnds() async {
        await untilTheLeftoverList { $0.whatTheDeletionSaid != nil }
    }
}

extension TheApp {
    var whatTheLeftoverListShows: [String] {
        everyRow.map { "\($0.name) — \($0.size)" }
    }

    var whatTheLeftoverListSaysAboutTheDeletion: String? {
        leftoverList.model.whatTheDeletionSaid
    }

    var theLeftoverListIsMeasuring: Bool {
        leftoverList.model.isMeasuring
    }

    var whatTheLeftoverListIsAskingToConfirm: String? {
        leftoverList.model.confirmation?.name
    }

    var whatTheConfirmationReads: String? {
        leftoverList.model.confirmation?.sentence
    }

    var whichRowsSayTheyAreBeingDeleted: [String] {
        everyRow.compactMap { $0.deletionUnderWay == nil ? nil : $0.name }
    }

    var whichRowsOfferDeletion: [String] {
        everyRow.filter(\.canBeDeleted).map(\.name)
    }
}

private extension TheApp {
    var leftoverList: LeftoverListView {
        container.screen
    }

    var everyRow: [LeftoverRow] {
        leftoverList.model.sections.flatMap(\.rows)
    }

    func untilTheLeftoverList(_ settles: (LeftoverListUIModel) -> Bool) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settles(leftoverList.model) {
            await Task.yield()
        }
    }
}
