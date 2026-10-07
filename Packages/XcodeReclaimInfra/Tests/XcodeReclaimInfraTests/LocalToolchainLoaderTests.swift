import Foundation
import Testing
import XcodeReclaimEngine
import XcodeReclaimInfra

struct LocalToolchainLoaderTests {
    @Test("A toolchain is delivered with the name its record gives it")
    func load_deliversAToolchainWithTheNameItsRecordGivesIt() {
        let roomItTakes = 3_500_000_000
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let toolchain = madeToolchain(named: "swift-6.2.4-RELEASE", displayName: "Swift 6.2.4 Release 2026-02-24 (a)", inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [toolchain]
        disk.sizes[toolchain] = roomItTakes

        let received = sut.load()

        #expect(received == [Toolchain(path: toolchain, name: "Swift 6.2.4 Release 2026-02-24 (a)", isPointedAtBySwiftLatest: false, bytes: roomItTakes)])
    }

    @Test("A toolchain whose record cannot be read is delivered named by its folder")
    func load_namesAToolchainWhoseRecordCannotBeReadByItsFolder() {
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let toolchain = FolderOnDisk.putAFolder(named: "swift-6.2-RELEASE.xctoolchain", inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [toolchain]

        let received = sut.load()

        #expect(received.map(\.name) == ["swift-6.2-RELEASE"])
    }

    @Test(
        "The toolchain swift-latest points at is delivered as the one it points at",
        arguments: [
            "swift-6.4.0-RELEASE.xctoolchain",
            "swift-6.4.0-RELEASE.xctoolchain/",
            "./swift-6.4.0-RELEASE.xctoolchain",
        ])
    func load_deliversTheToolchainSwiftLatestPointsAtAsTheOneItPointsAt(writtenRelatively destination: String) {
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let older = FolderOnDisk.putAFolder(named: "swift-6.2.4-RELEASE.xctoolchain", inside: toolchains)
        let latest = FolderOnDisk.putAFolder(named: "swift-6.4.0-RELEASE.xctoolchain", inside: toolchains)
        linkSwiftLatest(to: destination, inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [older, latest]

        let received = sut.load()

        #expect(received.map(\.isPointedAtBySwiftLatest) == [false, true])
    }

    @Test
    func load_deliversTheToolchainALinkWrittenInFullPointsAtAsTheOneItPointsAt() {
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let latest = FolderOnDisk.putAFolder(named: "swift-6.4.0-RELEASE.xctoolchain", inside: toolchains)
        linkSwiftLatest(to: latest.path(percentEncoded: false), inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [latest]

        let received = sut.load()

        #expect(received.map(\.isPointedAtBySwiftLatest) == [true])
    }

    @Test
    func load_deliversTheToolchainALinkWrittenInFullThroughItsParentPointsAtAsTheOneItPointsAt() {
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let latest = FolderOnDisk.putAFolder(named: "swift-6.4.0-RELEASE.xctoolchain", inside: toolchains)
        linkSwiftLatest(to: "\(toolchains.path(percentEncoded: false))/../\(toolchains.lastPathComponent)/swift-6.4.0-RELEASE.xctoolchain", inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [latest]

        let received = sut.load()

        #expect(received.map(\.isPointedAtBySwiftLatest) == [true])
    }

    @Test
    func load_deliversNoToolchainAsPointedAtWhenThereIsNoLink() {
        let toolchains = FolderOnDisk.made()
        defer { FolderOnDisk.throwAway(toolchains) }
        let toolchain = FolderOnDisk.putAFolder(named: "swift-6.4.0-RELEASE.xctoolchain", inside: toolchains)
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [toolchain]

        let received = sut.load()

        #expect(received.map(\.isPointedAtBySwiftLatest) == [false])
    }

    @Test
    func load_offersTheToolchainsTheFolderHoldsAndNothingElse() {
        let toolchains = URL(filePath: "/developer/Toolchains")
        let toolchain = toolchains.appending(path: "swift-6.4.0-RELEASE.xctoolchain")
        let (sut, disk) = makeSUT(readingToolchainsIn: toolchains)
        disk.folders[toolchains] = [toolchain, toolchains.appending(path: "swift-6.4.0-RELEASE.xctoolchain.old"), toolchains.appending(path: "Notes")]

        let received = sut.load()

        #expect(received.map(\.path) == [toolchain])
    }
}

private extension LocalToolchainLoaderTests {
    func makeSUT(readingToolchainsIn toolchains: URL) -> (sut: LocalToolchainLoader, disk: DiskStub) {
        let disk = DiskStub()
        let sut = LocalToolchainLoader(disk: disk, toolchainsFolder: toolchains)
        return (sut, disk)
    }

    func madeToolchain(named name: String, displayName: String, inside toolchains: URL) -> URL {
        let toolchain = FolderOnDisk.putAFolder(named: "\(name).xctoolchain", inside: toolchains)
        let written = (try? PropertyListSerialization.data(fromPropertyList: ["DisplayName": displayName], format: .xml, options: 0)) ?? Data()
        try? written.write(to: toolchain.appending(path: "Info.plist"))
        return toolchain
    }

    func linkSwiftLatest(to destination: String, inside toolchains: URL) {
        try? FileManager.default.createSymbolicLink(
            atPath: toolchains.appending(path: "swift-latest.xctoolchain").path(percentEncoded: false), withDestinationPath: destination)
    }
}
