import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimPresentation

final class LeftoverListViewModelNamingTests {
    private var released: [() -> Bool] = []

    deinit {
        for isReleased in released {
            #expect(isReleased(), "the view model was not released when the test ended")
        }
    }

    @Test("The folders are named for what they hold")
    func measuringEnded_namesTheFoldersForWhatTheyHold() {
        let sut = makeSUT()

        sut.measuringEnded(with: [
            derivedData(taking: 400), interfaceBuilderCache(taking: 300), previews(taking: 200), documentationCache(taking: 100),
        ])

        #expect(sut.shownNames == ["Derived data", "Interface builder cache", "Previews", "Documentation cache"])
    }

    @Test("Device support is named by the system version it holds")
    func measuringEnded_namesDeviceSupportByTheSystemVersionItHolds() {
        let sut = makeSUT()

        sut.measuringEnded(with: [deviceSupport(for: "26.5.2", taking: 200)])

        #expect(sut.shownNames == ["Device support (iOS 26.5.2)"])
    }

    @Test("Device support with no system version is named by its folder")
    func measuringEnded_namesDeviceSupportWithNoSystemVersionByItsFolder() {
        let sut = makeSUT()

        sut.measuringEnded(with: [deviceSupport(inFolderNamed: "a folder nobody can parse", taking: 200)])

        #expect(sut.shownNames == ["Device support (a folder nobody can parse)"])
    }

    @Test("A simulator is named with its runtime and the start of its device identifier")
    func measuringEnded_namesASimulatorWithItsRuntimeAndTheStartOfItsDeviceIdentifier() {
        let sut = makeSUT()

        sut.measuringEnded(with: [simulator(named: "iPhone 16 Pro", on: "iOS 18.1", identified: "21B507D3-909E-465B-957C-4B370278399F", taking: 200)])

        #expect(sut.shownNames == ["iPhone 16 Pro (iOS 18.1, 21B507D3)"])
    }

    @Test("A copy of Xcode is named by its version, its build and where it sits")
    func measuringEnded_namesACopyByItsVersionItsBuildAndWhereItSits() {
        let sut = makeSUT()

        sut.measuringEnded(with: [copyOfXcode(carrying: Leftover.XcodeVersion(number: "26.2", build: "17C51"), sittingIn: "Applications", taking: 200)])

        #expect(sut.shownNames == ["Xcode 26.2 (17C51) — Applications"])
    }

    @Test("A copy of Xcode carrying no version is named by where it sits")
    func measuringEnded_namesACopyCarryingNoVersionByWhereItSits() {
        let sut = makeSUT()

        sut.measuringEnded(with: [copyOfXcode(carrying: nil, sittingIn: "Desktop", taking: 200)])

        #expect(sut.shownNames == ["Xcode — Desktop"])
    }

    @Test("Two copies of one version are told apart by where they sit")
    func measuringEnded_tellsTwoCopiesOfOneVersionApartByWhereTheySit() {
        let version = Leftover.XcodeVersion(number: "26.2", build: "17C51")
        let sut = makeSUT()

        sut.measuringEnded(with: [
            copyOfXcode(carrying: version, sittingIn: "Applications", taking: 300), copyOfXcode(carrying: version, sittingIn: "Desktop", taking: 200),
        ])

        #expect(sut.shownNames == ["Xcode 26.2 (17C51) — Applications", "Xcode 26.2 (17C51) — Desktop"])
    }

    @Test(
        "A confirmation says what deleting each kind of leftover costs",
        arguments: [
            (derivedData(taking: 200), "Frees 200 bytes. This cannot be undone."),
            (interfaceBuilderCache(taking: 200), "Frees 200 bytes. This cannot be undone."),
            (previews(taking: 200), "Frees 200 bytes. The previews are built again. This cannot be undone."),
            (documentationCache(taking: 200), "Frees 200 bytes. The documentation is downloaded again. This cannot be undone."),
            (
                deviceSupport(for: "26.4", taking: 200),
                "Frees 200 bytes. The symbols are put back the next time that device is plugged in. This cannot be undone."
            ),
            (simulator(taking: 200), "Frees 200 bytes. The apps inside it and their data are gone. This cannot be undone."),
            (copyOfXcode(taking: 200), "Frees 200 bytes. That version has to be downloaded again. This cannot be undone."),
        ])
    func askAboutDeleting_saysWhatDeletingEachKindOfLeftoverCosts(leftover: Leftover, sentence: String) throws {
        let sut = makeSUT()
        sut.measuringEnded(with: [leftover])

        sut.askAboutDeleting(try #require(sut.shownRows.first))

        #expect(sut.uiModel.confirmation?.sentence == sentence)
    }

    @Test("A copy of Xcode that cannot be removed where it stands says its bundle stays")
    func askAboutDeleting_saysTheBundleOfACopyThatCannotBeRemovedWhereItStandsStays() throws {
        let whatItCosts = "That version has to be downloaded again, and the empty bundle stays where it is because removing it needs an administrator."
        let sut = makeSUT()
        sut.measuringEnded(with: [copyOfXcode(canBeRemovedWhereItStands: false, taking: 200)])

        sut.askAboutDeleting(try #require(sut.shownRows.first))

        #expect(sut.uiModel.confirmation?.sentence == "Frees 200 bytes. \(whatItCosts) This cannot be undone.")
    }
}

private extension LeftoverListViewModelNamingTests {
    func makeSUT() -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete)
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
