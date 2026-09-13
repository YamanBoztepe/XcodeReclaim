import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversXcodeCopyTests {
    @Test func everyCopyOfXcodeTheSearchReportsIsDeliveredWithTheRoomItTakes() {
        let roomTheFirstTakes = 4_000_000_000
        let roomTheSecondTakes = 3_000_000_000
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(sittingIn: "Applications", taking: roomTheFirstTakes), copy(sittingIn: "Desktop", taking: roomTheSecondTakes)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.bytes) == [roomTheFirstTakes, roomTheSecondTakes])
    }

    @Test func aCopyOfXcodeIsNamedByItsVersionItsBuildAndWhereItSits() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: XcodeCopy.Version(number: "26.2", build: "17C51"), sittingIn: "Applications")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode 26.2 (17C51) — Applications"])
    }

    @Test func aCopyOfXcodeCarryingNoVersionIsNamedByWhereItSits() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: nil, sittingIn: "Desktop")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode — Desktop"])
    }

    @Test func twoCopiesOfOneVersionAreToldApartByWhereTheySit() {
        let version = XcodeCopy.Version(number: "26.2", build: "17C51")
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(carrying: version, sittingIn: "Applications"), copy(carrying: version, sittingIn: "Desktop")]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Xcode 26.2 (17C51) — Applications", "Xcode 26.2 (17C51) — Desktop"])
    }

    @Test func aCopyOfXcodeThatIsOpenIsDeliveredAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByTheCommandLineTools: false)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test func theCopyTheCommandLineToolsPointAtIsDeliveredAsTheOneTheyPointAt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByTheCommandLineTools: true)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.theCommandLineToolsPointAtIt])
    }

    @Test func aCopyOfXcodeThatIsBothOpenAndPointedAtIsDeliveredAsOpen() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: true, isPointedAtByTheCommandLineTools: true)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [.xcodeIsOpen])
    }

    @Test func aCopyOfXcodeNeitherOpenNorPointedAtIsDeliveredWithNothingRefusingIt() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy(isOpen: false, isPointedAtByTheCommandLineTools: false)]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil])
    }

    @Test func aCopyOfXcodeCarriesWhatDeletingItCosts() {
        let (sut, disk, copies) = makeSUT()
        copies.reported = [copy()]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.cost) == ["that version has to be downloaded again"])
    }

    @Test func aCopyOfXcodeIsDeletedWhereTheSearchFoundIt() {
        let (sut, disk, copies) = makeSUT()
        let found = copy(sittingIn: "Applications")
        copies.reported = [found]

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.place) == [.xcodeCopy(found.path)])
    }
}

private extension MeasureLeftoversXcodeCopyTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: DiskSpy, copies: XcodeCopiesStub) {
        let disk = DiskSpy()
        let copies = XcodeCopiesStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            xcodeCopies: copies,
            worthDeleting: worthDeleting)
        return (sut, disk, copies)
    }

    func copy(
        carrying version: XcodeCopy.Version? = XcodeCopy.Version(number: "26.4.1", build: "17E201"),
        sittingIn folder: String = "Applications",
        taking bytes: Int = 200,
        isOpen: Bool = false,
        isPointedAtByTheCommandLineTools: Bool = false
    ) -> XcodeCopy {
        XcodeCopy(
            path: URL(fileURLWithPath: "/\(folder)/Xcode.app"),
            version: version,
            bytes: bytes,
            isOpen: isOpen,
            isPointedAtByTheCommandLineTools: isPointedAtByTheCommandLineTools)
    }
}
