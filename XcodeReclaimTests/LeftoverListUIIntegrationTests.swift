import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
struct LeftoverListUIIntegrationTests {
    @Test func screen_isHandedWhatTheViewModelHoldsAfterEveryEvent() {
        let screen = TheScreen()

        screen.isOpened()
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)

        screen.theMeasuringFinds([derivedData(taking: 300)])
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)

        screen.isAskedAboutDeleting("Derived data")
        #expect(screen.whatIsHandedToTheView == screen.whatTheViewModelHolds)
    }

    @Test func screen_drawsTheSectionsAndRowsTheMeasuringFound() {
        let screen = TheScreen()
        screen.isOpened()

        screen.theMeasuringFinds([derivedData(taking: 300), aSimulator(taking: 200), aCopyOfXcode(taking: 100)])

        #expect(screen.whatTheSectionsAreCalled == ["Caches and support files", "Simulators", "Xcode versions"])
        #expect(screen.whatTheSectionsAreDrawnWith == ["folder.fill", "iphone", "hammer.fill"])
        #expect(screen.whichRowIsMarkedAsHoldingTheMostRoom == ["Derived data"])
    }

    @Test func askAboutDeleting_reachesTheAlertTheScreenDraws() {
        let screen = TheScreen()
        screen.isOpened()
        screen.theMeasuringFinds([derivedData(taking: 300)])
        #expect(screen.whatIsBeingConfirmed == nil)

        screen.isAskedAboutDeleting("Derived data")
        #expect(screen.whatIsBeingConfirmed == .init(name: "Derived data", sentence: "Frees 300 bytes. This cannot be undone."))

        screen.hasTheDeletionBackedOutOf()
        #expect(screen.whatIsBeingConfirmed == nil)
    }

    @Test func confirm_takesEveryRowsDeletionAwayUntilTheDeletionEnds() {
        let screen = TheScreen()
        screen.isOpened()
        screen.theMeasuringFinds([derivedData(taking: 300), aSimulator(taking: 200)])
        #expect(screen.whichRowsOfferDeletion == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])

        screen.isAskedAboutDeleting("Derived data")
        screen.hasTheDeletionConfirmed()
        #expect(screen.whichRowsOfferDeletion.isEmpty)
        #expect(screen.whichRowsSayTheyAreBeingDeleted == ["Derived data"])

        screen.theDeletionFrees(300)
        #expect(screen.whichRowsOfferDeletion == ["iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.whatTheRowsAreCalled == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test func refresh_putsTheScreenBackToMeasuringAndAsksTheMachineAgain() {
        let screen = TheScreen()
        screen.isOpened()
        screen.theMeasuringFinds([derivedData(taking: 300)])
        #expect(screen.itIsMeasuring == false)

        screen.isRefreshed()
        #expect(screen.itIsMeasuring)
        #expect(screen.whatTheRowsAreCalled.isEmpty)
        #expect(screen.howManyMeasuringsWereAskedFor == 2)
    }

    @Test func measuringEnded_drawsNothingToDeleteOnlyOnceTheMeasuringIsOver() {
        let screen = TheScreen()
        screen.isOpened()
        #expect(screen.itSaysThereIsNothingToDelete == false)

        screen.theMeasuringFinds([])
        #expect(screen.itSaysThereIsNothingToDelete)
        #expect(screen.whatItIsCalled == "XcodeReclaim")
    }

    @Test("The developer watches the measuring work through the leftovers")
    func announced_namesEachLeftoverAsTheMeasuringReachesIt() {
        let screen = TheScreen()
        screen.isOpened()
        #expect(screen.whatIsBeingMeasured == nil)

        screen.theMeasuringAnnounces("Derived data")
        #expect(screen.whatIsBeingMeasured == "Derived data")

        screen.theMeasuringAnnounces("Previews")
        #expect(screen.whatIsBeingMeasured == "Previews")

        screen.theMeasuringFinds([derivedData(taking: 300)])
        #expect(screen.whatIsBeingMeasured == nil)
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() {
        let screen = TheScreen()
        screen.isOpened()

        screen.isRefreshed()
        screen.theMeasuringThatWasReplacedFinds([derivedData(taking: 27_700_000_000)])
        #expect(screen.itIsMeasuring)
        #expect(screen.whatTheRowsAreCalled.isEmpty)

        screen.theMeasuringFinds([derivedData(taking: 300)])
        #expect(screen.whatTheRowsAreCalled == ["Derived data"])
    }

    @Test func refresh_dropsWhatAReplacedMeasuringAnnounces() {
        let screen = TheScreen()
        screen.isOpened()

        screen.isRefreshed()
        screen.theMeasuringThatWasReplacedAnnounces("Derived data")
        #expect(screen.whatIsBeingMeasured == nil)

        screen.theMeasuringAnnounces("Previews")
        #expect(screen.whatIsBeingMeasured == "Previews")
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
