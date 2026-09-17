import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test("An opened screen is measuring")
    func open_isMeasuringNamingNothing() {
        let (sut, _) = makeSUT()

        sut.open()

        #expect(sut.uiModel.isMeasuring)
        #expect(sut.uiModel.leftoverBeingMeasured == nil)
    }

    @Test
    func open_asksForAMeasuring() {
        let (sut, requests) = makeSUT()

        sut.open()

        #expect(requests.measurings == 1)
    }

    @Test("Measured leftovers are shown with their sizes")
    func measuringEnded_showsTheMeasuredLeftoversWithTheirSizes() {
        let roomItTakes = 200
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: roomItTakes)])

        #expect(sut.shownNames == ["Derived data"])
        #expect(sut.shownRows.map(\.size) == ["200 bytes"])
        #expect(sut.uiModel.isMeasuring == false)
    }

    @Test("A measuring that ends with nothing says there is nothing to delete")
    func measuringEnded_saysThereIsNothingToDeleteWhenItFoundNothing() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [])

        #expect(sut.uiModel.nothingToDelete)
    }

    @Test
    func refresh_doesNotSayThereIsNothingToDeleteWhileMeasuringAgain() {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [])

        sut.refresh()

        #expect(sut.uiModel.nothingToDelete == false)
    }

    @Test("A refresh measures again")
    func refresh_measuresAgainNamingNothing() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [derivedData(taking: 200)])

        sut.refresh()

        #expect(requests.measurings == 1)
        #expect(sut.uiModel.isMeasuring)
        #expect(sut.uiModel.leftoverBeingMeasured == nil)
        #expect(sut.uiModel.sections.isEmpty)
    }

    @Test("A measuring screen says which leftover is being measured")
    func announced_saysWhichLeftoverIsBeingMeasured() {
        let (sut, _) = makeSUT()

        sut.announced("Derived data")
        #expect(sut.uiModel.leftoverBeingMeasured == "Derived data")

        sut.announced("Previews")
        #expect(sut.uiModel.leftoverBeingMeasured == "Previews")
    }

    @Test("A screen that has finished measuring names no leftover being measured")
    func measuringEnded_namesNoLeftoverBeingMeasured() {
        let roomItTakes = 200
        let (sut, _) = makeSUT()
        sut.announced("Derived data")

        sut.measuringEnded(with: [derivedData(taking: roomItTakes)])

        #expect(sut.shownRows.map(\.size) == ["200 bytes"])
        #expect(sut.uiModel.leftoverBeingMeasured == nil)
    }

    @Test
    func open_saysTheWindowIsMeasuringUntilTheMeasuringEnds() {
        let (sut, _) = makeSUT()

        #expect(sut.uiModel.title == "Measuring…")

        sut.measuringEnded(with: [derivedData(taking: 300)])

        #expect(sut.uiModel.title == "300 bytes to reclaim")
    }

    @Test("A refresh says nothing about the deletion before it")
    func refresh_saysNothingAboutTheDeletionBeforeIt() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [derivedData(taking: 200)])
        sut.askAboutDeleting(try #require(sut.uiModel.sections.first?.rows.first))
        sut.confirm()
        sut.deletionEnded(with: .freed(200))

        sut.refresh()

        #expect(sut.uiModel.deletionMessage == nil)
    }
}

private extension LeftoverListViewModelTests {
    func makeSUT() -> (sut: LeftoverListViewModel, requests: ScreenRequestsSpy) {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return (sut, requests)
    }
}
