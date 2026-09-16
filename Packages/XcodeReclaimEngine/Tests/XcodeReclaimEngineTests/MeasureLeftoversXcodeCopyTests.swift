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

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.bytes) == [roomTheFirstTakes, roomTheSecondTakes])
    }

    @Test("A copy of Xcode is named by its version, its build and where it sits")
    func measure_namesACopyByItsVersionItsBuildAndWhereItSits() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: XcodeCopy.Version(number: "26.2", build: "17C51"), sittingIn: "Applications")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode 26.2 (17C51) — Applications"])
    }

    @Test("A copy of Xcode carrying no version is named by where it sits")
    func measure_namesACopyCarryingNoVersionByWhereItSits() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: nil, sittingIn: "Desktop")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode — Desktop"])
    }

    @Test("Two copies of one version are told apart by where they sit")
    func measure_tellsTwoCopiesOfOneVersionApartByWhereTheySit() {
        let version = XcodeCopy.Version(number: "26.2", build: "17C51")
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: version, sittingIn: "Applications"), copy(carrying: version, sittingIn: "Desktop")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode 26.2 (17C51) — Applications", "Xcode 26.2 (17C51) — Desktop"])
    }

    @Test("A copy of Xcode that is open is delivered as open")
    func measure_deliversAnOpenCopyAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByCommandLineTools: false)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test("The copy the command line tools point at is delivered as the one they point at")
    func measure_deliversThePointedAtCopyAsTheOneTheToolsPointAt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByCommandLineTools: true)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.commandLineToolsPointAtIt])
    }

    @Test("A copy of Xcode that is both open and pointed at is delivered as open")
    func measure_deliversACopyThatIsBothOpenAndPointedAtAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByCommandLineTools: true)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test
    func measure_deliversACopyNeitherOpenNorPointedAtWithNothingRefusingIt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByCommandLineTools: false)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil])
    }

    @Test("A copy of Xcode sitting where the developer cannot write says so in what it costs")
    func measure_deliversACopyThatCannotBeRemovedWhereItStandsSayingTheBundleStays() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(canBeRemoved: false)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(
            received.map(\.cost)
                == ["that version has to be downloaded again, and the empty bundle stays where it is because removing it needs an administrator"])
    }

    @Test("A copy of Xcode carries what deleting it costs")
    func measure_deliversACopyWithWhatDeletingItCosts() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy()]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.cost) == ["that version has to be downloaded again"])
    }

    @Test
    func measure_deliversACopyWhereTheSearchFoundIt() {
        let (sut, disk, copies) = makeSUT()
        let found = copy(sittingIn: "Applications")
        copies.reported = [found]

        let received = sut.leftovers(announcing: disk.announce)

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
