import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelSortingTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test
    func measuringEnded_putsTheBiggestFirstUntilTheDeveloperSortsOtherwise() {
        let sut = makeSUT()

        sut.measuringEnded(with: threeFolders)

        #expect(sut.shownNames == ["Derived data", "Caches", "Previews"])
    }

    @Test
    func sort_byNamePutsTheRowsOfEverySectionInNameOrder() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, ascending: true))

        #expect(sut.shownNames == ["Caches", "Derived data", "Previews"])
    }

    @Test
    func sort_byNameDescendingTurnsTheNameOrderAround() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, ascending: false))

        #expect(sut.shownNames == ["Previews", "Derived data", "Caches"])
    }

    @Test
    func sort_bySizeAscendingPutsTheSmallestFirst() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .size, ascending: true))

        #expect(sut.shownNames == ["Previews", "Caches", "Derived data"])
    }

    @Test
    func sort_keepsTheOrderTheMeasuringOfferedForRowsHoldingTheSameRoom() {
        let roomTheyBothTake = 200
        let sut = makeSUT()
        sut.measuringEnded(with: [folder(named: "Previews", taking: roomTheyBothTake), folder(named: "Caches", taking: roomTheyBothTake)])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .size, ascending: true))

        #expect(sut.shownNames == ["Previews", "Caches"])
    }

    @Test
    func sort_sortsInsideEverySectionRatherThanAcrossThem() {
        let sut = makeSUT()
        sut.measuringEnded(with: [folder(named: "Derived data", taking: 100), simulator(taking: 300), simulator(named: "iPad Pro", taking: 200)])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, ascending: true))

        #expect(sut.uiModel.sections.map(\.name) == ["Simulators", "Caches and support files"])
        #expect(sut.shownNames == ["iPad Pro", "iPhone 17 (iOS 26.4, 21B507D3)", "Derived data"])
    }

    @Test
    func sort_byNameReadsTheNumbersInANameTheWayAPersonReadsThem() {
        let sut = makeSUT()
        sut.measuringEnded(with: [
            folder(named: "Device support (iOS 26.4)", taking: 300),
            folder(named: "Device support (iOS 9.0)", taking: 200),
        ])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, ascending: true))

        #expect(sut.shownNames == ["Device support (iOS 9.0)", "Device support (iOS 26.4)"])
    }

    @Test
    func sort_saysWhichColumnTheScreenIsSortedBy() {
        let sut = makeSUT()
        #expect(sut.uiModel.sorting == LeftoverListUIModel.Sorting.biggestFirst)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, ascending: true))

        #expect(sut.uiModel.sorting == LeftoverListUIModel.Sorting(column: .name, ascending: true))
    }
}

private extension LeftoverListViewModelSortingTests {
    var threeFolders: [Leftover] {
        let biggest = 300
        let middling = 200
        let smallest = 100

        return [
            folder(named: "Derived data", taking: biggest),
            folder(named: "Caches", taking: middling),
            folder(named: "Previews", taking: smallest),
        ]
    }

    func makeSUT() -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
