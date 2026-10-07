import Foundation
import Testing
import XcodeReclaimCore
import XcodeReclaimEngine

struct MeasureLeftoversToolchainTests {
    @Test("A toolchain is delivered with the name its record gives it")
    func measure_deliversAToolchainWithItsNameAndTheRoomItTakes() {
        let roomItTakes = 3_500_000_000
        let path = DeveloperFolder.toolchains.appending(path: "swift-6.2.4-RELEASE.xctoolchain")
        let (sut, disk, toolchains) = makeSUT()
        toolchains.reported = [Toolchain(path: path, name: "Swift 6.2.4 Release 2026-02-24 (a)", isPointedAtBySwiftLatest: false, bytes: roomItTakes)]

        let received = sut.leftovers(measuring: [.toolchains], announcing: disk.announce)

        #expect(received == [Leftover(kind: .toolchain(name: "Swift 6.2.4 Release 2026-02-24 (a)"), bytes: roomItTakes, place: .folder(path))])
    }

    @Test("The toolchain swift-latest points at is delivered as the one it points at")
    func measure_deliversTheToolchainSwiftLatestPointsAtAsRefused() {
        let (sut, disk, toolchains) = makeSUT()
        toolchains.reported = [toolchain(named: "Swift 6.2.4", isPointedAtBySwiftLatest: false), toolchain(named: "Swift 6.4", isPointedAtBySwiftLatest: true)]

        let received = sut.leftovers(measuring: [.toolchains], announcing: disk.announce)

        #expect(received.map(\.refusal) == [nil, .swiftLatestPointsAtIt])
    }
}

private extension MeasureLeftoversToolchainTests {
    func makeSUT() -> (sut: MeasureLeftovers, disk: WorldSpy, toolchains: ToolchainLoaderStub) {
        let anythingIsWorthDeleting = 1
        let disk = WorldSpy()
        let toolchains = ToolchainLoaderStub()
        let sut = MeasureLeftovers(
            developerFolder: DeveloperFolder.root,
            cachesFolder: DeveloperFolder.caches,
            disk: disk,
            simulatorService: SimulatorServiceSpy(),
            runtimeService: RuntimeServiceSpy(),
            xcodeCopyLoader: XcodeCopyLoaderStub(),
            archiveLoader: ArchiveLoaderStub(),
            toolchainLoader: toolchains,
            worthDeleting: anythingIsWorthDeleting)
        return (sut, disk, toolchains)
    }

    func toolchain(named name: String, isPointedAtBySwiftLatest: Bool, taking bytes: Int = 1) -> Toolchain {
        Toolchain(
            path: DeveloperFolder.toolchains.appending(path: "\(name).xctoolchain"), name: name, isPointedAtBySwiftLatest: isPointedAtBySwiftLatest,
            bytes: bytes)
    }
}
