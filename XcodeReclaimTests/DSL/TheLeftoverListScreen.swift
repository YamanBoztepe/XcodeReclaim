import Foundation
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheLeftoverListScreen {
    private let container: LeftoverListContainerView
    private let announcingThenWaiting: AMeasuringThatAnnouncesThenWaits?
    private let waitingThenAnnouncing: AMeasuringThatWaitsThenAnnounces?

    init(theMachineFinds finds: [Leftover] = [], announcing announces: [String] = []) {
        let machine = TheMachine(finds: finds, announces: announces)
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        announcingThenWaiting = nil
        waitingThenAnnouncing = nil
    }

    init(theMeasuringAnnouncesThenTakesAWhile announces: [String], finding finds: [Leftover] = []) {
        let machine = AMeasuringThatAnnouncesThenWaits(finds: finds, announces: announces)
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: TheMachine().deleting)
        announcingThenWaiting = machine
        waitingThenAnnouncing = nil
    }

    init(theMeasuringTakesAWhileThenAnnounces announces: [String], finding finds: [Leftover] = []) {
        let machine = AMeasuringThatWaitsThenAnnounces(finds: finds, announces: announces)
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: TheMachine().deleting)
        announcingThenWaiting = nil
        waitingThenAnnouncing = machine
    }

    init(theMachineSaysWhereItRan machine: AMachineThatSaysWhereItRan) {
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        announcingThenWaiting = nil
        waitingThenAnnouncing = nil
    }
}

extension TheLeftoverListScreen {
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

    func theMeasuringFinishes() {
        announcingThenWaiting?.itFinishes()
        waitingThenAnnouncing?.theFirstMeasuringFinishes()
    }
}

extension TheLeftoverListScreen {
    func untilItHasMeasured() async {
        await until { !$0.isMeasuring }
    }

    func untilItNames(_ name: String) async {
        await until { $0.leftoverBeingMeasured == name }
    }

    func untilItSaysSomethingAboutTheDeletion() async {
        await until { $0.whatTheDeletionSaid != nil }
    }

    func untilItSettles() async {
        let longEnoughForAnythingQueuedToRun = 200

        for _ in 0..<longEnoughForAnythingQueuedToRun {
            await Task.yield()
        }
    }
}

extension TheLeftoverListScreen {
    var whatIsHandedToTheView: LeftoverListUIModel { drawn.model }
    var whatTheViewModelHolds: LeftoverListUIModel { container.model.uiModel }
    var whatTheSectionsAreCalled: [String] { whatIsHandedToTheView.sections.map(\.name) }
    var whatTheSectionsAreDrawnWith: [String] { whatIsHandedToTheView.sections.map(\.symbol) }
    var whatTheRowsAreCalled: [String] { everyRow.map(\.name) }
    var whichRowIsMarkedAsHoldingTheMostRoom: [String] { everyRow.filter(\.holdsTheMostRoom).map(\.name) }
    var whichRowsOfferDeletion: [String] { everyRow.filter(\.canBeDeleted).map(\.name) }
    var whichRowsSayTheyAreBeingDeleted: [String] { everyRow.compactMap { $0.deletionUnderWay == nil ? nil : $0.name } }
    var whatIsBeingConfirmed: LeftoverListUIModel.Confirmation? { whatIsHandedToTheView.confirmation }
    var whatIsBeingMeasured: String? { whatIsHandedToTheView.leftoverBeingMeasured }
    var itIsMeasuring: Bool { whatIsHandedToTheView.isMeasuring }
    var itSaysThereIsNothingToDelete: Bool { whatIsHandedToTheView.nothingToDelete }
    var whatItIsCalled: String { whatIsHandedToTheView.title }
}

private extension TheLeftoverListScreen {
    var drawn: LeftoverListView { container.screen }

    var everyRow: [LeftoverRow] { whatIsHandedToTheView.sections.flatMap(\.rows) }

    func until(_ settles: (LeftoverListUIModel) -> Bool) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settles(whatIsHandedToTheView) {
            await Task.yield()
        }
    }
}
