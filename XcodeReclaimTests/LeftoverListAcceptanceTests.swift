import AppKit
import Foundation
import Testing
import XcodeReclaim
import XcodeReclaimCore
import XcodeReclaimPresentation
import XcodeReclaimUI

@MainActor
final class LeftoverListAcceptanceTests {
    private var root: XcodeLeftovers?

    @Test func theDeveloperOpensTheAppAndSeesWhatMayBeDeleted() {
        let (screen, machine) = makeSUT()

        screen.model.open()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 0)

        #expect(screen.model.sections.flatMap(\.rows).map(\.name) == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.model.sections.flatMap(\.rows).map(\.size) == ["300 bytes", "200 bytes"])
    }

    @Test func theDeveloperDeletesALeftover() throws {
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 0)

        screen.model.askAboutDeleting(try #require(screen.model.sections.first?.rows.first))
        screen.model.confirm()
        machine.report(.freed(300), from: 0)

        #expect(machine.deletions.map(\.leftover.name) == ["Derived data"])
        #expect(screen.model.sections.flatMap(\.rows).map(\.name) == ["iPhone 17 (iOS 26.4, 21B507D3)"])
    }

    @Test func theDeveloperRefreshesTheList() {
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([derivedData(taking: 300)], from: 0)

        screen.model.refresh()
        machine.deliver([derivedData(taking: 300), aSimulator(taking: 200)], from: 1)

        #expect(machine.measurings == 2)
        #expect(screen.model.sections.flatMap(\.rows).map(\.name) == ["Derived data", "iPhone 17 (iOS 26.4, 21B507D3)"])
        #expect(screen.model.sections.flatMap(\.rows).map(\.size) == ["300 bytes", "200 bytes"])
    }

    @Test func theDeveloperWatchesTheMeasuringWorkThroughTheLeftovers() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        machine.announce("Derived data", from: 0)
        #expect(screen.model.leftoverBeingMeasured == "Derived data")

        machine.announce("Previews", from: 0)
        #expect(screen.model.leftoverBeingMeasured == "Previews")
    }

    @Test func aMeasuringTheScreenHasReplacedDoesNotReachIt() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        screen.model.refresh()
        machine.deliver([derivedData(taking: 27_700_000_000)], from: 0)

        #expect(screen.model.isMeasuring)
        #expect(screen.model.leftoverBeingMeasured == nil)
        #expect(screen.model.sections.isEmpty)
    }

    @Test func anAnnouncementFromAMeasuringTheScreenHasReplacedDoesNotReachIt() {
        let (screen, machine) = makeSUT()
        screen.model.open()

        screen.model.refresh()
        machine.announce("Derived data", from: 0)

        #expect(screen.model.leftoverBeingMeasured == nil)
    }

    @Test func theScreenDoesNotKeepTheCompositionRootAlive() {
        let machine = TheMachineSpy()
        var leftovers: XcodeLeftovers? = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
        weak let stillHeld = leftovers
        let screen = leftovers?.screen

        leftovers = nil

        #expect(stillHeld == nil)
        #expect(screen != nil)
    }

    @Test func theDeveloperOpensTheAppAndItTakesItsPlaceAmongTheRegularApplications() {
        #expect(NSApplication.shared.activationPolicy() == .regular)
        #expect(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") == nil)
    }

    @Test func theDeveloperDeletesACopyOfXcodeTheyNoLongerUse() throws {
        let roomItTook = 4_000_000_000
        let (screen, machine) = makeSUT()
        screen.model.open()
        machine.deliver([aCopyOfXcode(taking: roomItTook), derivedData(taking: 300)], from: 0)

        screen.model.askAboutDeleting(try #require(screen.model.sections.first?.rows.first))
        screen.model.confirm()
        machine.report(.freed(roomItTook), from: 0)

        #expect(machine.deletions.map(\.leftover.name) == ["Xcode 26.2 (17C51) — Applications"])
        #expect(screen.model.sections.flatMap(\.rows).map(\.name) == ["Derived data"])
        #expect(screen.model.whatTheDeletionSaid == "4.0 GB came back.")
    }
}

private extension LeftoverListAcceptanceTests {
    func makeSUT() -> (screen: LeftoverListView, machine: TheMachineSpy) {
        let machine = TheMachineSpy()
        let leftovers = XcodeLeftovers(measuring: machine.measuring, deleting: machine.deleting)
        root = leftovers
        return (leftovers.screen, machine)
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
