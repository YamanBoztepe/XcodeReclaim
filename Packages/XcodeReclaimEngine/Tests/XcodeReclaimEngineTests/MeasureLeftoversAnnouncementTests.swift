import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversAnnouncementTests {
    @Test("A measuring announces a leftover before it reads its size")
    func measure_announcesALeftoverBeforeItReadsItsSize() {
        let (sut, disk, _, _, _, _, _) = makeSUT()
        disk.sizes[DeveloperFolder.derivedData] = 200

        _ = sut.leftovers(measuring: MeasureLeftovers.Offered.allCases, announcing: disk.announce)

        #expect(
            disk.messages == [
                .announced(.derivedData), .sizeRead(DeveloperFolder.derivedData),
                .announced(.interfaceBuilderCache), .sizeRead(DeveloperFolder.interfaceBuilderCache),
                .announced(.previews), .sizeRead(DeveloperFolder.previews),
                .announced(.documentationCache), .sizeRead(DeveloperFolder.documentationCache),
                .foldersListed(DeveloperFolder.deviceSupport),
                .announced(.swiftPackageCache), .sizeRead(DeveloperFolder.swiftPackageCache),
            ])
    }

    @Test("Every offered source announces the leftovers it works on")
    func measure_announcesTheLeftoversEveryOfferedSourceWorksOn() {
        let (sut, disk) = makeSUTWhereEverySourceHoldsOne()

        _ = sut.leftovers(measuring: MeasureLeftovers.Offered.allCases, announcing: disk.announce)

        #expect(
            disk.announcements == [
                .derivedData,
                .interfaceBuilderCache,
                .previews,
                .documentationCache,
                .deviceSupport(systemVersion: "26.4"),
                .simulator(name: "iPhone 17", runtime: "iOS 26.4"),
                .xcodeCopy(version: Leftover.XcodeVersion(number: "26.2", build: "17C51"), canBeRemovedWhereItStands: true),
                .runtime(name: "iOS 26.2", build: "23C54", lastUsed: nil),
                .archive(name: "Communite Test", version: "2.0.0", build: "676", created: nil),
                .swiftPackageCache,
                .toolchain(name: "Swift 6.2.4 Release 2026-02-24 (a)"),
            ])
    }
}

private extension MeasureLeftoversAnnouncementTests {
    func makeSUTWhereEverySourceHoldsOne() -> (sut: MeasureLeftovers, disk: WorldSpy) {
        let roomEachTakes = 100
        let (sut, disk, simulators, copies, runtimes, archives, toolchains) = makeSUT()
        let symbols = DeveloperFolder.deviceSupportFolder(holding: "26.4")
        disk.folders[DeveloperFolder.deviceSupport] = [symbols]
        for folder in DeveloperFolder.everythingOffered + [symbols, DeveloperFolder.swiftPackageCache] {
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
                isPointedAtByCommandLineTools: false,
                canBeRemoved: true)
        ]
        runtimes.report = .success([
            Runtime(
                identifier: "9A65D489-798D-4E19-8CBC-FA5C9A1F2A1E", name: "iOS 26.2", build: "23C54", simulatorRuntime: "iOS 26.2", lastUsed: nil,
                bytes: roomEachTakes)
        ])
        archives.reported = [
            Archive(
                path: URL(fileURLWithPath: "/developer/Xcode/Archives/2026-09-16/Communite Test 676.xcarchive"), name: "Communite Test",
                version: "2.0.0", build: "676", created: nil, bytes: roomEachTakes)
        ]

        toolchains.reported = [
            Toolchain(
                path: DeveloperFolder.toolchains.appending(path: "swift-6.2.4-RELEASE.xctoolchain"), name: "Swift 6.2.4 Release 2026-02-24 (a)",
                isPointedAtBySwiftLatest: false, bytes: roomEachTakes)
        ]
        return (sut, disk)
    }

    func makeSUT(
        worthDeleting: Int = 1
    ) -> (
        sut: MeasureLeftovers, disk: WorldSpy, simulators: SimulatorServiceSpy, copies: XcodeCopyLoaderStub, runtimes: RuntimeServiceSpy,
        archives: ArchiveLoaderStub, toolchains: ToolchainLoaderStub
    ) {
        let disk = WorldSpy()
        let simulators = SimulatorServiceSpy()
        let copies = XcodeCopyLoaderStub()
        let runtimes = RuntimeServiceSpy()
        let archives = ArchiveLoaderStub()
        let toolchains = ToolchainLoaderStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            cachesFolder: DeveloperFolder.caches,
            disk: disk,
            simulatorService: simulators,
            runtimeService: runtimes,
            xcodeCopyLoader: copies,
            archiveLoader: archives,
            toolchainLoader: toolchains,
            worthDeleting: worthDeleting)
        return (sut, disk, simulators, copies, runtimes, archives, toolchains)
    }
}
