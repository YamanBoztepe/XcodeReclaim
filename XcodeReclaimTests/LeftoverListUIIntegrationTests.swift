import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
struct LeftoverListUIIntegrationTests {
    @Test func screen_isHandedWhatTheViewModelHoldsAfterEveryEvent() {
        let (container, machine) = makeSUT()

        container.screen.onAppear()
        #expect(drawn(container) == container.model.uiModel)

        machine.deliver([derivedData(taking: 300)], from: 0)
        #expect(drawn(container) == container.model.uiModel)

        drawn(container).sections.first?.rows.first.map(container.screen.onAskAboutDeleting)
        #expect(drawn(container) == container.model.uiModel)
    }

    @Test func screen_drawsTheSectionsAndRowsTheMeasuringFound() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()

        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200), aCopyOfXcode(taking: 100)], from: 0)

        #expect(drawn(container).sections.map(\.name) == ["Caches and support files", "Simulators", "Xcode versions"])
        #expect(drawn(container).sections.map(\.symbol) == ["folder.fill", "iphone", "hammer.fill"])
        #expect(drawn(container).sections.flatMap(\.rows).map(\.holdsTheMostRoom) == [true, false, false])
    }

    @Test func askAboutDeleting_reachesTheAlertTheScreenDraws() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()
        machine.deliver([derivedData(taking: 300)], from: 0)
        #expect(drawn(container).confirmation == nil)

        drawn(container).sections.first?.rows.first.map(container.screen.onAskAboutDeleting)
        #expect(drawn(container).confirmation == LeftoverListUIModel.Confirmation(name: "Derived data", sentence: "Frees 300 bytes. This cannot be undone."))

        container.screen.onBackOut()
        #expect(drawn(container).confirmation == nil)
    }

    @Test func confirm_takesEveryRowsDeletionAwayUntilTheDeletionEnds() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 0)
        #expect(drawn(container).sections.flatMap(\.rows).map(\.canBeDeleted) == [true, true])

        drawn(container).sections.first?.rows.first.map(container.screen.onAskAboutDeleting)
        container.screen.onConfirm()
        #expect(drawn(container).sections.flatMap(\.rows).map(\.canBeDeleted) == [false, false])
        #expect(drawn(container).sections.flatMap(\.rows).map(\.deletionUnderWay) == ["Deleting…", nil])

        machine.report(.freed(300), from: 0)
        #expect(drawn(container).sections.flatMap(\.rows).map(\.canBeDeleted) == [true])
    }

    @Test func refresh_putsTheScreenBackToMeasuringAndAsksTheMachineAgain() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()
        machine.deliver([derivedData(taking: 300)], from: 0)
        #expect(drawn(container).isMeasuring == false)

        container.screen.onRefresh()
        #expect(drawn(container).isMeasuring)
        #expect(drawn(container).sections.isEmpty)
        #expect(machine.measurings == 2)
    }

    @Test func measuringEnded_drawsNothingToDeleteOnlyOnceTheMeasuringIsOver() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()
        #expect(drawn(container).nothingToDelete == false)

        machine.deliver([], from: 0)
        #expect(drawn(container).nothingToDelete)
        #expect(drawn(container).title == "XcodeReclaim")
    }

    @Test("The developer watches the measuring work through the leftovers")
    func announced_namesEachLeftoverAsTheMeasuringReachesIt() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()
        #expect(drawn(container).leftoverBeingMeasured == nil)

        machine.announce("Derived data", from: 0)
        #expect(drawn(container).leftoverBeingMeasured == "Derived data")

        machine.announce("Previews", from: 0)
        #expect(drawn(container).leftoverBeingMeasured == "Previews")

        machine.deliver([derivedData(taking: 300)], from: 0)
        #expect(drawn(container).leftoverBeingMeasured == nil)
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()

        container.screen.onRefresh()
        machine.deliver([derivedData(taking: 27_700_000_000)], from: 0)
        #expect(drawn(container).isMeasuring)
        #expect(drawn(container).sections.isEmpty)

        machine.deliver([derivedData(taking: 300)], from: 1)
        #expect(drawn(container).sections.flatMap(\.rows).map(\.name) == ["Derived data"])
    }

    @Test func refresh_dropsWhatAReplacedMeasuringAnnounces() {
        let (container, machine) = makeSUT()
        container.screen.onAppear()

        container.screen.onRefresh()
        machine.announce("Derived data", from: 0)
        #expect(drawn(container).leftoverBeingMeasured == nil)

        machine.announce("Previews", from: 1)
        #expect(drawn(container).leftoverBeingMeasured == "Previews")
    }

    @Test func screen_doesNotKeepItsViewModelAliveOnceTheScreenIsGone() {
        let machine = TheMachineSpy()
        var container: LeftoverListContainerView? = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        weak let model = container?.model

        container = nil

        #expect(model == nil)
    }
}

private extension LeftoverListUIIntegrationTests {
    func makeSUT() -> (container: LeftoverListContainerView, machine: TheMachineSpy) {
        let machine = TheMachineSpy()
        return (LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting), machine)
    }

    func drawn(_ container: LeftoverListContainerView) -> LeftoverListUIModel {
        container.screen.model
    }

    func derivedData(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.derivedData(taking: bytes)
    }

    func aSimulator(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.aSimulator(taking: bytes)
    }

    func aCopyOfXcode(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.aCopyOfXcode(taking: bytes)
    }
}
