import AppKit
import Foundation
import Testing
import XcodeReclaimCore

@MainActor
struct LeftoverListAcceptanceTests {
    @Test("The developer opens the app and sees what may be deleted")
    func open_showsEveryLeftoverWithItsSize() {
        let app = TheApp()

        app.theDeveloperOpensIt()
        app.theMeasuringFinds([derivedData(taking: 300), aSimulator(taking: 200)])

        #expect(app.whatTheScreenShows == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer deletes a leftover")
    func confirm_takesTheDeletedLeftoverOffTheScreen() {
        let app = TheApp()
        app.theDeveloperOpensIt()
        app.theMeasuringFinds([derivedData(taking: 300), aSimulator(taking: 200)])

        app.theDeveloperAsksToDelete("Derived data")
        app.theDeveloperConfirms()
        app.theDeletionFrees(300)

        #expect(app.whatTheMachineWasAskedToDelete == ["Derived data"])
        #expect(app.whatTheScreenShows == ["iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer refreshes the list")
    func refresh_showsEveryLeftoverTheSecondMeasuringFound() {
        let app = TheApp()
        app.theDeveloperOpensIt()
        app.theMeasuringFinds([derivedData(taking: 300)])

        app.theDeveloperAsksToRefresh()
        app.theMeasuringFinds([derivedData(taking: 300), aSimulator(taking: 200)])

        #expect(app.howManyMeasuringsWereAskedFor == 2)
        #expect(app.whatTheScreenShows == ["Derived data — 300 bytes", "iPhone 17 (iOS 26.4, 21B507D3) — 200 bytes"])
    }

    @Test("The developer watches the measuring work through the leftovers")
    func open_namesEachLeftoverAsTheMeasuringReachesIt() {
        let app = TheApp()
        app.theDeveloperOpensIt()

        app.theMeasuringAnnounces("Derived data")
        #expect(app.whatTheScreenIsMeasuring == "Derived data")

        app.theMeasuringAnnounces("Previews")
        #expect(app.whatTheScreenIsMeasuring == "Previews")
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() {
        let app = TheApp()
        app.theDeveloperOpensIt()

        app.theDeveloperAsksToRefresh()
        app.theMeasuringThatWasReplacedFinds([derivedData(taking: 27_700_000_000)])

        #expect(app.theScreenIsMeasuring)
        #expect(app.whatTheScreenShows.isEmpty)
    }

    @Test func refresh_dropsWhatAReplacedMeasuringAnnounces() {
        let app = TheApp()
        app.theDeveloperOpensIt()

        app.theDeveloperAsksToRefresh()
        app.theMeasuringThatWasReplacedAnnounces("Derived data")

        #expect(app.whatTheScreenIsMeasuring == nil)
    }

    @Test("The developer deletes a copy of Xcode they no longer use")
    func confirm_takesTheDeletedCopyOfXcodeOffTheScreenAndSaysWhatCameBack() {
        let roomItTook = 4_000_000_000
        let app = TheApp()
        app.theDeveloperOpensIt()
        app.theMeasuringFinds([aCopyOfXcode(taking: roomItTook), derivedData(taking: 300)])

        app.theDeveloperAsksToDelete("Xcode 26.2 (17C51) — Applications")
        app.theDeveloperConfirms()
        app.theDeletionFrees(roomItTook)

        #expect(app.whatTheMachineWasAskedToDelete == ["Xcode 26.2 (17C51) — Applications"])
        #expect(app.whatTheScreenShows == ["Derived data — 300 bytes"])
        #expect(app.whatTheScreenSaysAboutTheDeletion == "4.0 GB came back.")
    }

    @Test("The developer opens the app and it takes its place among the regular applications")
    func open_takesItsPlaceAmongTheRegularApplications() {
        #expect(NSApplication.shared.activationPolicy() == .regular)
        #expect(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") == nil)
    }
}

private extension LeftoverListAcceptanceTests {
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
