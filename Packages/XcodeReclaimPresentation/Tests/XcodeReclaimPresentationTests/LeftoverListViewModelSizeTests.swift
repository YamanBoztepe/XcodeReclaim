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

    @Test func aSizeIsShownTheWayAPersonReadsIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 28_359_995_392)])

        #expect(sut.sections.flatMap(\.rows).map(\.size) == ["28.4 GB"])
    }

    @Test func aSizeIsShownInTheUnitItsMagnitudeAsksFor() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 323_137_536)])

        #expect(sut.sections.flatMap(\.rows).map(\.size) == ["323.1 MB"])
    }

    @Test func everyMagnitudeIsShownInTheUnitItAsksFor() {
        let sut = makeSUT()
        let magnitudes = [999, 1_000, 999_999, 1_000_000, 999_999_999, 1_000_000_000, 1_000_000_000_000]

        sut.measuringEnded(with: magnitudes.map { ALeftover.folder(named: "taking \($0)", taking: $0) })

        #expect(
            sut.sections.flatMap(\.rows).map(\.size) == [
                "999 bytes", "1.0 KB", "1000.0 KB", "1.0 MB", "1000.0 MB", "1.0 GB", "1.0 TB",
            ])
    }

    @Test func theScreenSaysHowMuchRoomThereIsToReclaim() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 1_000_000_000), ALeftover.folder(named: "Previews", taking: 500_000_000)])

        #expect(sut.roomToReclaim == "1.5 GB")
    }

    @Test func aScreenWithNothingToDeleteHasNothingToReclaim() {
        let sut = makeSUT()
        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 1_000_000_000)])

        sut.measuringEnded(with: [])

        #expect(sut.roomToReclaim == nil)
    }

    @Test func theRoomToReclaimIsWhatTheSectionsSayTheyHold() {
        let roomEachHolds = 1_750_000_000
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: roomEachHolds), ALeftover.simulator(taking: roomEachHolds)])

        #expect(sut.sections.map(\.size) == ["1.8 GB", "1.8 GB"])
        #expect(sut.roomToReclaim == "3.6 GB")
    }
}

private extension LeftoverListViewModelSizeTests {
    func makeSUT() -> LeftoverListViewModel {
        let requests = RequestsFromTheScreen()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
