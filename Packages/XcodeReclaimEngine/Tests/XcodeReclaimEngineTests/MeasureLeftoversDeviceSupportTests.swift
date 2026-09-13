import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversDeviceSupportTests {
    @Test func deviceSupportIsDeliveredOneVersionAtATime() {
        let roomTheNewerTakes = 200_000_000
        let roomTheOlderTakes = 300_000_000
        let (sut, disk) = makeSUT()
        let newer = DeveloperFolder.deviceSupportFolder(holding: "26.4")
        let older = DeveloperFolder.deviceSupportFolder(holding: "18.5")
        disk.folders[DeveloperFolder.deviceSupport] = [newer, older]
        disk.sizes[newer] = roomTheNewerTakes
        disk.sizes[older] = roomTheOlderTakes

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (iOS 18.5)", "Device support (iOS 26.4)"])
        #expect(received.map(\.bytes) == [roomTheOlderTakes, roomTheNewerTakes])
    }

    @Test func aDeviceSupportVersionTooSmallToBeWorthDeletingIsNotDelivered() {
        let worthDeleting = 100_000_000
        let (sut, disk) = makeSUT(worthDeleting: worthDeleting)
        let newer = DeveloperFolder.deviceSupportFolder(holding: "26.4")
        let older = DeveloperFolder.deviceSupportFolder(holding: "18.5")
        disk.folders[DeveloperFolder.deviceSupport] = [newer, older]
        disk.sizes[newer] = worthDeleting
        disk.sizes[older] = worthDeleting - 1

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (iOS 26.4)"])
    }

    @Test func deviceSupportHoldingNoVersionIsNotDelivered() {
        let (sut, disk) = makeSUT()
        disk.folders[DeveloperFolder.deviceSupport] = []
        disk.sizes[DeveloperFolder.derivedData] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data"])
    }

    @Test func aDeviceSupportVersionIsNamedByTheSystemVersionItHolds() {
        let (sut, disk) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(named: "iPhone15,2 26.5.2 (23F84)")
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        disk.sizes[symbols] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (iOS 26.5.2)"])
    }

    @Test(arguments: [
        "a folder nobody can parse",
        "26.5.2 (23F84)",
        "iPhone15,2 26.5.2 23F84",
        "iPhone15,2 26.5.2 (23F84) arm64e",
        "iPhone15,2 (23F84)",
    ])
    func aDeviceSupportFolderNamedSomeOtherWayIsDeliveredAsItIsNamed(folderName: String) {
        let (sut, disk) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(named: folderName)
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        disk.sizes[symbols] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (\(folderName))"])
    }
}

private extension MeasureLeftoversDeviceSupportTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: DiskSpy) {
        let disk = DiskSpy()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            xcodeCopies: XcodeCopiesStub(),
            worthDeleting: worthDeleting)
        return (sut, disk)
    }
}
