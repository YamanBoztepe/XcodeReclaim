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

    @Test func aDeletionAskedAboutIsConfirmedFirst() throws {
        let roomItTakes = 200
        let (sut, _) = makeSUT()
        let cost = "the symbols are put back the next time that device is plugged in"
        sut.measuringEnded(with: [ALeftover.folder(named: "Device support (iOS 26.4)", taking: roomItTakes, costing: cost)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(
            sut.confirmation
                == LeftoverListViewModel.Confirmation(
                    name: "Device support (iOS 26.4)",
                    sentence: "Frees 200 bytes. The symbols are put back the next time that device is plugged in. This cannot be undone."))
    }

    @Test func aLeftoverThatCostsNothingIsConfirmedWithoutACost() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(sut.confirmation?.sentence == "Frees 200 bytes. This cannot be undone.")
    }

    @Test func aDeletionTheDeveloperBacksOutOfLeavesTheLeftoverAsItWas() throws {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        sut.backOut()

        #expect(sut.confirmation == nil)
        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
        #expect(sut.sections.flatMap(\.rows).map(\.size) == ["200 bytes"])
        #expect(requests.deletions.isEmpty)
    }

    @Test func aConfirmedDeletionMarksItsOwnRow() throws {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        sut.confirm()

        #expect(sut.sections.flatMap(\.rows).map(\.isBeingDeleted) == [true, false])
        #expect(requests.deletions.map(\.name) == ["Derived data"])
    }

    @Test func aFinishedDeletionEmptiesItsRow() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .freed(300))

        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["Previews"])
    }

    @Test func aFinishedDeletionSaysHowMuchRoomCameBack() throws {
        let whatCameBack = 200
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .freed(whatCameBack))

        #expect(sut.whatTheDeletionSaid == "200 bytes came back.")
    }

    @Test func aConfirmedDeletionIsNoLongerAskedAbout() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        sut.confirm()

        #expect(sut.confirmation == nil)
    }

    @Test func aDeletionUnderWayOffersNoOtherDeletionUntilItEnds() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        sut.confirm()
        #expect(sut.sections.flatMap(\.rows).map(\.canBeDeleted) == [false, false])

        sut.deletionEnded(with: .freed(300))
        #expect(sut.sections.flatMap(\.rows).map(\.canBeDeleted) == [true])
    }

    @Test func aDeletionRefusedBecauseTheSimulatorIsRunningSaysSo() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.simulator(taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .refused(.theSimulatorIsRunning))

        #expect(sut.whatTheDeletionSaid == "The simulator is running.")
        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test func aDeletionThatFailedSaysSo() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()

        sut.deletionEnded(with: .failed("Invalid device"))

        #expect(sut.whatTheDeletionSaid == "Derived data could not be deleted. Invalid device")
        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
    }

    @Test func confirmingWhenNothingWasAskedAboutAsksForNoDeletion() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.confirm()

        #expect(requests.deletions.isEmpty)
        #expect(sut.sections.flatMap(\.rows).map(\.isBeingDeleted) == [false])
    }

    @Test func aDeletionEndingWhenNoneWasUnderWaySaysNothing() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        sut.deletionEnded(with: .freed(200))

        #expect(sut.whatTheDeletionSaid == nil)
        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
    }

    @Test func aRunningSimulatorOffersNoDeletion() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning)])

        #expect(sut.sections.flatMap(\.rows).map(\.canBeDeleted) == [false])
        #expect(sut.sections.flatMap(\.rows).map(\.refusal) == ["The simulator is running."])
    }

    @Test func aRunningSimulatorIsNotConfirmed() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(sut.confirmation == nil)
    }

    @Test func aDeletionThatEndsWhileTheScreenIsMeasuringAgainDoesNotPutTheOldListBack() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()
        sut.refresh()

        sut.deletionEnded(with: .freed(200))

        #expect(sut.isMeasuring)
        #expect(sut.leftoverBeingMeasured == nil)
        #expect(sut.sections.isEmpty)
        #expect(sut.whatTheDeletionSaid == "200 bytes came back.")
    }

    @Test func aConfirmationSaysHowMuchRoomItFreesTheWayAPersonReadsIt() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 28_359_995_392)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(sut.confirmation?.sentence == "Frees 28.4 GB. This cannot be undone.")
    }

    @Test func aRowSaysUnderItsNameOnlyWhyItCannotBeDeleted() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [
            ALeftover.folder(named: "Device support (iOS 26.4)", taking: 300, costing: "the symbols are put back the next time that device is plugged in"),
            ALeftover.simulator(taking: 200, refusedFor: .theSimulatorIsRunning),
        ])

        #expect(sut.sections.flatMap(\.rows).map(\.refusal) == [nil, "The simulator is running."])
    }

    @Test func aCopyOfXcodeThatIsOpenOffersNoDeletion() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.copyOfXcode(taking: 200, refusedFor: .xcodeIsOpen)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(sut.confirmation == nil)
        #expect(sut.sections.flatMap(\.rows).map(\.refusal) == ["Xcode is open."])
    }

    @Test func theCopyTheCommandLineToolsPointAtOffersNoDeletion() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.copyOfXcode(taking: 200, refusedFor: .theCommandLineToolsPointAtIt)])

        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))

        #expect(sut.confirmation == nil)
        #expect(sut.sections.flatMap(\.rows).map(\.refusal) == ["The command line tools point at this one."])
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
