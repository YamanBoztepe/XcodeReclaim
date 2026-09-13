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

    @Test func anOpenedScreenIsMeasuring() {
        let (sut, _) = makeSUT()

        sut.open()

        #expect(sut.isMeasuring)
        #expect(sut.leftoverBeingMeasured == nil)
    }

    @Test func anOpenedScreenAsksForAMeasuring() {
        let (sut, requests) = makeSUT()

        sut.open()

        #expect(requests.measurings == 1)
    }

    @Test func measuredLeftoversAreShownWithTheirSizes() {
        let roomItTakes = 200
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: roomItTakes)])

        #expect(sut.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
        #expect(sut.sections.flatMap(\.rows).map(\.size) == ["200 bytes"])
        #expect(sut.isMeasuring == false)
    }

    @Test func aMeasuringThatEndsWithNothingSaysThereIsNothingToDelete() {
        let (sut, _) = makeSUT()

        sut.measuringEnded(with: [])

        #expect(sut.nothingToDelete)
    }

    @Test func aScreenStillMeasuringDoesNotSayThereIsNothingToDelete() {
        let (sut, _) = makeSUT()

        sut.open()

        #expect(sut.nothingToDelete == false)
    }

    @Test func aRefreshMeasuresAgain() {
        let (sut, requests) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(taking: 200)])

        sut.refresh()

        #expect(requests.measurings == 1)
        #expect(sut.isMeasuring)
        #expect(sut.leftoverBeingMeasured == nil)
        #expect(sut.sections.isEmpty)
    }

    @Test func aMeasuringScreenSaysWhichLeftoverIsBeingMeasured() {
        let (sut, _) = makeSUT()

        sut.announced("Derived data")
        #expect(sut.leftoverBeingMeasured == "Derived data")

        sut.announced("Previews")
        #expect(sut.leftoverBeingMeasured == "Previews")
    }

    @Test func aScreenThatHasFinishedMeasuringNamesNoLeftoverBeingMeasured() {
        let roomItTakes = 200
        let (sut, _) = makeSUT()
        sut.announced("Derived data")

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: roomItTakes)])

        #expect(sut.sections.flatMap(\.rows).map(\.size) == ["200 bytes"])
        #expect(sut.leftoverBeingMeasured == nil)
    }

    @Test func aRefreshSaysNothingAboutTheDeletionBeforeIt() throws {
        let (sut, _) = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(taking: 200)])
        sut.askAboutDeleting(try #require(sut.sections.first?.rows.first))
        sut.confirm()
        sut.deletionEnded(with: .freed(200))

        sut.refresh()

        #expect(sut.whatTheDeletionSaid == nil)
    }
}

private extension LeftoverListViewModelTests {
    func makeSUT() -> (sut: LeftoverListViewModel, requests: RequestsFromTheScreen) {
        let requests = RequestsFromTheScreen()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return (sut, requests)
    }
}
