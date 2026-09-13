import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversSourceBySourceTests {
    @Test
    func measureOne_deliversOnlyWhatTheSourceAskedForHolds() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 200
        disk.sizes[DeveloperFolder.previews] = 300

        let received = sut.leftovers(of: .derivedData, announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data"])
    }

    @Test
    func measureOne_announcesOnlyTheSourceAskedFor() {
        let (sut, disk, _, _) = makeSUT()

        _ = sut.leftovers(of: .previews, announcing: disk.announce)

        #expect(disk.announcements == ["Previews"])
    }

    @Test
    func measureOne_deliversALeftoverTooSmallForTheWholeMeasuring() {
        let worthDeleting = 100
        let (sut, disk, _, _) = makeSUT(worthDeleting: worthDeleting)
        disk.sizes[DeveloperFolder.derivedData] = worthDeleting - 1

        #expect(sut.leftovers(of: .derivedData, announcing: disk.announce).map(\.name) == ["Derived data"])
        #expect(sut.leftovers(announcing: disk.announce).isEmpty)
    }

    @Test
    func measureEverySource_deliversWhatTheSourcesFoundBiggestFirst() {
        let (sut, _, _, _) = makeSUT()

        let received = sut.leftovers(from: [[aLeftover(named: "Previews", taking: 200)], [aLeftover(named: "Derived data", taking: 300)]])

        #expect(received.map(\.name) == ["Derived data", "Previews"])
    }

    @Test
    func measureEverySource_keepsTheOrderTheSourcesWereGivenInForEqualSizes() {
        let roomTheyBothTake = 200
        let (sut, _, _, _) = makeSUT()

        let received = sut.leftovers(from: [
            [aLeftover(named: "Derived data", taking: roomTheyBothTake)],
            [aLeftover(named: "Previews", taking: roomTheyBothTake)],
        ])

        #expect(received.map(\.name) == ["Derived data", "Previews"])
    }

    @Test
    func measureEverySource_deliversNothingASourceFoundTooSmallToBeWorthDeleting() {
        let worthDeleting = 100
        let (sut, _, _, _) = makeSUT(worthDeleting: worthDeleting)

        let received = sut.leftovers(from: [
            [aLeftover(named: "Derived data", taking: worthDeleting - 1)],
            [aLeftover(named: "Previews", taking: worthDeleting)],
        ])

        #expect(received.map(\.name) == ["Previews"])
    }
}

private extension MeasureLeftoversSourceBySourceTests {
    func aLeftover(named name: String, taking bytes: Int) -> Leftover {
        Leftover(name: name, bytes: bytes, place: .folder(DeveloperFolder.root.appending(path: name)))
    }

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
