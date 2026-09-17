import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimPresentation

@MainActor
struct LeftoverListUIIntegrationTests {
    @Test func measure_runsAwayFromTheScreensThread() async {
        let machine = MachineThreadSpy()
        let screen = screenMeasuring(machine)

        screen.open()
        await screen.waitForMeasuringToEnd()

        #expect(machine.whereEachMeasuringRan == ["away from the screen's thread"])
    }

    @Test func screen_isHandedWhatTheViewModelHoldsAfterEveryEvent() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300)])
        let screen = screenMeasuring(machine)

        screen.open()
        #expect(screen.uiModelHandedToTheView == screen.uiModelTheViewModelHolds)

        await screen.waitForMeasuringToEnd()
        #expect(screen.uiModelHandedToTheView == screen.uiModelTheViewModelHolds)

        try screen.askToDelete("Derived data")
        #expect(screen.uiModelHandedToTheView == screen.uiModelTheViewModelHolds)
    }

    @Test func screen_drawsTheSectionsAndRowsTheMeasuringFound() async {
        let machine = MachineStub(finding: [derivedData(taking: 300), simulator(taking: 200), copyOfXcode(taking: 100)])
        let screen = screenMeasuring(machine)

        screen.open()
        await screen.waitForMeasuringToEnd()

        #expect(screen.sectionNames == ["Caches and support files", "Simulators", "Xcode versions"])
        #expect(screen.sectionSymbols == ["folder.fill", "iphone", "hammer.fill"])
        #expect(screen.rowsHoldingTheMostRoom == ["Derived data"])
    }

    @Test func askAboutDeleting_reachesTheAlertTheScreenDraws() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.confirmation == nil)

        try screen.askToDelete("Derived data")
        #expect(screen.confirmation == .init(question: "Delete Derived data?", sentence: "Frees 300 bytes. This cannot be undone."))

        screen.cancel()
        #expect(screen.confirmation == nil)
    }

    @Test func confirm_takesEveryRowsDeletionAwayUntilTheDeletionEnds() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300), simulator(taking: 200)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.deletableRows == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])

        try screen.askToDelete("Derived data")
        screen.confirm()
        #expect(screen.deletableRows.isEmpty)
        #expect(screen.rowsBeingDeleted == ["Derived data"])

        await screen.waitForDeletionToEnd()
        #expect(screen.deletableRows == ["iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.rowNames == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test func refresh_putsTheScreenBackToMeasuring() async {
        let machine = MachineStub(finding: [derivedData(taking: 300)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.isMeasuring == false)

        screen.refresh()
        #expect(screen.isMeasuring)
        #expect(screen.rowNames.isEmpty)
    }

    @Test func measuringEnded_drawsNothingToDeleteOnlyOnceTheMeasuringIsOver() async {
        let screen = screenMeasuring(MachineStub())

        screen.open()
        #expect(screen.saysThereIsNothingToDelete == false)

        await screen.waitForMeasuringToEnd()
        #expect(screen.saysThereIsNothingToDelete)
        #expect(screen.title.isEmpty)
    }

    @Test("The developer watches the measuring work through the leftovers")
    func announced_namesEachLeftoverAsTheMeasuringReachesIt() async {
        let machine = SlowMachineStub(eachMeasuring: [MachineStub(announcing: ["Derived data", "Previews"], finding: [derivedData(taking: 300)])])
        let screen = screenMeasuring(machine)

        screen.open()
        await screen.waitForMeasuringToReach("Previews")
        #expect(screen.leftoverBeingMeasured == "Previews")
        #expect(screen.isMeasuring)

        machine.letEveryMeasuringFinish()
        await screen.waitForMeasuringToEnd()
        #expect(screen.leftoverBeingMeasured == nil)
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() async {
        let theMeasuringTheRefreshReplaces = 0
        let theMeasuringTheRefreshStarts = 1
        let machine = SlowMachineStub(eachMeasuring: [
            MachineStub(announcing: ["Derived data"], finding: [derivedData(taking: 27_700_000_000)]),
            MachineStub(finding: [previews(taking: 300)]),
        ])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToReach("Derived data")
        screen.refresh()

        machine.letMeasuringFinish(theMeasuringTheRefreshStarts)
        await screen.waitForMeasuringToEnd()
        #expect(screen.rowNames == ["Previews"])

        machine.letMeasuringFinish(theMeasuringTheRefreshReplaces)
        await screen.waitForEverythingQueuedToRun()
        #expect(screen.rowNames == ["Previews"])
    }

    @Test func choose_marksTheRowsOnTheScreenAndOffersToDeleteThem() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300), simulator(taking: 200)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.offersToDeleteWhatIsChosen == false)

        try screen.choose("Derived data", "iPhone 17 (iOS 26.4, 21B507D3)")

        #expect(screen.chosenRows == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.offersToDeleteWhatIsChosen)
    }

    @Test func sort_putsTheRowsTheScreenDrawsInTheOrderAskedFor() async {
        let machine = MachineStub(finding: [previews(taking: 300), derivedData(taking: 200)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.rowNames == ["Previews", "Derived data"])

        screen.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: true))

        #expect(screen.rowNames == ["Derived data", "Previews"])
    }

    @Test func askToDelete_overManyRowsAsksOneQuestionOnTheScreen() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300), previews(taking: 200)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()

        try screen.askToDelete("Derived data", "Previews")

        #expect(screen.confirmation == .init(question: "Delete 2 items?", sentence: "Frees 500 bytes. The previews are built again. This cannot be undone."))
    }

    @Test func menu_asksAboutDeletingTheRowsChosenOnTheScreen() async throws {
        let machine = MachineStub(finding: [derivedData(taking: 300)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.menuOffersDeletion == false)

        try screen.choose("Derived data")
        #expect(screen.menuOffersDeletion)

        screen.askToDeleteFromTheMenu()
        #expect(screen.confirmation == .init(question: "Delete Derived data?", sentence: "Frees 300 bytes. This cannot be undone."))
    }

    @Test func menu_refreshesTheScreenAndOffersNoRefreshWhileItMeasures() async {
        let machine = MachineStub(finding: [derivedData(taking: 300)])
        let screen = screenMeasuring(machine)
        screen.open()
        await screen.waitForMeasuringToEnd()
        #expect(screen.menuOffersARefresh)

        screen.refreshFromTheMenu()

        #expect(screen.isMeasuring)
        #expect(screen.menuOffersARefresh == false)
    }

    @Test func screen_doesNotKeepItsViewModelAliveOnceTheScreenIsGone() {
        let machine = MachineStub()
        var container: LeftoverListContainerView? = screenMeasuring(machine)
        weak let model = container?.model

        container = nil

        #expect(model == nil)
    }
}
