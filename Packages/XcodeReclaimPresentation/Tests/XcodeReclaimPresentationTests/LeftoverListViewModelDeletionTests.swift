import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelDeletionTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test("A deletion asked about is confirmed first")
    func askAboutDeleting_asksToConfirmNamingTheLeftoverAndWhatItCosts() throws {
        let roomItTakes = 200
        let (sut, _) = makeSUT()
        let cost = "the symbols are put back the next time that device is plugged in"
        sut.measuringEnded(with: [ALeftover.folder(named: "Device support (iOS 26.4)", taking: roomItTakes, costing: cost)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(
            sut.uiModel.confirmation
                == LeftoverListUIModel.Confirmation(
                    name: "Device support (iOS 26.4)",
                    sentence: "Frees 200 bytes. The symbols are put back the next time that device is plugged in. This cannot be undone."))
    }

    @Test
    func askAboutDeleting_asksToConfirmWithoutACostWhenTheLeftoverCostsNothing() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(sut.uiModel.confirmation?.sentence == "Frees 200 bytes. This cannot be undone.")
    }

    @Test("A deletion the developer backs out of leaves the leftover as it was")
    func backOut_leavesTheLeftoverAsItWas() throws {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        sut.backOut()

        #expect(sut.uiModel.confirmation == nil)
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.size) == ["200 bytes"])
        #expect(requests.deletions.isEmpty)
    }

    @Test("A confirmed deletion marks its own row")
    func confirm_marksItsOwnRowAndAsksForTheDeletion() throws {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        sut.confirm()

        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.deletionUnderWay) == ["Deleting…", nil])
        #expect(requests.deletions.map(\.name) == ["Derived data"])
    }

    @Test("A finished deletion empties its row")
    func deletionEnded_emptiesTheRowItFreed() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .freed(300))

        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.name) == ["Previews"])
    }

    @Test("A finished deletion says how much room came back")
    func deletionEnded_saysHowMuchRoomCameBack() throws {
        let whatCameBack = 200
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .freed(whatCameBack))

        #expect(sut.uiModel.whatTheDeletionSaid == "200 bytes came back.")
    }

    @Test
    func confirm_asksNothingOnceItIsConfirmed() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        sut.confirm()

        #expect(sut.uiModel.confirmation == nil)
    }

    @Test("A deletion under way offers no other deletion until it ends")
    func confirm_offersNoOtherDeletionUntilTheDeletionEnds() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        sut.confirm()
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.canBeDeleted) == [false, false])

        sut.deletionEnded(with: .freed(300))
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.canBeDeleted) == [true])
    }

    @Test("A deletion refused because the simulator is running says so")
    func deletionEnded_saysTheSimulatorIsRunningWhenTheDeletionWasRefused() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.simulator(taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .refused(.theSimulatorIsRunning))

        #expect(sut.uiModel.whatTheDeletionSaid == "The simulator is running.")
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test("A deletion that failed says so")
    func deletionEnded_saysTheLeftoverCouldNotBeDeletedAndWhy() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .failed("Invalid device"))

        #expect(sut.uiModel.whatTheDeletionSaid == "Derived data could not be deleted. Invalid device")
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
    }

    @Test
    func confirm_asksForNoDeletionWhenNothingWasAskedAbout() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.confirm()

        #expect(requests.deletions.isEmpty)
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.deletionUnderWay) == [nil])
    }

    @Test
    func deletionEnded_saysNothingWhenNoDeletionWasUnderWay() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.deletionEnded(with: .freed(200))

        #expect(sut.uiModel.whatTheDeletionSaid == nil)
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
    }

    @Test("A running simulator offers no deletion")
    func measuringEnded_offersNoDeletionForARunningSimulatorAndSaysWhy() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning)])

        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.canBeDeleted) == [false])
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.refusal) == ["The simulator is running."])
    }

    @Test("A running simulator is not confirmed")
    func askAboutDeleting_asksNothingForARunningSimulator() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(sut.uiModel.confirmation == nil)
    }

    @Test("A deletion that ends while the screen is measuring again does not put the old list back")
    func deletionEnded_doesNotPutTheOldListBackWhileTheScreenIsMeasuringAgain() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()
        sut.refresh()

        sut.deletionEnded(with: .freed(200))

        #expect(sut.uiModel.isMeasuring)
        #expect(sut.uiModel.leftoverBeingMeasured == nil)
        #expect(sut.uiModel.sections.isEmpty)
        #expect(sut.uiModel.whatTheDeletionSaid == "200 bytes came back.")
    }

    @Test("A confirmation says how much room it frees the way a person reads it")
    func askAboutDeleting_saysHowMuchRoomItFreesTheWayAPersonReadsIt() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 28_359_995_392)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(sut.uiModel.confirmation?.sentence == "Frees 28.4 GB. This cannot be undone.")
    }

    @Test("A row says under its name only why it cannot be deleted")
    func measuringEnded_saysUnderARowsNameOnlyWhyItCannotBeDeleted() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [
            ALeftover.folder(named: "Device support (iOS 26.4)", taking: 300, costing: "the symbols are put back the next time that device is plugged in"),
            ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning),
        ])

        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.refusal) == [nil, "The simulator is running."])
    }

    @Test("A copy of Xcode that is open offers no deletion")
    func askAboutDeleting_asksNothingForAnOpenCopyOfXcode() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.copyOfXcode(taking: 200, refusedFor: .xcodeIsOpen)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(sut.uiModel.confirmation == nil)
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.refusal) == ["Xcode is open."])
    }

    @Test("The copy the command line tools point at offers no deletion")
    func askAboutDeleting_asksNothingForTheCopyTheCommandLineToolsPointAt() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.copyOfXcode(taking: 200, refusedFor: .theCommandLineToolsPointAtIt)])

        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))

        #expect(sut.uiModel.confirmation == nil)
        #expect(sut.uiModel.sections.flatMap(\.rows).map(\.refusal) == ["The command line tools point at this one."])
    }
}

private extension LeftoverListViewModelDeletionTests {
    func makeSUT() -> (sut: LeftoverListViewModel, requests: RequestsFromTheScreen) {
        let requests = RequestsFromTheScreen()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return (sut, requests)
    }
}
