import Foundation
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheApp {
    private let leftovers: XcodeLeftovers

    init(theMachineFinds finds: [Leftover] = [], announcing announces: [String] = []) {
        let machine = TheMachine(finds: finds, announces: announces)
        leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
    }

    init(theMachineSaysWhereItRan machine: TheMachineThatSaysWhereItRan) {
        leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
    }
}

extension TheApp {
    func theDeveloperOpensIt() {
        screen.onAppear()
    }

    func theDeveloperAsksToRefresh() {
        screen.onRefresh()
    }

    func theDeveloperAsksToDelete(_ name: String) {
        guard let row = everyRow.first(where: { $0.name == name }) else { return }

        screen.onAskAboutDeleting(row)
    }

    func theDeveloperConfirms() {
        screen.onConfirm()
    }

    func theDeveloperBacksOut() {
        screen.onBackOut()
    }
}

extension TheApp {
    func untilTheMeasuringEnds() async {
        await untilTheScreen { !$0.isMeasuring }
    }

    func untilTheDeletionEnds() async {
        await untilTheScreen { $0.whatTheDeletionSaid != nil }
    }
}

extension TheApp {
    var whatTheScreenShows: [String] {
        everyRow.map { "\($0.name) — \($0.size)" }
    }

    var whatTheScreenSaysAboutTheDeletion: String? {
        screen.model.whatTheDeletionSaid
    }

    var theScreenIsMeasuring: Bool {
        screen.model.isMeasuring
    }

    var whatTheScreenIsMeasuring: String? {
        screen.model.leftoverBeingMeasured
    }

    var whatTheScreenIsAskingToConfirm: String? {
        screen.model.confirmation?.name
    }

    var whatTheConfirmationReads: String? {
        screen.model.confirmation?.sentence
    }

    var whichRowsSayTheyAreBeingDeleted: [String] {
        everyRow.compactMap { $0.deletionUnderWay == nil ? nil : $0.name }
    }

    var whichRowsOfferDeletion: [String] {
        everyRow.filter(\.canBeDeleted).map(\.name)
    }
}

private extension TheApp {
    var screen: LeftoverListView {
        leftovers.screen.screen
    }

    var everyRow: [LeftoverRow] {
        screen.model.sections.flatMap(\.rows)
    }

    func untilTheScreen(_ settles: (LeftoverListUIModel) -> Bool) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settles(screen.model) {
            await Task.yield()
        }
    }
}
