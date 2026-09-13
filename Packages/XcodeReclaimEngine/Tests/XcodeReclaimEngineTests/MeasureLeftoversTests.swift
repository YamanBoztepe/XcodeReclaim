import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversTests {
    @Test("A measured folder delivers derived data with the room it takes")
    func measure_deliversDerivedDataWithTheRoomItTakes() {
        let roomItTakes = 200
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test("A leftover taking no room is not delivered")
    func measure_doesNotDeliverALeftoverTakingNoRoom() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 0
        disk.sizes[DeveloperFolder.derivedData] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data"])
    }

    @Test("A folder holding nothing to delete delivers no leftover")
    func measure_deliversNoLeftoverFromAFolderHoldingNothingToDelete() {
        let (sut, disk, _, _) = makeSUT()

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.isEmpty)
    }

    @Test("The other leftovers are delivered even when the simulators cannot be listed")
    func measure_deliversTheOtherLeftoversWhenTheSimulatorsCannotBeListed() {
        let roomItTakes = 200
        let (sut, disk, simulators, _) = makeSUT()
        simulators.report = .failure(TheSimulatorsCannotBeListed())
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test("Every offered leftover is delivered when it takes room")
    func measure_deliversEveryOfferedLeftoverThatTakesRoom() {
        let roomEachTakes = 100
        let (sut, disk, _, _) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(holding: "26.4")
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        for folder in DeveloperFolder.everythingOffered + [symbols] {
            disk.sizes[folder] = roomEachTakes
        }

        let received = sut.leftovers(announcing: disk.announce)

        #expect(
            received == [
                Leftover(name: "Derived data", bytes: roomEachTakes, place: .folder(DeveloperFolder.derivedData), cost: nil),
                Leftover(name: "Interface builder cache", bytes: roomEachTakes, place: .folder(DeveloperFolder.interfaceBuilderCache), cost: nil),
                Leftover(name: "Previews", bytes: roomEachTakes, place: .folder(DeveloperFolder.previews), cost: "the previews are built again"),
                Leftover(
                    name: "Documentation cache",
                    bytes: roomEachTakes,
                    place: .folder(DeveloperFolder.documentationCache),
                    cost: "the documentation is downloaded again"),
                Leftover(
                    name: "Device support (iOS 26.4)",
                    bytes: roomEachTakes,
                    place: .folder(symbols),
                    cost: "the symbols are put back the next time that device is plugged in"),
            ])
    }

    @Test("Two leftovers of equal size keep the order they were offered in")
    func measure_keepsTheOfferedOrderForLeftoversOfEqualSize() {
        let roomEachTakes = 200
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = roomEachTakes
        disk.sizes[DeveloperFolder.previews] = roomEachTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data", "Previews"])
    }

    @Test("The leftovers are delivered biggest first")
    func measure_deliversTheLeftoversBiggestFirst() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 50
        disk.sizes[DeveloperFolder.previews] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Previews", "Derived data"])
    }

    @Test("A leftover that costs something is delivered with its cost")
    func measure_deliversALeftoverThatCostsSomethingWithItsCost() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.first?.cost != nil)
    }

    @Test("A leftover that costs nothing is delivered without a cost")
    func measure_deliversALeftoverThatCostsNothingWithoutACost() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 200
        disk.sizes[DeveloperFolder.derivedData] = 120

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.last?.cost == nil)
    }

    @Test("A leftover too small to be worth deleting is not delivered")
    func measure_doesNotDeliverALeftoverTooSmallToBeWorthDeleting() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting - 1
        disk.sizes[DeveloperFolder.previews] = worthDeleting

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Previews"])
    }

    @Test("A leftover exactly at the threshold is delivered")
    func measure_deliversALeftoverExactlyAtTheThreshold() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: worthDeleting, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test
    func measure_deliversALeftoverWithMoreRoomThanTheThreshold() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting + 1

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: worthDeleting + 1, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test
    func measureOne_deliversALeftoverTheWholeMeasuringWouldFindTooSmall() {
        let worthDeleting = 100
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting - 1

        #expect(sut.leftovers(of: .derivedData, announcing: disk.announce).map(\.name) == ["Derived data"])
        #expect(sut.leftovers(announcing: disk.announce).isEmpty)
    }
}

private struct TheSimulatorsCannotBeListed: Error {}

private extension MeasureLeftoversTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: WorldSpy, simulators: SimulatorServiceSpy, copies: XcodeCopiesStub) {
        let disk = WorldSpy()
        let simulators = SimulatorServiceSpy()
        let copies = XcodeCopiesStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: simulators,
            xcodeCopies: copies,
            worthDeleting: worthDeleting)
        return (sut, disk, simulators, copies)
    }
}
