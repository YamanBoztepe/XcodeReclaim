import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversArchiveTests {
    @Test("An archive is delivered with its name, its version, its build and when it was made")
    func measure_deliversAnArchiveWithItsNameItsVersionItsBuildAndWhenItWasMade() {
        let roomItTakes = 385_875_968
        let secondsFrom2001ToTheSixteenthOfSeptember = 811_264_966.0
        let created = Date(timeIntervalSinceReferenceDate: secondsFrom2001ToTheSixteenthOfSeptember)
        let path = archivePath(named: "Communite Test 676")
        let (sut, disk, archives) = makeSUT()
        archives.reported = [
            Archive(path: path, name: "Communite Test", version: "2.0.0", build: "676", created: created, bytes: roomItTakes)
        ]

        let received = sut.leftovers(measuring: [.archives], announcing: disk.announce)

        #expect(
            received == [
                Leftover(
                    kind: .archive(name: "Communite Test", version: "2.0.0", build: "676", created: created), bytes: roomItTakes,
                    place: .folder(path))
            ])
    }

    @Test
    func measure_deliversEveryArchiveTheLoaderReportsWithItsOwnRoom() {
        let (sut, disk, archives) = makeSUT()
        archives.reported = [archive(named: "Communite Test 676", taking: 300), archive(named: "Communite Test 675", taking: 200)]

        let received = sut.leftovers(measuring: [.archives], announcing: disk.announce)

        #expect(received.map(\.place) == [.folder(archivePath(named: "Communite Test 676")), .folder(archivePath(named: "Communite Test 675"))])
        #expect(received.map(\.bytes) == [300, 200])
    }
}

private extension MeasureLeftoversArchiveTests {
    func makeSUT() -> (sut: MeasureLeftovers, disk: WorldSpy, archives: ArchiveLoaderStub) {
        let anythingIsWorthDeleting = 1
        let disk = WorldSpy()
        let archives = ArchiveLoaderStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            cachesFolder: DeveloperFolder.caches,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            runtimeService: RuntimeServiceSpy(),
            xcodeCopyLoader: XcodeCopyLoaderStub(),
            archiveLoader: archives,
            toolchainLoader: ToolchainLoaderStub(),
            worthDeleting: anythingIsWorthDeleting)
        return (sut, disk, archives)
    }

    func archivePath(named name: String) -> URL {
        DeveloperFolder.root.appending(path: "Xcode/Archives/2026-09-16/\(name).xcarchive")
    }

    func archive(named folderName: String, taking bytes: Int) -> Archive {
        Archive(path: archivePath(named: folderName), name: "Communite Test", version: "2.0.0", build: "676", created: nil, bytes: bytes)
    }
}
