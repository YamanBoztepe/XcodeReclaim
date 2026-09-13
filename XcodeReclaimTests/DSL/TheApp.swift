import Foundation
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheApp {
    private let machine = TheMachineSpy()
    private let container: LeftoverListContainerView

    init() {
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
    }
}

extension TheApp {
    func theDeveloperOpensIt() {
        container.screen.onAppear()
    }

    func theDeveloperAsksToRefresh() {
        container.screen.onRefresh()
    }

    func theDeveloperAsksToDelete(_ name: String) {
        guard let row = everyRow.first(where: { $0.name == name }) else { return }

        container.screen.onAskAboutDeleting(row)
    }

    func theDeveloperConfirms() {
        container.screen.onConfirm()
    }
}

extension TheApp {
    func theMeasuringAnnounces(_ name: String) {
        machine.announce(name, from: theMeasuringUnderWay)
    }

    func theMeasuringFinds(_ leftovers: [Leftover]) {
        machine.deliver(leftovers, from: theMeasuringUnderWay)
    }

    func theMeasuringThatWasReplacedAnnounces(_ name: String) {
        machine.announce(name, from: theMeasuringThatWasReplaced)
    }

    func theMeasuringThatWasReplacedFinds(_ leftovers: [Leftover]) {
        machine.deliver(leftovers, from: theMeasuringThatWasReplaced)
    }

    func theDeletionFrees(_ bytes: Int) {
        machine.report(.freed(bytes), from: theDeletionUnderWay)
    }
}

extension TheApp {
    var whatTheScreenShows: [String] {
        everyRow.map { "\($0.name) — \($0.size)" }
    }

    var whatTheScreenSaysAboutTheDeletion: String? {
        container.screen.model.whatTheDeletionSaid
    }

    var theScreenIsMeasuring: Bool {
        container.screen.model.isMeasuring
    }

    var whatTheScreenIsMeasuring: String? {
        container.screen.model.leftoverBeingMeasured
    }

    var whatTheMachineWasAskedToDelete: [String] {
        machine.deletions.map(\.name)
    }

    var howManyMeasuringsWereAskedFor: Int {
        machine.measurings
    }
}

private extension TheApp {
    var everyRow: [LeftoverRow] {
        container.screen.model.sections.flatMap(\.rows)
    }

    var theMeasuringUnderWay: Int {
        machine.measurings - 1
    }

    var theMeasuringThatWasReplaced: Int {
        0
    }

    var theDeletionUnderWay: Int {
        machine.deletions.count - 1
    }
}
