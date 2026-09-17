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

        #expect(sut.shownNames == ["Previews", "Derived data", "Interface builder cache"])
    }

    @Test
    func sort_byNamePutsTheRowsOfEverySectionInNameOrder() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: true))

        #expect(sut.shownNames == ["Derived data", "Interface builder cache", "Previews"])
    }

    @Test
    func sort_byNameDescendingTurnsTheNameOrderAround() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: false))

        #expect(sut.shownNames == ["Previews", "Interface builder cache", "Derived data"])
    }

    @Test
    func sort_bySizeAscendingPutsTheSmallestFirst() {
        let sut = makeSUT()
        sut.measuringEnded(with: threeFolders)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .size, isAscending: true))

        #expect(sut.shownNames == ["Interface builder cache", "Derived data", "Previews"])
    }

    @Test
    func sort_keepsTheOrderTheMeasuringOfferedForRowsHoldingTheSameRoom() {
        let roomTheyBothTake = 200
        let sut = makeSUT()
        sut.measuringEnded(with: [previews(taking: roomTheyBothTake), documentationCache(taking: roomTheyBothTake)])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .size, isAscending: true))

        #expect(sut.shownNames == ["Previews", "Documentation cache"])
    }

    @Test
    func sort_sortsInsideEverySectionRatherThanAcrossThem() {
        let sut = makeSUT()
        sut.measuringEnded(with: [
            derivedData(taking: 100), simulator(taking: 300), simulator(named: "iPad Pro", identified: "8FB6EB6C-8E0B-4AD6-9A55-4E0A1C3B2D11", taking: 200),
        ])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: true))

        #expect(sut.uiModel.sections.map(\.name) == ["Simulators", "Caches and support files"])
        #expect(sut.shownNames == ["iPad Pro (iOS 26.4, 8FB6EB6C)", "iPhone 17 (iOS 26.4, 21B507D3)", "Derived data"])
    }

    @Test
    func sort_byNameReadsTheNumbersInANameTheWayAPersonReadsThem() {
        let sut = makeSUT()
        sut.measuringEnded(with: [
            deviceSupport(for: "26.4", taking: 300),
            deviceSupport(for: "9.0", taking: 200),
        ])

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: true))

        #expect(sut.shownNames == ["Device support (iOS 9.0)", "Device support (iOS 26.4)"])
    }

    @Test
    func sort_saysWhichColumnTheScreenIsSortedBy() {
        let sut = makeSUT()
        #expect(sut.uiModel.sorting == LeftoverListUIModel.Sorting.biggestFirst)

        sut.sort(by: LeftoverListUIModel.Sorting(column: .name, isAscending: true))

        #expect(sut.uiModel.sorting == LeftoverListUIModel.Sorting(column: .name, isAscending: true))
    }
}

private extension LeftoverListViewModelSortingTests {
    var threeFolders: [Leftover] {
        let biggest = 300
        let middling = 200
        let smallest = 100

        return [
            previews(taking: biggest),
            derivedData(taking: middling),
            interfaceBuilderCache(taking: smallest),
        ]
    }

    func makeSUT() -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
