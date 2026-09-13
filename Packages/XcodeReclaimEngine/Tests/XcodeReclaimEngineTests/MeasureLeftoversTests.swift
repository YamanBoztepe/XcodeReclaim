import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversTests {
    @Test func aMeasuredFolderDeliversDerivedDataWithTheRoomItTakes() {
        let roomItTakes = 200
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test func aLeftoverTakingNoRoomIsNotDelivered() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 0
        disk.sizes[DeveloperFolder.derivedData] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data"])
    }

    @Test func aFolderHoldingNothingToDeleteDeliversNoLeftover() {
        let (sut, disk, _, _) = makeSUT()

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.isEmpty)
    }

    @Test func theOtherLeftoversAreDeliveredEvenWhenTheSimulatorsCannotBeListed() {
        let roomItTakes = 200
        let (sut, disk, simulators, _) = makeSUT()
        simulators.report = .failure(TheSimulatorsCannotBeListed())
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test func everyOfferedLeftoverIsDeliveredWhenItTakesRoom() {
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

    @Test func twoLeftoversOfEqualSizeKeepTheOrderTheyWereOfferedIn() {
        let roomEachTakes = 200
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = roomEachTakes
        disk.sizes[DeveloperFolder.previews] = roomEachTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data", "Previews"])
    }

    @Test func theLeftoversAreDeliveredBiggestFirst() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 50
        disk.sizes[DeveloperFolder.previews] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Previews", "Derived data"])
    }

    @Test func aLeftoverThatCostsSomethingIsDeliveredWithItsCost() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.first?.cost != nil)
    }

    @Test func aLeftoverThatCostsNothingIsDeliveredWithoutACost() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.previews] = 200
        disk.sizes[DeveloperFolder.derivedData] = 120

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.last?.cost == nil)
    }

    @Test func aLeftoverTooSmallToBeWorthDeletingIsNotDelivered() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting - 1
        disk.sizes[DeveloperFolder.previews] = worthDeleting

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Previews"])
    }

    @Test func aLeftoverExactlyAtTheThresholdIsDelivered() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: worthDeleting, place: .folder(DeveloperFolder.derivedData))])
    }

    @Test func aLeftoverWithMoreRoomThanTheThresholdIsDelivered() {
        let worthDeleting = 100_000_000
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting + 1

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received == [Leftover(name: "Derived data", bytes: worthDeleting + 1, place: .folder(DeveloperFolder.derivedData))])
    }
}

private struct TheSimulatorsCannotBeListed: Error {}

private extension MeasureLeftoversTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: DiskSpy, simulators: SimulatorServiceSpy, copies: XcodeCopiesStub) {
        let disk = DiskSpy()
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
