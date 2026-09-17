import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelSizeTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test("A size is shown the way a person reads it")
    func measuringEnded_showsASizeTheWayAPersonReadsIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 28_359_995_392)])

        #expect(sut.shownRows.map(\.size) == ["28.4 GB"])
    }

    @Test("A size is shown in the unit its magnitude asks for")
    func measuringEnded_showsASizeInTheUnitItsMagnitudeAsksFor() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 323_137_536)])

        #expect(sut.shownRows.map(\.size) == ["323.1 MB"])
    }

    @Test
    func measuringEnded_showsEveryMagnitudeInTheUnitItAsksFor() {
        let sut = makeSUT()
        let magnitudes = [999, 1_000, 999_999, 1_000_000, 999_999_999, 1_000_000_000, 1_000_000_000_000]

        sut.measuringEnded(with: magnitudes.map { deviceSupport(for: "\($0)", taking: $0) })

        #expect(
            sut.shownRows.map(\.size) == [
                "1.0 TB", "1.0 GB", "1000.0 MB", "1.0 MB", "1000.0 KB", "1.0 KB", "999 bytes",
            ])
    }

    @Test("The screen says how much room there is to reclaim")
    func measuringEnded_saysHowMuchRoomThereIsToReclaim() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 1_000_000_000), previews(taking: 500_000_000)])

        #expect(sut.uiModel.title == "1.5 GB to reclaim")
    }

    @Test("A screen with nothing to delete has nothing to reclaim")
    func measuringEnded_saysNothingAboutReclaimingWhenThereIsNothingToDelete() {
        let sut = makeSUT()
        sut.measuringEnded(with: [derivedData(taking: 1_000_000_000)])

        sut.measuringEnded(with: [])

        #expect(sut.uiModel.title.isEmpty)
    }

    @Test("The room to reclaim is what the sections say they hold")
    func measuringEnded_saysTheRoomToReclaimIsWhatTheSectionsHold() {
        let roomEachHolds = 1_750_000_000
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: roomEachHolds), simulator(taking: roomEachHolds)])

        #expect(sut.uiModel.sections.map(\.size) == ["1.8 GB", "1.8 GB"])
        #expect(sut.uiModel.title == "3.6 GB to reclaim")
    }
}

private extension LeftoverListViewModelSizeTests {
    func makeSUT() -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
