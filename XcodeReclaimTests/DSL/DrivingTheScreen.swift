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

    func askToDelete(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let row = try #require(rows.first(where: { $0.name == name }), "no row named \(name)", sourceLocation: sourceLocation)

        view.onAskAboutDeleting(row)
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
    var leftoverAwaitingConfirmation: String? { confirmation?.name }
    var confirmationMessage: String? { confirmation?.sentence }
    var sectionNames: [String] { uiModelHandedToTheView.sections.map(\.name) }
    var sectionSymbols: [String] { uiModelHandedToTheView.sections.map(\.symbol) }
    var rowNames: [String] { rows.map(\.name) }
    var shownLeftovers: [String] { rows.map { "\($0.name) — \($0.size)" } }
    var rowsHoldingTheMostRoom: [String] { rows.filter(\.holdsTheMostRoom).map(\.name) }
    var deletableRows: [String] { rows.filter(\.canBeDeleted).map(\.name) }
    var rowsBeingDeleted: [String] { rows.compactMap { $0.deletionUnderWay == nil ? nil : $0.name } }
}

@MainActor
private extension LeftoverListContainerView {
    var view: LeftoverListView { screen }

    var rows: [LeftoverRow] { uiModelHandedToTheView.sections.flatMap(\.rows) }
}
