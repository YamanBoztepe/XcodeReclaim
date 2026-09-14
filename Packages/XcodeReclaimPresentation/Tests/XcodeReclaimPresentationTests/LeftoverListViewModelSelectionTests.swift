import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelSelectionTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test
    func select_marksTheRowsTheDeveloperChose() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])

        sut.select(rowsNamed: "Derived data", "Previews")

        #expect(sut.selectedNames == ["Derived data", "Previews"])
    }

    @Test
    func select_offersNoDeletionUntilARowThatCanBeDeletedIsChosen() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), simulator(taking: 200, refusedFor: .simulatorIsRunning)])
        #expect(sut.uiModel.canDeleteSelection == false)

        sut.select(rowsNamed: "iPhone 17 (iOS 26.4, 21B507D3)")
        #expect(sut.uiModel.canDeleteSelection == false)

        sut.select(rowsNamed: "Derived data")
        #expect(sut.uiModel.canDeleteSelection)
    }

    @Test
    func askAboutDeleting_asksOneQuestionOverEveryRowChosen() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])

        sut.askAboutDeleting(rowsNamed: "Derived data", "Previews")

        #expect(
            sut.uiModel.confirmation
                == LeftoverListUIModel.Confirmation(question: "Delete 2 items?", sentence: "Frees 500 bytes. This cannot be undone."))
    }

    @Test
    func askAboutDeleting_leavesOutTheRowsThatCannotBeDeletedAndSaysHowMany() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), simulator(taking: 200, refusedFor: .simulatorIsRunning)])

        sut.askAboutDeleting(rowsNamed: "Derived data", "iPhone 17 (iOS 26.4, 21B507D3)")

        #expect(
            sut.uiModel.confirmation
                == LeftoverListUIModel.Confirmation(
                    question: "Delete Derived data?",
                    sentence: "Frees 300 bytes. Leaving 1 that cannot be deleted. This cannot be undone."))
    }

    @Test
    func askAboutDeleting_saysACostOnceHoweverManyRowsCarryIt() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [
            simulator(named: "iPhone 17", taking: 300),
            simulator(named: "iPhone 16", taking: 200),
        ])

        sut.askAboutDeleting(rowsNamed: "iPhone 17", "iPhone 16")

        #expect(
            sut.uiModel.confirmation?.sentence
                == "Frees 500 bytes. The apps inside it and their data are gone. This cannot be undone.")
    }

    @Test
    func confirm_asksForTheDeletionsOneAfterAnother() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data", "Previews")

        sut.confirm()
        #expect(requests.deletions.map(\.name) == ["Derived data"])
        #expect(sut.namesBeingDeleted == ["Derived data", "Previews"])

        sut.deletionEnded(with: .freed(300))
        #expect(requests.deletions.map(\.name) == ["Derived data", "Previews"])
        #expect(sut.namesBeingDeleted == ["Previews"])
    }

    @Test
    func deletionEnded_addsUpTheRoomEveryDeletionInTheBatchFreed() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data", "Previews")
        sut.confirm()

        sut.deletionEnded(with: .freed(300))
        #expect(sut.uiModel.deletionMessage == nil)

        sut.deletionEnded(with: .freed(200))
        #expect(sut.uiModel.deletionMessage == "500 bytes came back.")
        #expect(sut.shownNames.isEmpty)
    }

    @Test
    func deletionEnded_saysWhatCameBackAndWhatWentWrongInTheSameBatch() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), simulator(taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data", "iPhone 17 (iOS 26.4, 21B507D3)")
        sut.confirm()

        sut.deletionEnded(with: .freed(300))
        sut.deletionEnded(with: .refused(.simulatorIsRunning))

        #expect(sut.uiModel.deletionMessage == "300 bytes came back. The simulator is running.")
        #expect(sut.shownNames == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test
    func deletionEnded_saysNothingWhenTheDeletionFreedNothing() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300)])
        sut.askAboutDeleting(rowsNamed: "Derived data")
        sut.confirm()

        sut.deletionEnded(with: .freed(0))

        #expect(sut.uiModel.deletionMessage == nil)
        #expect(sut.shownNames.isEmpty)
    }

    @Test
    func deletionEnded_takesTheDeletedRowOutOfWhatIsChosen() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data")
        sut.confirm()

        sut.deletionEnded(with: .freed(300))

        #expect(sut.selectedNames.isEmpty)
    }

    @Test
    func measuringEnded_choosesNothingOfWhatTheMeasuringBroughtBack() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300)])
        sut.select(rowsNamed: "Derived data")

        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300)])

        #expect(sut.selectedNames.isEmpty)
    }

    @Test
    func confirm_offersNoDeletionOverWhatIsChosenUntilTheDeletionEnds() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data")

        sut.confirm()
        #expect(sut.uiModel.canDeleteSelection == false)

        sut.deletionEnded(with: .freed(300))
        sut.select(rowsNamed: "Previews")
        #expect(sut.uiModel.canDeleteSelection)
    }

    @Test
    func askAboutDeletingWhatIsChosen_asksOverTheRowsTheDeveloperChose() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.select(rowsNamed: "Derived data")

        sut.askAboutDeletingWhatIsChosen()

        #expect(sut.uiModel.confirmation?.question == "Delete Derived data?")
    }

    @Test
    func askAboutDeleting_asksNothingWhileADeletionIsUnderWay() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 300), folder(named: "Previews", taking: 200)])
        sut.askAboutDeleting(rowsNamed: "Derived data")
        sut.confirm()

        sut.askAboutDeleting(rowsNamed: "Previews")

        #expect(sut.uiModel.confirmation == nil)
        #expect(requests.deletions.map(\.name) == ["Derived data"])
    }
}

private extension LeftoverListViewModelSelectionTests {
    func makeSUT() -> (sut: LeftoverListViewModel, requests: ScreenRequestsSpy) {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return (sut, requests)
    }
}
