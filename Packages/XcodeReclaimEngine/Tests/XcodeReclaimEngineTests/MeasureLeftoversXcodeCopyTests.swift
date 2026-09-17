import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversXcodeCopyTests {
    @Test("Every copy of Xcode the search reports is delivered with the room it takes")
    func measure_deliversEveryCopyTheSearchReportsWithTheRoomItTakes() {
        let roomTheFirstTakes = 4_000_000_000
        let roomTheSecondTakes = 3_000_000_000
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(sittingIn: "Applications", taking: roomTheFirstTakes), copy(sittingIn: "Desktop", taking: roomTheSecondTakes)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.bytes) == [roomTheFirstTakes, roomTheSecondTakes])
    }

    @Test("A copy of Xcode is delivered with its version and its build")
    func measure_deliversACopyWithItsVersionAndItsBuild() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: XcodeCopy.Version(number: "26.2", build: "17C51"))]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(
            received.map(\.kind) == [.xcodeCopy(version: Leftover.XcodeVersion(number: "26.2", build: "17C51"), canBeRemovedWhereItStands: true)])
    }

    @Test("A copy of Xcode carrying no version is delivered without one")
    func measure_deliversACopyCarryingNoVersionWithoutOne() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: nil)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.kind) == [.xcodeCopy(version: nil, canBeRemovedWhereItStands: true)])
    }

    @Test("A copy of Xcode that is open is delivered as open")
    func measure_deliversAnOpenCopyAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByCommandLineTools: false)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test("The copy the command line tools point at is delivered as the one they point at")
    func measure_deliversThePointedAtCopyAsTheOneTheToolsPointAt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByCommandLineTools: true)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.refusal) == [.commandLineToolsPointAtIt])
    }

    @Test("A copy of Xcode that is both open and pointed at is delivered as open")
    func measure_deliversACopyThatIsBothOpenAndPointedAtAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByCommandLineTools: true)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test
    func measure_deliversACopyNeitherOpenNorPointedAtWithNothingRefusingIt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByCommandLineTools: false)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil])
    }

    @Test("A copy of Xcode sitting where the developer cannot write is delivered as not removable where it stands")
    func measure_deliversACopyThatCannotBeRemovedWhereItStandsAsSuch() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: XcodeCopy.Version(number: "26.2", build: "17C51"), canBeRemoved: false)]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(
            received.map(\.kind) == [.xcodeCopy(version: Leftover.XcodeVersion(number: "26.2", build: "17C51"), canBeRemovedWhereItStands: false)])
    }

    @Test
    func measure_deliversACopyWhereTheSearchFoundIt() {
        let (sut, disk, copies) = makeSUT()
        let found = copy(sittingIn: "Applications")
        copies.reported = [found]

        let received = sut.leftovers(measuring: [.copiesOfXcode], announcing: disk.announce)

        #expect(received.map(\.place) == [.xcodeCopy(found.path)])
    }
}

private extension MeasureLeftoversXcodeCopyTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: WorldSpy, copies: XcodeCopyLoaderStub) {
        let disk = WorldSpy()
        let copies = XcodeCopyLoaderStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            xcodeCopyLoader: copies,
            worthDeleting: worthDeleting)
        return (sut, disk, copies)
    }

    func copy(
        carrying version: XcodeCopy.Version? = XcodeCopy.Version(number: "26.4.1", build: "17E201"),
        sittingIn folder: String = "Applications",
        taking bytes: Int = 200,
        isOpen: Bool = false,
        isPointedAtByCommandLineTools: Bool = false,
        canBeRemoved: Bool = true
    ) -> XcodeCopy {
        XcodeCopy(
            path: URL(fileURLWithPath: "/\(folder)/Xcode.app"),
            version: version,
            bytes: bytes,
            isOpen: isOpen,
            isPointedAtByCommandLineTools: isPointedAtByCommandLineTools,
            canBeRemoved: canBeRemoved)
    }
}
