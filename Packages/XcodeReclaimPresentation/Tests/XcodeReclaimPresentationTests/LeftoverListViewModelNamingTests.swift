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

    @Test("A simulator runtime is named by its version, its build and the day it was last used")
    func measuringEnded_namesARuntimeByItsVersionItsBuildAndTheDayItWasLastUsed() {
        let sut = makeSUT()

        sut.measuringEnded(with: [runtime(named: "iOS 26.2", build: "23C54", lastUsed: moment("2026-10-01T12:17:46Z"), taking: 200)])

        #expect(sut.shownNames == ["iOS 26.2 (23C54) — last used 1 Oct 2026"])
    }

    @Test("A simulator runtime never used says so")
    func measuringEnded_saysASimulatorRuntimeWasNeverUsed() {
        let sut = makeSUT()

        sut.measuringEnded(with: [runtime(named: "watchOS 11.1", build: "22R581", lastUsed: nil, taking: 200)])

        #expect(sut.shownNames == ["watchOS 11.1 (22R581) — never used"])
    }

    @Test("An archive is named by its app, its version, its build and the day it was made")
    func measuringEnded_namesAnArchiveByItsAppItsVersionItsBuildAndTheDayItWasMade() {
        let sut = makeSUT()

        sut.measuringEnded(with: [archive(named: "Communite Test", version: "2.0.0", build: "676", created: moment("2026-09-16T15:22:46Z"), taking: 200)])

        #expect(sut.shownNames == ["Communite Test 2.0.0 (676) — 16 Sep 2026"])
    }

    @Test(
        "An archive is named by what its record carries",
        arguments: [
            (nil, nil, nil, "Communite Test 676"),
            ("2.0.0", nil, nil, "Communite Test 676 2.0.0"),
            (nil, "676", nil, "Communite Test 676 (676)"),
            (nil, nil, "2026-09-16T15:22:46Z", "Communite Test 676 — 16 Sep 2026"),
        ])
    func measuringEnded_namesAnArchiveByWhatItsRecordCarries(version: String?, build: String?, created: String?, name: String) {
        let sut = makeSUT()

        sut.measuringEnded(with: [archive(named: "Communite Test 676", version: version, build: build, created: created.map(moment), taking: 200)])

        #expect(sut.shownNames == [name])
    }

    @Test("A day is written in the developer's time zone")
    func measuringEnded_writesTheDayInTheDevelopersTimeZone() throws {
        let istanbul = try #require(TimeZone(identifier: "Europe/Istanbul"))
        let sut = makeSUT(in: istanbul)

        sut.measuringEnded(with: [runtime(named: "iOS 26.2", build: "23C54", lastUsed: moment("2026-10-01T22:30:00Z"), taking: 200)])

        #expect(sut.shownNames == ["iOS 26.2 (23C54) — last used 2 Oct 2026"])
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
            (runtime(taking: 200), "Frees 200 bytes. Its simulators do not start until it is downloaded again. This cannot be undone."),
            (swiftPackageCache(taking: 200), "Frees 200 bytes. The packages are downloaded again. This cannot be undone."),
            (toolchain(taking: 200), "Frees 200 bytes. Anything that builds with it needs it installed again. This cannot be undone."),
            (
                archive(taking: 200),
                "Frees 200 bytes. Its debug symbols go with it: crashes from that build can be read only if the symbols were uploaded "
                    + "somewhere else. This cannot be undone."
            ),
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

    @Test("A row says under its name only why it cannot be deleted")
    func measuringEnded_saysUnderARowsNameOnlyWhyItCannotBeDeleted() {
        let sut = makeSUT()

        sut.measuringEnded(with: [
            deviceSupport(for: "26.4", taking: 300),
            simulator(taking: 200, refusedFor: .simulatorIsRunning),
        ])

        #expect(sut.shownRows.map(\.refusal) == [nil, "The simulator is running."])
    }
}

private extension LeftoverListViewModelNamingTests {
    func makeSUT(in timeZone: TimeZone = .gmt) -> LeftoverListViewModel {
        let requests = ScreenRequestsSpy()
        let sut = LeftoverListViewModel(measure: requests.measure, delete: requests.delete, calendar: calendar(in: timeZone))
        released.append { [weak sut] in sut == nil }
        return sut
    }
}
