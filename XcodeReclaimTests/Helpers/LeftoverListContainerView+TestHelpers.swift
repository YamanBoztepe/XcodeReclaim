import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
extension LeftoverListContainerView {
    func open() {
        view.onAppear()
    }

    func refresh() {
        view.onRefresh()
    }

    func askToDelete(_ names: String..., sourceLocation: SourceLocation = #_sourceLocation) throws {
        view.onAskAboutDeleting(try identities(of: names, sourceLocation: sourceLocation))
    }

    func choose(_ names: String..., sourceLocation: SourceLocation = #_sourceLocation) throws {
        view.onSelect(try identities(of: names, sourceLocation: sourceLocation))
    }

    func sort(by sorting: LeftoverListUIModel.Sorting) {
        view.onSort(sorting)
    }

    func refreshFromTheMenu() {
        menu.onRefresh()
    }

    func askToDeleteFromTheMenu() {
        menu.onAskAboutDeleting()
    }

    func confirm() {
        view.onConfirm()
    }

    func backOut() {
        view.onBackOut()
    }
}

@MainActor
extension LeftoverListContainerView {
    func waitForMeasuringToEnd(sourceLocation: SourceLocation = #_sourceLocation) async {
        await waitUntil({ !isMeasuring }, sourceLocation: sourceLocation)
    }

    func waitForMeasuringToReach(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) async {
        await waitUntil({ leftoverBeingMeasured == name }, sourceLocation: sourceLocation)
    }

    func waitForDeletionToEnd(sourceLocation: SourceLocation = #_sourceLocation) async {
        await waitUntil({ deletionMessage != nil }, sourceLocation: sourceLocation)
    }

    func waitUntil(_ settled: () -> Bool, sourceLocation: SourceLocation = #_sourceLocation) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settled() {
            await Task.yield()
        }

        if !settled() {
            Issue.record("the screen never got there", sourceLocation: sourceLocation)
        }
    }

    func waitForEverythingQueuedToRun() async {
        let moreTurnsThanAnyStubbedMachineAsksFor = 200

        for _ in 0..<moreTurnsThanAnyStubbedMachineAsksFor {
            await Task.yield()
        }
    }
}

@MainActor
extension LeftoverListContainerView {
    var uiModelHandedToTheView: LeftoverListUIModel { view.model }
    var uiModelTheViewModelHolds: LeftoverListUIModel { model.uiModel }
    var title: String { uiModelHandedToTheView.title }
    var isMeasuring: Bool { uiModelHandedToTheView.isMeasuring }
    var saysThereIsNothingToDelete: Bool { uiModelHandedToTheView.nothingToDelete }
    var leftoverBeingMeasured: String? { uiModelHandedToTheView.leftoverBeingMeasured }
    var deletionMessage: String? { uiModelHandedToTheView.deletionMessage }
    var confirmation: LeftoverListUIModel.Confirmation? { uiModelHandedToTheView.confirmation }
    var confirmationQuestion: String? { confirmation?.question }
    var confirmationMessage: String? { confirmation?.sentence }
    var sectionNames: [String] { uiModelHandedToTheView.sections.map(\.name) }
    var sectionSymbols: [String] { uiModelHandedToTheView.sections.map(\.symbol) }
    var rowNames: [String] { rows.map(\.name) }
    var shownLeftovers: [String] { rows.map { "\($0.name) — \($0.size)" } }
    var rowsHoldingTheMostRoom: [String] { rows.filter(\.holdsTheMostRoom).map(\.name) }
    var deletableRows: [String] { rows.filter(\.canBeDeleted).map(\.name) }
    var rowsBeingDeleted: [String] { rows.compactMap { $0.deletionUnderWay == nil ? nil : $0.name } }
    var chosenRows: [String] { rows.filter { uiModelHandedToTheView.selection.contains($0.id) }.map(\.name) }
    var offersToDeleteWhatIsChosen: Bool { uiModelHandedToTheView.canDeleteSelection }
    var menuOffersDeletion: Bool { menu.model.canDeleteSelection }
    var menuOffersARefresh: Bool { !menu.model.isMeasuring }
}

@MainActor
private extension LeftoverListContainerView {
    var view: LeftoverListView { screen }

    var menu: LeftoverListCommands { commands }

    var rows: [LeftoverRow] { uiModelHandedToTheView.sections.flatMap(\.rows) }

    func identities(of names: [String], sourceLocation: SourceLocation) throws -> Set<String> {
        try Set(
            names.map { name in
                try #require(rows.first(where: { $0.name == name }), "no row named \(name)", sourceLocation: sourceLocation).id
            })
    }
}
