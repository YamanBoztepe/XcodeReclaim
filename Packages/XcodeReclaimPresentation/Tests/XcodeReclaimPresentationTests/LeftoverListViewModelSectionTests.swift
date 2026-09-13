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

    @Test func leftoversAreShownInTwoSections() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.simulator(taking: 100)])

        #expect(sut.sections.map(\.name) == ["Caches and support files", "Simulators"])
        #expect(sut.sections.map { $0.rows.map(\.name) } == [["Derived data"], ["iPhone 17 (iOS 26.4, 21B507D3)"]])
    }

    @Test func theSectionHoldingTheMostRoomIsShownFirst() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.simulator(taking: 300)])

        #expect(sut.sections.map(\.name) == ["Simulators", "Caches and support files"])
    }

    @Test func aSectionTheMeasuringFoundNothingForIsNotShown() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        #expect(sut.sections.map(\.name) == ["Caches and support files"])
    }

    @Test func aSectionCarriesTheShareOfTheRoomItHolds() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.simulator(taking: 100)])

        #expect(sut.sections.map(\.share) == [0.75, 0.25])
    }

    @Test func aSectionCarriesTheSymbolThatNamesIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.simulator(taking: 100)])

        #expect(sut.sections.map(\.symbol) == ["folder.fill", "iphone"])
    }

    @Test func aSectionSaysHowMuchRoomItHolds() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 300), ALeftover.simulator(taking: 100)])

        #expect(sut.sections.map(\.size) == ["300 bytes", "100 bytes"])
    }

    @Test func theLeftoverHoldingTheMostRoomIsMarkedWhereverItSits() {
        let sut = makeSUT()

        sut.measuringEnded(with: [
            ALeftover.folder(named: "Derived data", taking: 300),
            ALeftover.simulator(named: "iPhone 17 (iOS 26.4, 21B507D3)", taking: 200),
            ALeftover.simulator(named: "iPad Pro (iOS 26.4, 8FB6EB6C)", taking: 200),
        ])

        #expect(sut.sections.map(\.name) == ["Simulators", "Caches and support files"])
        #expect(sut.sections.flatMap(\.rows).map(\.holdsTheMostRoom) == [false, false, true])
    }

    @Test func leftoversHoldingTheSameRoomMarkOnlyTheOneShownFirst() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.simulator(taking: 200)])

        #expect(sut.sections.flatMap(\.rows).map(\.holdsTheMostRoom) == [true, false])
    }

    @Test func aScreenWithOneLeftoverMarksNothing() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200)])

        #expect(sut.sections.flatMap(\.rows).map(\.holdsTheMostRoom) == [false])
    }

    @Test func copiesOfXcodeAreShownInTheirOwnSection() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.copyOfXcode(taking: 100)])

        #expect(sut.sections.map(\.name) == ["Caches and support files", "Xcode versions"])
        #expect(sut.sections.map { $0.rows.map(\.name) } == [["Derived data"], ["Xcode 26.2 (17C51) — Applications"]])
    }

    @Test func theXcodeVersionsSectionCarriesTheSymbolThatNamesIt() {
        let sut = makeSUT()

        sut.measuringEnded(with: [ALeftover.folder(named: "Derived data", taking: 200), ALeftover.copyOfXcode(taking: 100)])

        #expect(sut.sections.map(\.symbol) == ["folder.fill", "hammer.fill"])
    }
}

private extension LeftoverListViewModelSectionTests {
    func makeSUT() -> LeftoverListViewModel {
        let requests = RequestsFromTheScreen()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
