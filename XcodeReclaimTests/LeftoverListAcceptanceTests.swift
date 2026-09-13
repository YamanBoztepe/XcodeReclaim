import AppKit
import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation

@MainActor
struct LeftoverListAcceptanceTests {
    @Test("The developer opens the app and sees what may be deleted")
    func open_showsEveryLeftoverWithItsSize() {
        let (screen, machine) = makeSUT()

        screen.model.open()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 0)

        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.size) == ["300 bytes", "200 bytes"])
    }

    @Test("The developer deletes a leftover")
    func confirm_takesTheDeletedLeftoverOffTheScreen() throws {
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 0)

        screen.model.askAboutDeleting(try #require(screen.model.uiModel.sections.first?.rows.first))
        screen.model.confirm()
        machine.report(.freed(300), from: 0)

        #expect(machine.deletions.map(\.name) == ["Derived data"])
        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test("The developer refreshes the list")
    func refresh_showsEveryLeftoverTheSecondMeasuringFound() {
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([derivedData(taking: 300)], from: 0)

        screen.model.refresh()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 1)

        #expect(machine.measurings == 2)
        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.size) == ["300 bytes", "200 bytes"])
    }

    @Test("The developer watches the measuring work through the leftovers")
    func open_namesEachLeftoverAsTheMeasuringReachesIt() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        machine.announce("Derived data", from: 0)
        #expect(screen.model.uiModel.leftoverBeingMeasured == "Derived data")

        machine.announce("Previews", from: 0)
        #expect(screen.model.uiModel.leftoverBeingMeasured == "Previews")
    }

    @Test("A measuring the screen has replaced does not reach it")
    func refresh_dropsWhatAReplacedMeasuringDelivers() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        screen.model.refresh()
        machine.deliver([derivedData(taking: 27_700_000_000)], from: 0)

        #expect(screen.model.uiModel.isMeasuring)
        #expect(screen.model.uiModel.leftoverBeingMeasured == nil)
        #expect(screen.model.uiModel.sections.isEmpty)
    }

    @Test func refresh_dropsWhatAReplacedMeasuringAnnounces() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        screen.model.refresh()
        machine.announce("Derived data", from: 0)

        #expect(screen.model.uiModel.leftoverBeingMeasured == nil)
    }

    @Test func screen_doesNotKeepItsViewModelAliveOnceTheScreenIsGone() {
        let machine = TheMachineSpy()
        var screen: LeftoverListContainerView? = LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting)
        weak let model = screen?.model

        screen = nil

        #expect(model == nil)
    }

    @Test("The developer opens the app and it takes its place among the regular applications")
    func open_takesItsPlaceAmongTheRegularApplications() {
        #expect(NSApplication.shared.activationPolicy() == .regular)
        #expect(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") == nil)
    }

    @Test("The developer deletes a copy of Xcode they no longer use")
    func confirm_takesTheDeletedCopyOfXcodeOffTheScreenAndSaysWhatCameBack() throws {
        let roomItTook = 4_000_000_000
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([aCopyOfXcode(taking: roomItTook), derivedData(taking: 300)], from: 0)

        screen.model.askAboutDeleting(try #require(screen.model.uiModel.sections.first?.rows.first))
        screen.model.confirm()
        machine.report(.freed(roomItTook), from: 0)

        #expect(machine.deletions.map(\.name) == ["Xcode 26.2 (17C51) — Applications"])
        #expect(screen.model.uiModel.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
        #expect(screen.model.uiModel.whatTheDeletionSaid == "4.0 GB came back.")
    }
}

private extension LeftoverListAcceptanceTests {
    func makeSUT() -> (screen: LeftoverListContainerView, machine: TheMachineSpy) {
        let machine = TheMachineSpy()
        return (LeftoverListUIComposer.screen(measuring: machine.measuring, deleting: machine.deleting), machine)
    }

    func derivedData(taking bytes: Int) -> Leftover {
        Leftover(name: "Derived data", bytes: bytes, place: .folder(URL(filePath: "/developer/Xcode/DerivedData")))
    }

    func aSimulator(taking bytes: Int) -> Leftover {
        Leftover(
            name: "iPhone 17 (iOS 26.4, 21B507D3)",
            bytes: bytes,
            place: .simulator("21B507D3-909E-465B-957C-4B370278399F"),
            cost: "the apps inside it and their data are gone")
    }

    func aCopyOfXcode(taking bytes: Int) -> Leftover {
        Leftover(
            name: "Xcode 26.2 (17C51) — Applications",
            bytes: bytes,
            place: .xcodeCopy(URL(filePath: "/Applications/Xcode 26.2.app")),
            cost: "that version has to be downloaded again")
    }
}
