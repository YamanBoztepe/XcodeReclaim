import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversAnnouncementTests {
    @Test("A measuring announces a leftover before it reads its size")
    func measure_announcesALeftoverBeforeItReadsItsSize() {
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 200

        _ = sut.leftovers(announcing: disk.announce)

        #expect(
            disk.messages == [
                .announced("Derived data"), .sizeRead(DeveloperFolder.derivedData),
                .announced("Interface builder cache"), .sizeRead(DeveloperFolder.interfaceBuilderCache),
                .announced("Previews"), .sizeRead(DeveloperFolder.previews),
                .announced("Documentation cache"), .sizeRead(DeveloperFolder.documentationCache),
                .foldersListed(DeveloperFolder.deviceSupport),
            ])
    }

    @Test("A measuring announces every offered leftover in the order it works on them")
    func measure_announcesEveryOfferedLeftoverInTheOrderItWorksOnThem() {
        let roomEachTakes = 100
        let (sut, disk, simulators, copies) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(holding: "26.4")
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        for folder in DeveloperFolder.everythingOffered + [symbols] {
            disk.sizes[folder] = roomEachTakes
        }
        simulators.report = .success([
            Simulator(identifier: "21B507D3-909E-465B-957C-4B370278399F", name: "iPhone 17", runtime: "iOS 26.4", isShutDown: true, bytes: roomEachTakes)
        ])
        copies.reported = [
            XcodeCopy(
                path: URL(fileURLWithPath: "/Applications/Xcode.app"),
                version: XcodeCopy.Version(number: "26.2", build: "17C51"),
                bytes: roomEachTakes,
                isOpen: false,
                isPointedAtByTheCommandLineTools: false)
        ]

        _ = sut.leftovers(announcing: disk.announce)

        #expect(
            disk.announcements == [
                "Derived data",
                "Interface builder cache",
                "Previews",
                "Documentation cache",
                "Device support (iOS 26.4)",
                "iPhone 17 (iOS 26.4, 21B507D3)",
                "Xcode 26.2 (17C51) — Applications",
            ])
    }

    @Test("A measuring that is not listened to still delivers its leftovers")
    func measure_deliversItsLeftoversWhenNothingIsListening() {
        let roomItTakes = 200
        let (sut, disk, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = roomItTakes

        let received = sut.leftovers()

        #expect(received == [Leftover(name: "Derived data", bytes: roomItTakes, place: .folder(DeveloperFolder.derivedData))])
    }
}

private extension MeasureLeftoversAnnouncementTests {
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
