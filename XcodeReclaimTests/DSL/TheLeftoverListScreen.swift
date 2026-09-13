import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class TheLeftoverListScreen {
    private let container: LeftoverListContainerView
    private let held: AMachineHeldUntilLetGo?

    init(theMachineFinds finds: [Leftover] = [], announcing announces: [String] = []) {
        let machine = TheMachine(announcing: announces, finding: finds)
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        held = nil
    }

    init(eachMeasuringHeldUntilLetGo measurings: [TheMachine]) {
        let machine = AMachineHeldUntilLetGo(eachMeasuring: measurings)
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        held = machine
    }

    init(theMachineSaysWhereItRan machine: AMachineThatSaysWhereItRan) {
        container = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        held = nil
    }
}

extension TheLeftoverListScreen {
    func isOpened() {
        drawn.onAppear()
    }

    func isRefreshed() {
        drawn.onRefresh()
    }

    func isAskedAboutDeleting(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let row = try #require(everyRow.first(where: { $0.name == name }), "no row named \(name)", sourceLocation: sourceLocation)

        drawn.onAskAboutDeleting(row)
    }

    func hasTheDeletionConfirmed() {
        drawn.onConfirm()
    }

    func hasTheDeletionBackedOutOf() {
        drawn.onBackOut()
    }

    func theMeasuringFinishes(_ measuring: Int) {
        held?.theMeasuringFinishes(measuring)
    }

    func everyMeasuringFinishes() {
        held?.everyMeasuringFinishes()
    }
}

extension TheLeftoverListScreen {
    func untilItHasMeasured() async {
        await until { !$0.isMeasuring }
    }

    func untilItNames(_ name: String) async {
        await until { $0.leftoverBeingMeasured == name }
    }

    func untilEverythingQueuedHasRun() async {
        let moreTurnsThanAnyStubbedMachineAsksFor = 200

        for _ in 0..<moreTurnsThanAnyStubbedMachineAsksFor {
            await Task.yield()
        }
    }

    func untilItSaysSomethingAboutTheDeletion() async {
        await until { $0.whatTheDeletionSaid != nil }
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
