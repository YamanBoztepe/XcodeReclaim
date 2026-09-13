import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
struct LeftoverListUIIntegrationTests {
    @Test func measure_runsAwayFromTheScreensThreadAndLandsBackOnIt() async {
        let screen = TheLeftoverListScreen(theMachineSaysWhereItRan: AMachineThatSaysWhereItRan())

        screen.isOpened()
        await screen.untilItHasMeasured()

        #expect(screen.whatTheRowsAreCalled == ["away from the screen's thread"])
    }

    @Test func screen_isHandedWhatTheViewModelHoldsAfterEveryEvent() async throws {
        let screen = TheLeftoverListScreen(theMachineFinds: [derivedData(taking: 300)])

        screen.isOpened()
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)

        await screen.untilItHasMeasured()
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)

        try screen.isAskedAboutDeleting("Derived data")
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)
    }

    @Test func screen_drawsTheSectionsAndRowsTheMeasuringFound() async {
        let screen = TheLeftoverListScreen(theMachineFinds: [derivedData(taking: 300), aSimulator(taking: 200), aCopyOfXcode(taking: 100)])

        screen.isOpened()
        await screen.untilItHasMeasured()

        #expect(screen.whatTheSectionsAreCalled == ["Caches and support files", "Simulators", "Xcode versions"])
        #expect(screen.whatTheSectionsAreDrawnWith == ["folder.fill", "iphone", "hammer.fill"])
        #expect(screen.whichRowIsMarkedAsHoldingTheMostRoom == ["Derived data"])
    }

    @Test func askAboutDeleting_reachesTheAlertTheScreenDraws() async throws {
        let screen = TheLeftoverListScreen(theMachineFinds: [derivedData(taking: 300)])
        screen.isOpened()
        await screen.untilItHasMeasured()
        #expect(screen.whatIsBeingConfirmed == nil)

        try screen.isAskedAboutDeleting("Derived data")
        #expect(screen.whatIsBeingConfirmed == .init(name: "Derived data", sentence: "Frees 300 bytes. This cannot be undone."))

        screen.hasTheDeletionBackedOutOf()
        #expect(screen.whatIsBeingConfirmed == nil)
    }

    @Test func confirm_takesEveryRowsDeletionAwayUntilTheDeletionEnds() async throws {
        let screen = TheLeftoverListScreen(theMachineFinds: [derivedData(taking: 300), aSimulator(taking: 200)])
        screen.isOpened()
        await screen.untilItHasMeasured()
        #expect(screen.whichRowsOfferDeletion == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])

        try screen.isAskedAboutDeleting("Derived data")
        screen.hasTheDeletionConfirmed()
        #expect(screen.whichRowsOfferDeletion.isEmpty)
        #expect(screen.whichRowsSayTheyAreBeingDeleted == ["Derived data"])

        await screen.untilItSaysSomethingAboutTheDeletion()
        #expect(screen.whichRowsOfferDeletion == ["iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.whatTheRowsAreCalled == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test func refresh_putsTheScreenBackToMeasuring() async {
        let screen = TheLeftoverListScreen(theMachineFinds: [derivedData(taking: 300)])
        screen.isOpened()
        await screen.untilItHasMeasured()
        #expect(screen.itIsMeasuring == false)

        screen.isRefreshed()
        #expect(screen.itIsMeasuring)
        #expect(screen.whatTheRowsAreCalled.isEmpty)
    }

    @Test func measuringEnded_drawsNothingToDeleteOnlyOnceTheMeasuringIsOver() async {
        let screen = TheLeftoverListScreen()

        screen.isOpened()
        #expect(screen.itSaysThereIsNothingToDelete == false)

        await screen.untilItHasMeasured()
        #expect(screen.itSaysThereIsNothingToDelete)
        #expect(screen.whatItIsCalled == "XcodeReclaim")
    }

    @Test("The developer watches the measuring work through the leftovers")
    func announced_namesEachLeftoverAsTheMeasuringReachesIt() async {
        let screen = TheLeftoverListScreen(theMeasuringAnnouncesThenTakesAWhile: ["Derived data", "Previews"], finding: [derivedData(taking: 300)])

        screen.isOpened()
        await screen.untilItNames("Previews")
        #expect(screen.itIsMeasuring)

        screen.theMeasuringFinishes()
        await screen.untilItHasMeasured()
        #expect(screen.whatIsBeingMeasured == nil)
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() async {
        let screen = TheLeftoverListScreen(
            eachMeasuringWaitsThenFinds: [[derivedData(taking: 27_700_000_000)], [previews(taking: 300)]],
            announcing: [[], []])
        screen.isOpened()
        screen.isRefreshed()

        screen.everyMeasuringFinishes()
        await screen.untilItHasMeasured()

        #expect(screen.whatTheRowsAreCalled == ["Previews"])
    }

    @Test func refresh_dropsWhatAReplacedMeasuringAnnounces() async {
        let screen = TheLeftoverListScreen(
            eachMeasuringWaitsThenFinds: [[derivedData(taking: 300)], [previews(taking: 300)]],
            announcing: [["Derived data"], ["Previews"]])
        screen.isOpened()
        screen.isRefreshed()

        screen.theMeasuringFinishes(0)
        await screen.untilEverythingQueuedHasRun()

        #expect(screen.whatIsBeingMeasured == nil)
        #expect(screen.itIsMeasuring)
        screen.everyMeasuringFinishes()
    }

    @Test func screen_doesNotKeepItsViewModelAliveOnceTheScreenIsGone() {
        let machine = TheMachine()
        var container: LeftoverListContainerView? = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        weak let model = container?.model

        container = nil

        #expect(model == nil)
    }
}

private extension LeftoverListUIIntegrationTests {
    func derivedData(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.derivedData(taking: bytes)
    }

    func aSimulator(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.aSimulator(taking: bytes)
    }

    func aCopyOfXcode(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.aCopyOfXcode(taking: bytes)
    }

    func previews(taking bytes: Int) -> Leftover {
        ALeftoverOnTheMachine.previews(taking: bytes)
    }
}
