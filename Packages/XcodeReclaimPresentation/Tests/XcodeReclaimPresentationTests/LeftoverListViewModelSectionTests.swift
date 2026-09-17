import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelSectionTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test("Leftovers are shown in two sections")
    func measuringEnded_showsTheLeftoversInTwoSections() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), simulator(taking: 100)])

        #expect(sut.uiModel.sections.map(\.name) == ["Caches and support files", "Simulators"])
        #expect(sut.uiModel.sections.map { $0.rows.map(\.name) } == [["Derived data"], ["iPhone 17 (iOS 26.4, 21B507D3)"]])
    }

    @Test
    func measuringEnded_showsEveryKindOfLeftoverInTheSectionItBelongsTo() {
        let sut = makeSUT()

        sut.measuringEnded(with: [
            derivedData(taking: 900), interfaceBuilderCache(taking: 800), previews(taking: 700), documentationCache(taking: 600),
            deviceSupport(for: "26.4", taking: 500), simulator(taking: 400), copyOfXcode(taking: 300),
        ])

        #expect(
            sut.uiModel.sections.map { $0.rows.map(\.name) } == [
                ["Derived data", "Interface builder cache", "Previews", "Documentation cache", "Device support (iOS 26.4)"],
                ["iPhone 17 (iOS 26.4, 21B507D3)"],
                ["Xcode 26.2 (17C51) — Applications"],
            ])
    }

    @Test("The section holding the most room is shown first")
    func measuringEnded_showsTheSectionHoldingTheMostRoomFirst() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), simulator(taking: 300)])

        #expect(sut.uiModel.sections.map(\.name) == ["Simulators", "Caches and support files"])
    }

    @Test("A section the measuring found nothing for is not shown")
    func measuringEnded_showsNoSectionTheMeasuringFoundNothingFor() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200)])

        #expect(sut.uiModel.sections.map(\.name) == ["Caches and support files"])
    }

    @Test("A section carries the share of the room it holds")
    func measuringEnded_givesEachSectionTheShareOfTheRoomItHolds() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 300), simulator(taking: 100)])

        #expect(sut.uiModel.sections.map(\.share) == [0.75, 0.25])
    }

    @Test("A section carries the symbol that names it")
    func measuringEnded_givesEachSectionTheSymbolThatNamesIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), simulator(taking: 100)])

        #expect(sut.uiModel.sections.map(\.symbol) == ["folder.fill", "iphone"])
    }

    @Test("A section says how much room it holds")
    func measuringEnded_saysHowMuchRoomEachSectionHolds() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 300), simulator(taking: 100)])

        #expect(sut.uiModel.sections.map(\.size) == ["300 bytes", "100 bytes"])
    }

    @Test
    func measuringEnded_readsASectionsShareFromWhatItsRowsSay() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 1_150_000_000), simulator(taking: 1_150_000_000)])

        #expect(sut.uiModel.sections.map(\.share) == [0.5, 0.5])
    }

    @Test("A section holds what its rows add up to")
    func measuringEnded_saysASectionHoldsWhatItsRowsAddUpTo() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 1_150_000_000), previews(taking: 1_150_000_000)])

        #expect(sut.shownRows.map(\.size) == ["1.2 GB", "1.2 GB"])
        #expect(sut.uiModel.sections.map(\.size) == ["2.4 GB"])
    }

    @Test("The leftover holding the most room is marked wherever it sits")
    func measuringEnded_marksTheLeftoverHoldingTheMostRoomWhereverItSits() {
        let sut = makeSUT()

        sut.measuringEnded(with: [
            derivedData(taking: 300),
            simulator(named: "iPhone 17", taking: 200),
            simulator(named: "iPad Pro", identified: "8FB6EB6C-8E0B-4AD6-9A55-4E0A1C3B2D11", taking: 200),
        ])

        #expect(sut.uiModel.sections.map(\.name) == ["Simulators", "Caches and support files"])
        #expect(sut.shownRows.map(\.holdsTheMostRoom) == [false, false, true])
    }

    @Test("Leftovers holding the same room mark only the one shown first")
    func measuringEnded_marksOnlyTheFirstOfTheLeftoversHoldingTheSameRoom() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), simulator(taking: 200)])

        #expect(sut.shownRows.map(\.holdsTheMostRoom) == [true, false])
    }

    @Test("A screen with one leftover marks nothing")
    func measuringEnded_marksNothingWhenThereIsOneLeftover() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200)])

        #expect(sut.shownRows.map(\.holdsTheMostRoom) == [false])
    }

    @Test("Copies of Xcode are shown in their own section")
    func measuringEnded_showsTheCopiesOfXcodeInTheirOwnSection() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), copyOfXcode(taking: 100)])

        #expect(sut.uiModel.sections.map(\.name) == ["Caches and support files", "Xcode versions"])
        #expect(sut.uiModel.sections.map { $0.rows.map(\.name) } == [["Derived data"], ["Xcode 26.2 (17C51) — Applications"]])
    }

    @Test("The Xcode versions section carries the symbol that names it")
    func measuringEnded_givesTheXcodeVersionsSectionTheSymbolThatNamesIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [derivedData(taking: 200), copyOfXcode(taking: 100)])

        #expect(sut.uiModel.sections.map(\.symbol) == ["folder.fill", "hammer.fill"])
    }
}

private extension LeftoverListViewModelSectionTests {
    func makeSUT() -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
