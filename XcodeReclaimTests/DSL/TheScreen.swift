import Foundation
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheScreen {
    private let machine = TheMachineSpy()
    private let container: LeftoverListContainerView

    init() {
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
    }
}

extension TheScreen {
    func isOpened() {
        drawn.onAppear()
    }

    func isRefreshed() {
        drawn.onRefresh()
    }

    func isAskedAboutDeleting(_ name: String) {
        guard let row = everyRow.first(where: { $0.name == name }) else { return }

        drawn.onAskAboutDeleting(row)
    }

    func hasTheDeletionConfirmed() {
        drawn.onConfirm()
    }

    func hasTheDeletionBackedOutOf() {
        drawn.onBackOut()
    }
}

extension TheScreen {
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
        machine.report(.freed(bytes), from: machine.deletions.count - 1)
    }
}

extension TheScreen {
    var whatIsHandedToTheView: LeftoverListUIModel {
        drawn.model
    }

    var whatTheViewModelHolds: LeftoverListUIModel {
        container.model.uiModel
    }

    var whatTheSectionsAreCalled: [String] {
        whatIsHandedToTheView.sections.map(\.name)
    }

    var whatTheSectionsAreDrawnWith: [String] {
        whatIsHandedToTheView.sections.map(\.symbol)
    }

    var whatTheRowsAreCalled: [String] {
        everyRow.map(\.name)
    }

    var whichRowIsMarkedAsHoldingTheMostRoom: [String] {
        everyRow.filter(\.holdsTheMostRoom).map(\.name)
    }

    var whichRowsOfferDeletion: [String] {
        everyRow.filter(\.canBeDeleted).map(\.name)
    }

    var whichRowsSayTheyAreBeingDeleted: [String] {
        everyRow.compactMap { $0.deletionUnderWay == nil ? nil : $0.name }
    }

    var whatIsBeingConfirmed: LeftoverListUIModel.Confirmation? {
        whatIsHandedToTheView.confirmation
    }

    var whatIsBeingMeasured: String? {
        whatIsHandedToTheView.leftoverBeingMeasured
    }

    var itIsMeasuring: Bool {
        whatIsHandedToTheView.isMeasuring
    }

    var itSaysThereIsNothingToDelete: Bool {
        whatIsHandedToTheView.nothingToDelete
    }

    var whatItIsCalled: String {
        whatIsHandedToTheView.title
    }

    var howManyMeasuringsWereAskedFor: Int {
        machine.measurings
    }
}

private extension TheScreen {
    var drawn: LeftoverListView {
        container.screen
    }

    var everyRow: [LeftoverRow] {
        whatIsHandedToTheView.sections.flatMap(\.rows)
    }

    var theMeasuringUnderWay: Int {
        machine.measurings - 1
    }

    var theMeasuringThatWasReplaced: Int {
        0
    }
}
