import AppKit
import Foundation
import Testing
import XcodeReclaimCore

@MainActor
struct XcodeReclaimAcceptanceTests {
    @Test("The developer opens the app and sees what may be deleted")
    func open_showsEveryLeftoverWithItsSize() async {
        let app = TheApp(theMachineFinds: [derivedData(taking: 300), aSimulator(taking: 200)])

        app.theDeveloperOpensIt()
        #expect(app.theLeftoverListIsMeasuring)
        #expect(app.whatTheLeftoverListShows.isEmpty)

        await app.untilTheMeasuringEnds()
        #expect(app.whatTheLeftoverListShows == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer deletes a leftover")
    func confirm_takesTheDeletedLeftoverOffTheScreen() async {
        let app = TheApp(theMachineFinds: [derivedData(taking: 300), aSimulator(taking: 200)])
        app.theDeveloperOpensIt()
        await app.untilTheMeasuringEnds()

        app.theDeveloperAsksToDelete("Derived data")
        #expect(app.whatTheLeftoverListIsAskingToConfirm == "Derived data")

        app.theDeveloperConfirms()
        #expect(app.whatTheLeftoverListIsAskingToConfirm == nil)
        #expect(app.whichRowsSayTheyAreBeingDeleted == ["Derived data"])
        #expect(app.whichRowsOfferDeletion.isEmpty)

        await app.untilTheDeletionEnds()
        #expect(app.whatTheLeftoverListShows == ["iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
        #expect(app.whatTheLeftoverListSaysAboutTheDeletion == "300 bytes came back.")
    }

    @Test("A deletion the developer backs out of leaves the leftover as it was")
    func backOut_leavesTheLeftoverAsItWas() async {
        let app = TheApp(theMachineFinds: [derivedData(taking: 300)])
        app.theDeveloperOpensIt()
        await app.untilTheMeasuringEnds()

        app.theDeveloperAsksToDelete("Derived data")
        #expect(app.whatTheLeftoverListIsAskingToConfirm == "Derived data")

        app.theDeveloperBacksOut()
        #expect(app.whatTheLeftoverListIsAskingToConfirm == nil)
        #expect(app.whatTheLeftoverListShows == ["Derived data — 300 bytes"])
        #expect(app.whatTheLeftoverListSaysAboutTheDeletion == nil)
    }

    @Test("The developer refreshes the list")
    func refresh_showsEveryLeftoverTheSecondMeasuringFound() async {
        let app = TheApp(theMachineFinds: [derivedData(taking: 300), aSimulator(taking: 200)])
        app.theDeveloperOpensIt()
        await app.untilTheMeasuringEnds()

        app.theDeveloperAsksToRefresh()
        #expect(app.theLeftoverListIsMeasuring)
        #expect(app.whatTheLeftoverListShows.isEmpty)

        await app.untilTheMeasuringEnds()
        #expect(app.whatTheLeftoverListShows == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer deletes a copy of Xcode they no longer use")
    func confirm_takesTheDeletedCopyOfXcodeOffTheScreenAndSaysWhatCameBack() async {
        let roomItTook = 4_000_000_000
        let app = TheApp(theMachineFinds: [aCopyOfXcode(taking: roomItTook), derivedData(taking: 300)])
        app.theDeveloperOpensIt()
        await app.untilTheMeasuringEnds()

        app.theDeveloperAsksToDelete("Xcode 26.2 (17C51) — Applications")
        #expect(app.whatTheConfirmationReads == "Frees 4.0 GB. That version has to be downloaded again. This cannot be undone.")

        app.theDeveloperConfirms()
        await app.untilTheDeletionEnds()
        #expect(app.whatTheLeftoverListShows == ["Derived data — 300 bytes"])
        #expect(app.whatTheLeftoverListSaysAboutTheDeletion == "4.0 GB came back.")
    }

    @Test("The developer opens the app and it takes its place among the regular applications")
    func open_takesItsPlaceAmongTheRegularApplications() {
        #expect(NSApplication.shared.activationPolicy() == .regular)
        #expect(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") == nil)
    }
}

private extension XcodeReclaimAcceptanceTests {
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
