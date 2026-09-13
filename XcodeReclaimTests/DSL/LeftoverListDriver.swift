import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct LeftoverListDriver {
    private let container: LeftoverListContainerView
    private let slowMachine: SlowMachineStub?

    init(machineFinds finds: [Leftover] = [], announcing announces: [String] = []) {
        let machine = MachineStub(announcing: announces, finding: finds)

        self.init(measuring: machine.measuring, deleting: machine.deleting)
    }

    init(eachMeasuringHeldUntilLetGo measurings: [MachineStub]) {
        let machine = SlowMachineStub(eachMeasuring: measurings)

        self.init(measuring: machine.measuring, deleting: machine.deleting, heldBy: machine)
    }

    static func withAMachineThatReportsItsThread() -> LeftoverListDriver {
        let machine = ThreadReportingMachineStub()

        return LeftoverListDriver(measuring: machine.measuring, deleting: machine.deleting)
    }

    private init(
        measuring: @escaping LeftoverListUIComposer.Measuring,
        deleting: @escaping LeftoverListUIComposer.Deleting,
        heldBy slowMachine: SlowMachineStub? = nil
    ) {
        container = LeftoverListUIComposer.screen(measuring: measuring, deleting: deleting)
        self.slowMachine = slowMachine
    }
}

extension LeftoverListDriver {
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

    func letMeasuringFinish(_ measuring: Int) {
        slowMachine?.letMeasuringFinish(measuring)
    }

    func letEveryMeasuringFinish() {
        slowMachine?.letEveryMeasuringFinish()
    }
}

extension LeftoverListDriver {
    func waitForMeasuringToEnd() async {
        await wait { !$0.isMeasuring }
    }

    func waitForMeasuringToReach(_ name: String) async {
        await wait { $0.leftoverBeingMeasured == name }
    }

    func waitForDeletionToEnd() async {
        await wait { $0.whatTheDeletionSaid != nil }
    }

    func waitForEverythingQueuedToRun() async {
        let moreTurnsThanAnyStubbedMachineAsksFor = 200

        for _ in 0..<moreTurnsThanAnyStubbedMachineAsksFor {
            await Task.yield()
        }
    }
}

extension LeftoverListDriver {
    var uiModelHandedToTheView: LeftoverListUIModel { view.model }
    var uiModelTheViewModelHolds: LeftoverListUIModel { container.model.uiModel }
    var title: String { uiModelHandedToTheView.title }
    var isMeasuring: Bool { uiModelHandedToTheView.isMeasuring }
    var saysThereIsNothingToDelete: Bool { uiModelHandedToTheView.nothingToDelete }
    var leftoverBeingMeasured: String? { uiModelHandedToTheView.leftoverBeingMeasured }
    var confirmation: LeftoverListUIModel.Confirmation? { uiModelHandedToTheView.confirmation }
    var sectionNames: [String] { uiModelHandedToTheView.sections.map(\.name) }
    var sectionSymbols: [String] { uiModelHandedToTheView.sections.map(\.symbol) }
    var rowNames: [String] { rows.map(\.name) }
    var rowsHoldingTheMostRoom: [String] { rows.filter(\.holdsTheMostRoom).map(\.name) }
    var deletableRows: [String] { rows.filter(\.canBeDeleted).map(\.name) }
    var rowsBeingDeleted: [String] { rows.compactMap { $0.deletionUnderWay == nil ? nil : $0.name } }
}

private extension LeftoverListDriver {
    var view: LeftoverListView { container.screen }

    var rows: [LeftoverRow] { uiModelHandedToTheView.sections.flatMap(\.rows) }

    func wait(for settled: (LeftoverListUIModel) -> Bool) async {
        let longerThanAnyStubbedMachineTakes = 100_000

        for _ in 0..<longerThanAnyStubbedMachineTakes where !settled(uiModelHandedToTheView) {
            await Task.yield()
        }
    }
}
