import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimEngine
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct AppDriver {
    private let leftovers: XcodeLeftovers
    private let container: LeftoverListContainerView

    init(machineHolding held: LeftoverOnTheMachine...) {
        self.init(
            disk: DiskStub(sizes: foldersHeld(in: held)),
            simulatorService: SimulatorServiceStub(taking: simulatorsHeld(in: held)),
            xcodeCopies: XcodeCopiesStub(taking: copiesHeld(in: held)))
    }

    init(theFoldersMeasuredBy disk: DiskSpy) {
        self.init(disk: disk, simulatorService: SimulatorServiceStub(taking: []), xcodeCopies: XcodeCopiesStub(taking: []))
    }

    private init(disk: any Disk & Sendable, simulatorService: any SimulatorService & Sendable, xcodeCopies: any XcodeCopies & Sendable) {
        leftovers = XcodeLeftovers(
            developerFolder: developerFolder,
            worthDeleting: anythingIsWorthDeleting,
            disk: { disk },
            simulatorService: { simulatorService },
            xcodeCopies: { xcodeCopies })
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

    func waitForMeasuringToEnd(sourceLocation: SourceLocation = #_sourceLocation) async {
        await wait(for: { !$0.isMeasuring }, sourceLocation: sourceLocation)
    }

    func waitUntil(_ settled: () -> Bool, sourceLocation: SourceLocation = #_sourceLocation) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settled() {
            await Task.yield()
        }

        if !settled() {
            Issue.record("the machine never got there", sourceLocation: sourceLocation)
        }
    }

    func waitForDeletionToEnd(sourceLocation: SourceLocation = #_sourceLocation) async {
        await wait(for: { $0.deletionMessage != nil }, sourceLocation: sourceLocation)
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
        leftoverList.model.deletionMessage
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

    func wait(for settled: (LeftoverListUIModel) -> Bool, sourceLocation: SourceLocation) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settled(leftoverList.model) {
            await Task.yield()
        }

        if !settled(leftoverList.model) {
            Issue.record("the screen never got there", sourceLocation: sourceLocation)
        }
    }
}
