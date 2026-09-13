import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversDeviceSupportTests {
    @Test("Device support is delivered one version at a time")
    func measure_deliversDeviceSupportOneVersionAtATime() {
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

    @Test("A device support version too small to be worth deleting is not delivered")
    func measure_doesNotDeliverADeviceSupportVersionTooSmallToBeWorthDeleting() {
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

    @Test("Device support holding no version is not delivered")
    func measure_doesNotDeliverDeviceSupportHoldingNoVersion() {
        let (sut, disk) = makeSUT()
        disk.folders[DeveloperFolder.deviceSupport] = []
        disk.sizes[DeveloperFolder.derivedData] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Derived data"])
    }

    @Test("A device support version is named by the system version it holds")
    func measure_namesADeviceSupportVersionByTheSystemVersionItHolds() {
        let (sut, disk) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(named: "iPhone15,2 26.5.2 (23F84)")
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        disk.sizes[symbols] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (iOS 26.5.2)"])
    }

    @Test(
        "A device support folder named some other way is delivered as it is named",
        arguments: [
            "a folder nobody can parse",
            "26.5.2 (23F84)",
            "iPhone15,2 26.5.2 23F84",
            "iPhone15,2 26.5.2 (23F84) arm64e",
            "iPhone15,2 (23F84)",
        ])
    func measure_namesADeviceSupportFolderAsItIsNamedWhenItsShapeIsUnknown(folderName: String) {
        let (sut, disk) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(named: folderName)
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        disk.sizes[symbols] = 200

        let received = sut.leftovers(announcing: disk.announce)

        #expect(received.map(\.name) == ["Device support (\(folderName))"])
    }
}

private extension MeasureLeftoversDeviceSupportTests {
    func makeSUT(worthDeleting: Int = 1) -> (sut: MeasureLeftovers, disk: WorldSpy) {
        let disk = WorldSpy()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            xcodeCopies: XcodeCopiesStub(),
            worthDeleting: worthDeleting)
        return (sut, disk)
    }
}
